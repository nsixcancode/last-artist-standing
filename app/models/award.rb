# frozen_string_literal: true

class Award < ApplicationRecord
  # FIXME: `created_at` and `updated_at` are probably pointless, given we have `date_recieved`.

  # FIXME: Awards should be uniquely identified by user and badge, so the `id` is unnecessary.

  belongs_to :user
  belongs_to :badge

  # Really, an award has only one associated badge_map
  # (assuming badge maps should have unique prestige modulo badge),
  # but this is necessary to include that data in queries.
  has_many :badge_maps, through: :badge
  has_one :challenge, through: :badge

  validates :user_id, presence: true
  validates :badge_id, presence: true

  # FIXME: Shouldn't prestige be a property of the associated badge map, not part of the award?
  #   Perhaps the award should be associated with a badge_map rather than (just) with a badge.
  validates :prestige, presence: true, numericality: { only_integer: true }
  validates :date_received, presence: true

  # FIXME: This uniqueness should be reflected in the schema as an index.
  validates :user_id, uniqueness: { scope: :badge_id }

  def badge_map
    # This being present isn't actually enforced by the model,
    # so this *could* potentially return null.
    # It'll have to be good enough for now, until challenges are reworked.
    badge_maps.select { |map| map.badge_id == badge_id && map.prestige == prestige }.first
  end
end
