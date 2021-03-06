# frozen_string_literal: true

class AddChallengeIdToBadges < ActiveRecord::Migration[5.0]
  def change
    add_column :badges, :challenge_id, :integer

    Badge.all.each do |badge|
      badge.challenge_id = BadgeMap.where(badge_id: badge.id).first.challenge_id
      badge.save!
    end
  end
end
