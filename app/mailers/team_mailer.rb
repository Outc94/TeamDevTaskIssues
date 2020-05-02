class TeamMailer < ApplicationMailer
  def mail_users(user)
     mail(to: user.email, subject: `The agenda you were in has been deleted`)
 end
end
