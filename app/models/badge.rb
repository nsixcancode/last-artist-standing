class Badge < ApplicationRecord
  mount_uploader :avatar, ImageUploader
  
  has_many :awards
  has_many :badge_maps
  has_many :users, through: :awards
  has_many :challenges, through: :badge_maps
  
  NO_EXCESS_WHITESPACE = /\A(\S\s?)*\S\z/
  
  validates :name, presence: true, length: { maximum: 100 }, format: { with: NO_EXCESS_WHITESPACE }, uniqueness: { case_sensitive: false }
  validate :avatar_exists
  
  def avatar_exists
    if !avatar.present? && !direct_image.present?
      errors.add(:avatar, "should be provided for the badge.")
    end
  end

  def avatar_url
    direct_image || avatar.avatar.url
  end
end
