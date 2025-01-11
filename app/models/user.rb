class User
  include ActiveModel::Model

  attr_accessor :id, :email, :password, :password_confirmation, :club_id, :is_supervisor

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true, if: -> { password.present? }
  validate :password_match

  def initialize(attributes = {})
    super
    fetch_additional_data if id.present?
  end

  # Move this method BEFORE the private keyword
  def is_supervisor?
    is_supervisor == true
  end

  private

  def password_match
    if password.present? && password_confirmation.present? && password != password_confirmation
      errors.add(:password_confirmation, "doesn't match Password")
    end
  end

  def fetch_additional_data
    user_data = UserData.find_by(id: id)
    if user_data
      self.club_id = user_data.club_id
      self.is_supervisor = user_data.is_supervisor
    end
  end
end
