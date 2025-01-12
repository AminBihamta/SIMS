class NotificationHistory < ApplicationRecord
  belongs_to :notification

  validates :message, presence: true
  validates :status, presence: true
  validates :triggered_at, presence: true
end
