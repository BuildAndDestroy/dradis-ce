class NotificationMailer < ApplicationMailer
  def digest
    @user = params[:user]
    @notifications = params[:notifications]
    count = @notifications.count

    mail to: @user.email, subject: "You have #{count} of unread #{'notification'.pluralize(count)}"
  end
end
