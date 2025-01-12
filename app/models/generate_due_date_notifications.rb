private

def generate_due_date_notifications
  return if due_date.nil?

  # Ensure both objects are of the same type
  due_date_obj = due_date.to_date
  today_obj = Date.today

  if due_date_obj < today_obj
    # Generate Overdue Notification
    notifications.create!(
      notification_type: "Overdue",
      message: "#{equipment.Equipment_Name} is overdue by #{(today_obj - due_date_obj).to_i} days.",
      triggered_at: Time.now,
      status: "pending"
    )
  elsif due_date_obj <= today_obj + 3.days
    # Generate Upcoming Due Date Notification
    notifications.create!(
      notification_type: "Upcoming Due Date",
      message: "#{equipment.Equipment_Name} is due in #{(due_date_obj - today_obj).to_i} days.",
      triggered_at: Time.now,
      status: "pending"
    )
  end
end
