class GenerateNotificationJob < ApplicationJob
  queue_as :default
  
  retry_on ActiveRecord::RecordInvalid, wait: 5.seconds, attempts: 3
  
  def perform
    Rails.logger.info "Starting GenerateNotificationJob at #{Time.current}"
    
    Borrowing.needs_notification.find_each do |borrowing|
      create_notification_for_borrowing(borrowing)
    end
  rescue => e
    Rails.logger.error "Error in GenerateNotificationJob: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise e
  end
  
  private
  
  def create_notification_for_borrowing(borrowing)
    days_overdue = (Date.current - borrowing.due_date.to_date).to_i
    
    notification = Notification.create!(
      borrowing: borrowing,
      notification_type: 'overdue_alert',
      message: generate_message(borrowing, days_overdue),
      triggered_at: Time.current,
      status: 'pending'
    )

    NotificationDeliveryJob.perform_later(notification.id)
    Rails.logger.info "Created notification for borrowing #{borrowing.id}"
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create notification for borrowing #{borrowing.id}: #{e.message}"
  end

  def generate_message(borrowing, days_overdue)
    "OVERDUE ALERT: #{borrowing.equipment.Equipment_Name} " \
    "borrowed by #{borrowing.club.Club_Name} is " \
    "#{days_overdue} #{'day'.pluralize(days_overdue)} overdue. " \
    "Due date was #{borrowing.due_date.strftime('%B %d, %Y')}."
  end
end