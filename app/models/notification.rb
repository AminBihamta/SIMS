class Notification < ApplicationRecord
  belongs_to :borrowing

  validates :message, presence: true
  validates :status, inclusion: { in: %w[pending delivered failed] }
  validates :borrowing_id, uniqueness: true
  validates :notification_type, presence: true
end