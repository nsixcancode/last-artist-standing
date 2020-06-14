# frozen_string_literal: true

# Represents a challenge on the website.
class Challenge < ApplicationRecord
  belongs_to :creator, class_name: 'User'

  # TODO: Do these two associations work together in a way that breaks deleting challenges?
  has_many :badges, dependent: :destroy
  has_many :badge_maps, dependent: :destroy
  has_many :challenge_entries
  has_many :entries, through: :challenge_entries, source: :submission
  has_many :notifications, as: :source, dependent: :destroy
  has_many :participations, dependent: :destroy
  has_many :users, through: :participations

  NO_EXCESS_WHITESPACE = /\A(\S\s?)*\S\z/.freeze

  validates :name, presence: true, length: { maximum: 100 },
                   format: { with: NO_EXCESS_WHITESPACE }, uniqueness: { case_sensitive: false }
  validates :description, presence: true, length: { maximum: 2000 }
  validates :start_date, presence: true
  validates :nsfw_level, presence: true, numericality: { only_integer: true,
                                                         greater_than_or_equal_to: 1,
                                                         less_than_or_equal_to: 3 }
  # There is no required end date, indicating an indefinte challenge
  # (should only apply to the primary DED challenge).
  # NOTE: End date should be EXCLUSIVE, not INCLUSIVE
  validates :postfrequency, presence: true, numericality: { only_integer: true,
                                                            greater_than_or_equal_to: -1,
                                                            less_than_or_equal_to: 7 }

  validate :end_date_cannot_precede_start_date

  def badge
    # There should only be one badge per challenge.
    # FIXME: The model should ensure that this is the case!
    badges.first
  end

  def started?
    Time.now.utc.to_date > start_date
  end

  # FIXME: Rename to `deletable?`
  def can_delete?
    !started?
  end

  def end_date_cannot_precede_start_date
    return unless end_date.present? && end_date <= start_date

    errors.add(:end_date, ' cannot precede or equal start date.')
  end

  def self.current_season
    Challenge.where(':todays_date >= start_date AND :todays_date < end_date AND seasonal = true',
                    { todays_date: Time.now.utc.to_date }).first
  end
end
