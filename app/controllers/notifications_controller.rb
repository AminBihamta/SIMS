class NotificationsController < ApplicationController
    def index
      # Fetch all notifications to display
      @notifications = Notification.all
    end
  
    def show
      # Fetch the notification and its histories
      @notification = Notification.find(params[:id])
      @histories = @notification.notification_histories
    end
  
    def resend
      # Fetch the notification by ID
      notification = Notification.find(params[:id])
  
      # Queue the delivery job
      NotificationDeliveryJob.perform_later(notification.id)
  
      # Redirect back with success message
      redirect_to notifications_path, notice: "Notification resent successfully."
    end
  
    # New Methods for Borrowing Notifications
  
    def create_borrowing_notification(borrowing)
      Notification.create(
        borrowing_id: borrowing.id,
        message: "#{borrowing.equipment.name} borrowed by #{borrowing.club.name} on #{borrowing.borrow_date}.",
        status: "pending",
        triggered_at: Time.current
      )
    end
  
    def create_overdue_notification(borrowing)
      Notification.create(
        borrowing_id: borrowing.id,
        message: "#{borrowing.equipment.name} is overdue by #{(Date.today - borrowing.due_date).to_i} days.",
        status: "delivered",
        triggered_at: Time.current
      )
    end
  end
  