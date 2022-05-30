# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  def invite_from_admin_email
    UserMailer.with(user: User.first).invite_from_admin_email
  end

  def invite_from_community_email
    UserMailer.with(user: User.first).invite_from_community_email
  end

  def reset_instructions_email
    UserMailer.with(user: User.first).reset_instructions_email
  end

end
