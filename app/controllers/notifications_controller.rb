class NotificationsController < ApplicationController
  def index
    @notifications = Notification.includes(:borrowing).all
  end

  def send_to_pic
    @notification = Notification.find(params[:id])
    
    if @notification.status == "pending"
      NotificationDeliveryJob.perform_now(@notification.id)
      flash[:notice] = "Notification sent to PIC successfully."
    else
      flash[:alert] = "Notification has already been #{@notification.status}."
    end
    
    redirect_to notifications_path
  end
end