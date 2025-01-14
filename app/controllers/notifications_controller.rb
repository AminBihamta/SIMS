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

  def return_equipment
    notification = Notification.find(params[:id])
    borrowing = notification.borrowing

    if borrowing.update(status: "returned")
      borrowing.equipment.update(Status: 'Available', stock: 1)
      borrowing.restore_stock_on_destroy
      notification.destroy
      flash[:success] = "Borrowing status updated to returned and notification destroyed."
    else
      flash[:error] = "Failed to update borrowing status."
    end
    redirect_to notifications_path
  end
end