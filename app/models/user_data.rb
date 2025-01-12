class UserData < ApplicationRecord
  has_many :borrowings, foreign_key: "pic_id"

  validates :id, presence: true
  self.table_name = "user_data"

  belongs_to :user, foreign_key: :id
  belongs_to :club, foreign_key: :club_id
end
