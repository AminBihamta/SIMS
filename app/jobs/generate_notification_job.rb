class GenerateNotificationJob < ApplicationJob
  queue_as :default
  
  def perform(borrowing_id = nil)
    if borrowing_id
      process_single_borrowing(borrowing_id)
    else
      process_all_borrowings
    end
  end

  private

  def process_single_borrowing(borrowing_id)
    borrowing = Borrowing.find(borrowing_id)
    create_notification_for_borrowing(borrowing)
  end

  def process_all_borrowings
    Borrowing.needs_notification.find_each do |borrowing|
      create_notification_for_borrowing(borrowing)
    end
  end

  def create_notification_for_borrowing(borrowing)
    return if Notification.exists?(borrowing_id: borrowing.id)
    
    days_overdue = (Date.current - borrowing.due_date.to_date).to_i
    user = UserData.find_by(club_id: borrowing.club_id)
    
    notification = Notification.create!(
      borrowing: borrowing,
      notification_type: 'overdue_alert',
      message: generate_message(borrowing, days_overdue, user&.is_supervisor),
      triggered_at: Time.current,
      status: 'pending'
    )

    Rails.logger.info "Created notification for borrowing #{borrowing.id}"
  rescue => e
    Rails.logger.error "Failed to create notification: #{e.message}"
  end

  def generate_message(borrowing, days_overdue, is_supervisor)
    if is_supervisor
      "OVERDUE ALERT: #{borrowing.equipment.Equipment_Name} " \
      "borrowed by #{borrowing.club.Club_Name} is " \
      "#{days_overdue} #{'day'.pluralize(days_overdue)} overdue."
    else
      "OVERDUE ALERT: #{borrowing.equipment.Equipment_Name} is " \
      "#{days_overdue} #{'day'.pluralize(days_overdue)} overdue."
    end
  end
end