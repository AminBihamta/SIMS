class GenerateNotificationJob < ApplicationJob
  queue_as :default
  
  retry_on ActiveRecord::RecordInvalid, wait: 1.minute, attempts: 3
  
  def perform
    Rails.logger.info("Starting GenerateNotificationJob at #{Time.current}")
    
    overdue_borrowings = Borrowing
      .includes(:equipment, :club) # Eager load associations
      .where(status: "overdue")
      .where.not(id: Notification.select(:borrowing_id)) # Exclude those that already have notifications
    
    if overdue_borrowings.empty?
      Rails.logger.info("No new overdue borrowings found requiring notifications.")
      return
    end
    
    created_count = 0
    failed_count = 0
    
    overdue_borrowings.each do |borrowing|
      begin
        create_notification_for_borrowing(borrowing)
        created_count += 1
      rescue StandardError => e
        failed_count += 1
        Rails.logger.error("Failed to create notification for Borrowing ID: #{borrowing.id}")
        Rails.logger.error("Error: #{e.message}")
        Rails.logger.error(e.backtrace.join("\n"))
      end
    end
    
    Rails.logger.info("GenerateNotificationJob completed: #{created_count} notifications created, #{failed_count} failed")
  end
  
  private
  
  def create_notification_for_borrowing(borrowing)
    days_overdue = (Date.current - borrowing.due_date.to_date).to_i
    equipment_name = borrowing.equipment&.Equipment_Name || "equipment"
    club_name = borrowing.club&.Club_Name || "unknown club"
    
    notification = Notification.create!(
      borrowing_id: borrowing.id,
      notification_type: "borrow_overdue",
      message: generate_overdue_message(borrowing, days_overdue),
      triggered_at: Time.current,
      status: "pending"
    )
    
    Rails.logger.info("Created notification ID: #{notification.id} for Borrowing ID: #{borrowing.id}")
    
    # Enqueue the delivery job
    NotificationDeliveryJob.perform_later(notification.id)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Validation failed for notification: #{e.message}")
    raise e
  end
  
  def generate_overdue_message(borrowing, days_overdue)
    equipment_name = borrowing.equipment&.Equipment_Name || "equipment"
    club_name = borrowing.club&.Club_Name || "unknown club"
    due_date = borrowing.due_date.strftime("%B %d, %Y")
    
    "OVERDUE NOTICE: #{equipment_name} borrowed by #{club_name} is #{days_overdue} #{'day'.pluralize(days_overdue)} overdue. " \
    "Original due date: #{due_date}. " \
    "Please return the equipment immediately to avoid any penalties. " \
    "If you have already returned this item, please contact the equipment management office."
  end
end