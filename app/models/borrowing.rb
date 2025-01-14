class Borrowing < ApplicationRecord
  def status
    read_attribute(:status)&.to_sym # Convert the database value to a symbol
  end
  
  # Custom setter for PostgreSQL enum
  def status=(value)
    write_attribute(:status, value.to_s) # Convert the symbol or string to a string
  end

  # Scopes for easy querying
  scope :borrowed, -> { where(status: 'borrowed').order(borrow_date: :desc) }
  scope :returned, -> { where(status: 'returned') }
  scope :overdue, -> { where(status: 'overdue').order(due_date: :asc) }
  scope :needs_overdue_update, -> {
    where("due_date < ? AND status = ?", Time.current, 'borrowed')
  }

  scope :needs_notification, -> {
    where(status: 'overdue')
      .where.not(id: Notification.select(:borrowing_id))
  }


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
  after_save :check_and_generate_notification


  def reduce_stock_on_borrow
    return unless equipment
  
    available_items = Equipment.where(
      Equipment_Name: equipment.Equipment_Name,
      Status: 'Available'
    ).limit(quantity)
  
    if available_items.count < quantity
      raise "Not enough available items"
    end
  
    available_items.each do |item|
      item.update!(Status: 'Unavailable', stock: 0)
    end
  end
  
  def restore_stock_on_destroy
    return unless equipment
  
    borrowed_items = Equipment.where(
      Equipment_Name: equipment.Equipment_Name,
      Status: 'Unavailable'
    ).limit(quantity)
  
    borrowed_items.each do |item|
      item.update!(Status: 'Available', stock: 1)
    end
  end
  

  def pic_info
    user_data = UserData.find_by(club_id: self.club_id, is_supervisor: false)
    club = Club.find_by(Club_ID: self.club_id)
    
    if user_data && club
      if !user_data.is_supervisor
        "PIC of #{club.Club_Name}"
      else
        "No PIC assigned for #{club.Club_Name}"
      end
    else
      "Club info not found"
    end
  rescue => e
    Rails.logger.error "Error in pic_info: #{e.message}"
    "Error fetching club info"
  end

  private

  def check_and_generate_notification
    if status.to_s == 'overdue' && !notifications.exists?
      GenerateNotificationJob.perform_now(id)
    end
  end

  def check_and_update_status
    if due_date_changed? || will_save_change_to_due_date?
      Rails.logger.info "Due date changed from #{due_date_was} to #{due_date}"
      Rails.logger.info "Current time: #{Time.current}"
      Rails.logger.info "Current status: #{status}"
      
      # Force update status regardless of current status
      if due_date.present? && due_date < Time.current
        write_attribute(:status, 'overdue')
      else
        write_attribute(:status, 'borrowed')
      end
      
      Rails.logger.info "New status set to: #{read_attribute(:status)}"
    end
  end

  def handle_overdue_status
    if due_date_changed? || saved_change_to_status?
      if due_date < Time.current
        generate_overdue_notification unless notifications.exists?
      end
    end
  end


  def generate_overdue_notification
    days_overdue = (Date.current - due_date).to_i
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