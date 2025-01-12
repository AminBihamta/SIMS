class NotificationsController < ApplicationController
  def index
    @notifications = Notification.includes(:borrowing).all
  end

  def show
    @notification = Notification.find(params[:id])
    @histories = @notification.notification_histories
  end

  def send_to_pic
    @notification = Notification.find(params[:id])
    
    if @notification.status != "delivered"
      @notification.update!(status: "pending")
      NotificationDeliveryJob.perform_later(@notification.id)
      
      flash[:notice] = "Notification will be sent to PIC shortly."
    else
      flash[:alert] = "Notification has already been sent."
    end
    
    redirect_to notifications_path
  end

  def resend
    notification = Notification.find(params[:id])
    NotificationDeliveryJob.perform_later(notification.id)
    redirect_to notifications_path, notice: "Notification resent successfully."
  end
end
