class NotificationDeliveryJob < ApplicationJob
  queue_as :default

  def perform(notification_id)
    notification = Notification.find(notification_id)

    begin
      case notification.notification_type
      when "borrow_created"
        deliver_borrow_created(notification)
      when "borrow_updated"
        deliver_borrow_updated(notification)
      when "borrow_canceled"
        deliver_borrow_canceled(notification)
      else
        deliver_default(notification)
      end
    rescue => e
      notification.update!(status: "failed")
      log_failure(notification, "in-app", e.message)
      Rails.logger.error("NotificationDeliveryJob failed: #{e.message}")
    end
  end

  private

  def deliver_borrow_created(notification)
    if deliver_in_app(notification)
      notification.update!(status: "delivered")
      log_success(notification, "in-app")
    else
      notification.update!(status: "failed")
      log_failure(notification, "in-app", "Delivery failed.")
    end
  end

  def deliver_borrow_updated(notification)
    deliver_borrow_created(notification) # Placeholder for specific logic
  end

  def deliver_borrow_canceled(notification)
    deliver_borrow_created(notification) # Placeholder for specific logic
  end

  def deliver_default(notification)
    deliver_borrow_created(notification) # Placeholder for generic notifications
  end

  def deliver_in_app(notification)
    # Simulate in-app notification delivery
    true
  end

  def log_success(notification, method)
    notification.notification_histories.create!(
      delivery_status: "success",
      delivery_method: method,
      delivered_at: Time.now
    )
  end

  def log_failure(notification, method, reason)
    notification.notification_histories.create!(
      delivery_status: "failed",
      delivery_method: method,
      failure_reason: reason
    )
  end
end
