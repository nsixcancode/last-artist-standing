module ParticipationsHelper
  PARTICIPATION_ICONS_MARKUP = {
    0 => "<i class='fa fa-times-circle' aria-hidden='true'></i>",
    1 => "<i class='fa fa-check' aria-hidden='true'></i>",
    2 => "<i class='fa fa-trophy' aria-hidden='true'></i>",
  }

  def user_is_participating(user, challenge)
    !Participation.find_by(user_id: user.id, challenge_id: challenge.id).blank?
  end

  def participation_icon(value)
    PARTICIPATION_ICONS_MARKUP[value]
  end
end
