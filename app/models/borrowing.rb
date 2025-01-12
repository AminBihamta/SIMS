# app/models/borrowing.rb
class Borrowing < ApplicationRecord

  def status
    read_attribute(:status)&.to_sym # Convert the database value to a symbol
  end
  # Custom setter for PostgreSQL enum
  def status=(value)
    write_attribute(:status, value.to_s) # Convert the symbol or string to a string
  end
  # Scopes for easy querying
  scope :borrowed, -> { where(status: "borrowed") }
  scope :returned, -> { where(status: "returned") }
  scope :overdue, -> { where(status: "overdue") }
  belongs_to :equipment, foreign_key: "equipment_id", class_name: "Equipment"
  belongs_to :club, foreign_key: "club_id", class_name: "Club"
  belongs_to :person_in_charge, class_name: "UserData", foreign_key: "pic_id", optional: true
  has_many :notifications, dependent: :destroy

  validates :equipment_id, :club_id, :borrow_date, :due_date, :quantity, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  
  # Callbacks
  before_create :reduce_stock_on_borrow
  before_destroy :restore_stock_on_destroy
  after_update :handle_overdue_status
  before_save :check_and_update_status


  private

  def check_and_update_status
    if due_date < Date.today && status == "borrowed"
      self.status = "overdue"
    end
  end

  def reduce_stock_on_borrow
    if equipment
      new_stock = equipment.stock - quantity
      raise ActiveRecord::RecordInvalid, "Insufficient stock for borrowing" if new_stock.negative?

      equipment.update!(stock: new_stock)
    end
  end

  def restore_stock_on_destroy
    equipment.update!(stock: equipment.stock + quantity) if equipment
  end

  def handle_overdue_status
    if saved_change_to_status? && status == "overdue"
      generate_overdue_notification
    end
  end

  def generate_overdue_notification
    days_overdue = (Date.today - due_date).to_i
    notification = notifications.create!(
      notification_type: "Overdue",
      message: generate_overdue_message(days_overdue),
      status: "pending",
      triggered_at: Time.current
    )
    
    # Create the initial history record
    notification.notification_histories.create!(
      message: notification.message,
      status: "pending",
      triggered_at: Time.current
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create overdue notification: #{e.message}"
  end

  def generate_overdue_message(days_overdue)
    "OVERDUE ALERT: #{equipment.name} borrowed by #{club.name} is #{days_overdue} #{'day'.pluralize(days_overdue)} overdue. " \
    "Due date was #{due_date.strftime('%B %d, %Y')}. " \
    "Please contact #{person_in_charge&.full_name || 'PIC'} immediately."
  end
end