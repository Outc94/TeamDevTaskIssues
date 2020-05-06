class TeamOwnerMailer < ApplicationMailer
  def mail_new_owner(owner)
    mail(to: owner, subject: `You are the new team owner, this email confirms it.`)
  end
end
