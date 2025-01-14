class Equipment < ApplicationRecord
  before_create :set_initial_status_and_stock

  self.table_name = "equipments"

  belongs_to :financial_record, foreign_key: "Financial_Record_Id", optional: true
  belongs_to :club, foreign_key: "Club_ID"
  belongs_to :vendor, foreign_key: "Vendor_ID", optional: true

  validates :Equipment_Name, presence: true
  validates :Club_ID, presence: true


  def self.group_stock(equipment_name)
    where(Equipment_Name: equipment_name).count
  end

  def self.available_stock(equipment_name)
    where(Equipment_Name: equipment_name, Status: "Available").count
  end

  def self.total_in_group(equipment_name)
    where(Equipment_Name: equipment_name).count
  end

  def self.available_in_group(equipment_name)
    where(Equipment_Name: equipment_name, Status: "Available").count
  end

  # app/models/equipment.rb
  def self.grouped_for_selection
    select('"Equipment_Name", COUNT(*) as total_count, SUM(CASE WHEN "Status" = \'Available\' THEN stock ELSE 0 END) as available_stock')
      .group('"Equipment_Name"')
      .order('"Equipment_Name"')
  end

  def update_equipment_status
    return unless saved_change_to_quantity? || saved_change_to_equipment_id?

    ActiveRecord::Base.transaction do
      restore_old_equipment_status if saved_change_to_equipment_id?
      update_new_equipment_status
    end
  end


  private

  def set_initial_status_and_stock
    self.Status ||= "Available"
    self.stock ||= 1
  end

  def restore_old_equipment_status
    old_equipment_id = equipment_id_before_last_save
    old_equipment = Equipment.find(old_equipment_id)

    borrowed_items = Equipment.where(
      Equipment_Name: old_equipment.Equipment_Name,
      Status: "Unavailable"
    ).limit(quantity_before_last_save)

    borrowed_items.update_all(Status: "Available", stock: 1)
  end

  def update_new_equipment_status
    available_items = Equipment.where(
      Equipment_Name: equipment.Equipment_Name,
      Status: "Available"
    ).limit(quantity)

    available_items.update_all(Status: "Unavailable", stock: 0)
  end
end
