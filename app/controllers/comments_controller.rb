# frozen_string_literal: true

class CommentsController < ApplicationController
  include CommentsHelper
  include SubmissionsHelper

  before_action :set_source, only: %i[new create]
  before_action :use_canonical_comment_url, only: %i[show destroy]
  before_action :set_comment, only: %i[destroy]
  before_action :ensure_authenticated, only: %i[new create destroy]
  before_action -> { ensure_authorized @comment.user_id }, only: %i[destroy]
  before_action :ensure_authorized_to_comment, only: %i[create]

  def index
    respond_to do |format|
      format.html do
        redirect_to "#{url_for(@source)}#comments", status: :temporary_redirect
      end

      format.json do
        # FIXME: The term used in the schema is source,
        #   so @target should be renamed to @source generally.
        @source = source_model.includes(comments: :user).find_by(id: source_id)

        render_not_found_json if @source.nil?
      end
    end
  end

  def show
    respond_to do |format|
      # TODO: Is it safe to use :moved_permanently in this case,
      #   or would that interfere with JSON requests?
      format.html { redirect_to comment_html_path(@comment), status: :temporary_redirect }

      format.json do
        # The source must be included to use `url_for(source)`
        # Perhaps we can come up with an alternative so that that won't be necessary.
        @comment = Comment.includes(:source, :user).find_by(id: params[:id])

        render_not_found_json if @comment.nil?
      end
    end
  end

  def new
    @comment = Comment.new
  end

  def create
    @comment = @source.comments.new(comment_params)
    @comment.user_id = current_user.id
    @comment.body = @comment.body.gsub(/ +/, ' ').strip

    unless @comment.save
      flash[:error] = 'Comment failed to post: ' + @comment.errors.full_messages.join(', ')
      redirect_back(fallback_location: '/')
      return
    end

    # FIXME: Use `Comments.where(source: source).count` instead of a table column, then remove this.
    @source.num_comments += 1
    @source.save!

    send_notifications

    flash[:success] = 'Comment posted successfully!'
    redirect_to comment_path(@comment), status: :see_other
  end

  def destroy
    @comment.destroy!

    source = @comment.source
    source.num_comments -= 1
    source.save!

    # Odds are, the source path are where the user was in the first place.
    redirect_back(fallback_location: url_for(comment.source))
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :user_id)
  end

  def use_canonical_comment_url
    return unless source_id

    # The canonical URL for comments is their `comment_path`.
    # Nested collection paths (e.g. `submission_comment_path`) should not be used.
    redirect_to comment_path(params[:id]), status: 308
  end

  def source_model
    Submission if params[:submission_id]
  end

  def source_id
    params[:submission_id] # if params[:submission_id]
  end

  def set_source
    @source = source_model.find_by(id: source_id)

    render_not_found if @source.nil?
  end

  def set_comment
    @comment = Comment.find_by(id: params[:id])

    render_not_found if @comment.nil?
  end

  def ensure_authorized_to_comment
    has_permission, error = @source.can_be_commented_on_by(current_user)
    return if has_permission

    flash[:error] = error
    redirect_back(fallback_location: root_path)
  end

  def send_notification(message, user_id)
    Notification.create(
      body: format(message, poster: current_user.username,
                            target: "#{@source.display_title} (ID: #{@source.id})"),
      source_type: 'Comment',
      source_id: @comment.id,
      user_id: user_id,
      url: comment_html_path(@comment)
    )
  end

  def send_notifications
    # Notifications are not currently implemented for targets other than submissions.
    return unless @source.is_a? Submission

    # Send a notification to the artist unless they're the commenter.
    unless @source.user_id == current_user.id
      send_notification('%<poster>s has commented on your submission %<target>s.', @source.user_id)
    end

    discussion_users = @source.comments.group(:user_id).pluck(:user_id)
    discussion_users.each do |user_id|
      # Don't send notifications to ourselves.
      next if user_id == current_user.id
      # Don't send the artist two notifications for the same comment.
      next if @source.user_id == user_id

      send_notification('%<poster>s has also commented on submission %<target>s.', user_id)
    end
  end
end
