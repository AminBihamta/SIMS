class Vendor < ApplicationRecord
  self.table_name = "vendors"
  has_many :equipments, foreign_key: "Vendor_ID"
  has_many :financial_records, foreign_key: "Vendor_ID"
  validates :Name, presence: true
  validates :Address, presence: true
  validates :Phone_Number, presence: true, numericality: { only_integer: true }
end
