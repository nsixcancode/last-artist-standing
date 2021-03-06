# frozen_string_literal: true

class SubmissionTest < ActiveSupport::TestCase
  def setup
    @submission = build(:submission, user: create(:user))
  end

  test 'should be valid' do
    assert @submission.valid?
  end

  test 'user_id should be present' do
    @submission.user_id = nil
    assert_not @submission.valid?
  end

  test 'drawing should be present' do
    @submission.drawing = '  '
    assert_not @submission.valid?
  end

  test 'nsfw_level should be present' do
    @submission.nsfw_level = nil
    assert_not @submission.valid?
  end

  test 'nsfw_level should not be a decimal' do
    @submission.nsfw_level = 1.5
    assert_not @submission.valid?
  end

  test 'nsfw_level should not exceed 3' do
    @submission.nsfw_level = 4
    assert_not @submission.valid?
  end

  test 'nsfw_level should not be less than 1' do
    @submission.nsfw_level = 0
    assert_not @submission.valid?
  end
end
