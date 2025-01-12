class Notification < ApplicationRecord
  belongs_to :borrowing
  has_many :notification_histories, dependent: :destroy

  validates :message, presence: true
  validates :status, inclusion: { in: %w[pending delivered resent] }
  validates :triggered_at, presence: true
  validates :notification_type, presence: true # Add this validation

  after_create_commit :enqueue_delivery_job_and_log_history
  after_update :log_history

  private

  def enqueue_delivery_job_and_log_history
    begin
      # Enqueue the delivery job
      NotificationDeliveryJob.perform_later(self.id)

      # Log notification history on creation
      NotificationHistory.create!(
        notification_id: self.id,
        delivery_status: "pending",
        delivery_method: "in-app",
        delivered_at: Time.current,
        failure_reason: nil
      )
      Rails.logger.debug "NotificationDeliveryJob enqueued and NotificationHistory logged successfully."
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Failed to create NotificationHistory: #{e.message}"
      raise e
    end
  end

  def log_history
    begin
      NotificationHistory.create!(
        notification_id: self.id,
        delivery_status: self.status == "delivered" ? "success" : "failed",
        delivery_method: "in-app",
        delivered_at: Time.current,
        failure_reason: self.status == "failed" ? "Delivery failed due to system error." : nil
      )
      Rails.logger.debug "Notification history updated successfully."
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Failed to log NotificationHistory on update: #{e.message}"
      raise e
    end
  end
end 