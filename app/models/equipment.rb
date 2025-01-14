class Equipment < ApplicationRecord
  before_create :set_initial_status_and_stock

  self.table_name = "equipments"

  belongs_to :financial_record, foreign_key: "Financial_Record_Id"
  belongs_to :club, foreign_key: "Club_ID"
  belongs_to :vendor, foreign_key: "Vendor_ID", optional: true

  validates :Equipment_Name, presence: true
  validates :Financial_Record_Id, presence: true
  validates :Club_ID, presence: true


  def self.group_stock(equipment_name)
    where(Equipment_Name: equipment_name).count
  end

  def self.available_stock(equipment_name)
    where(Equipment_Name: equipment_name, Status: 'Available').count
  end

  def self.total_in_group(equipment_name)
    where(Equipment_Name: equipment_name).count
  end

  def self.available_in_group(equipment_name)
    where(Equipment_Name: equipment_name, Status: 'Available').count
  end


  private

  def set_initial_status_and_stock
    self.Status ||= 'Available'
    self.stock ||= 1
  end
end