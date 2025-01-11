class FinancialRecord < ApplicationRecord
  self.table_name = "financial_records"

  belongs_to :club, class_name: "Club", foreign_key: "Club_ID"
  belongs_to :vendor, class_name: "Vendor", foreign_key: "Vendor_ID"

  has_many :equipments
end
