class GenerateNotificationJob < ApplicationJob
    queue_as :default
  
    def perform(borrowing_id)
      borrowing = Borrowing.find_by(id: borrowing_id)
      return if borrowing.nil? || borrowing.due_date.nil?
  
      due_date_obj = borrowing.due_date.to_date
      today_obj = Date.today
  
      if due_date_obj < today_obj
        borrowing.notifications.create!(
          notification_type: "Overdue",
          message: "#{borrowing.equipment.Equipment_Name} is overdue by #{(today_obj - due_date_obj).to_i} days.",
          triggered_at: Time.now,
          status: "pending"
        )
      elsif due_date_obj <= today_obj + 3.days
        borrowing.notifications.create!(
          notification_type: "Upcoming Due Date",
          message: "#{borrowing.equipment.Equipment_Name} is due in #{(due_date_obj - today_obj).to_i} days.",
          triggered_at: Time.now,
          status: "pending"
        )
      end
    end
  end
  