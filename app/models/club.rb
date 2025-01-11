class Club < ApplicationRecord
  self.table_name = "clubs"

  belongs_to :parent_club, class_name: "Club", optional: true, foreign_key: "Parent_Club"
  has_many :children, class_name: "Club", foreign_key: "Parent_Club", dependent: :nullify
  has_many :equipments, foreign_key: "Club_ID"
  has_many :financial_records, foreign_key: "Club_ID"

  validates :Club_Name, presence: true
  validates :Budget, numericality: { greater_than_or_equal_to: 0 }
end
