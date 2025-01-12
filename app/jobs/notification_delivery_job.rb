class NotificationDeliveryJob < ApplicationJob
  queue_as :default

  def perform(notification_id)
    notification = Notification.find(notification_id)
    borrowing = notification.borrowing
    
    begin
      # Find PIC associated with the club
      pic = UserData.find_by(club_id: borrowing.club_id)
      
      if pic
        success = notification.update(status: "delivered")
        if success
          Rails.logger.info "Notification #{notification_id} delivered to PIC of club #{borrowing.club_id}"
        else
          Rails.logger.error "Failed to deliver notification: #{notification.errors.full_messages.join(', ')}"
          notification.update(status: "failed")
        end
      else
        Rails.logger.error "No PIC found for club #{borrowing.club_id}"
        notification.update(status: "failed")
      end
    rescue => e
      Rails.logger.error "Error delivering notification: #{e.message}"
      notification.update(status: "failed")
    end
  end
end