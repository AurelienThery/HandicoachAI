class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :routines, dependent: :destroy
  has_many :chat_messages, dependent: :destroy

  # Validations
  validates :role, presence: true, inclusion: { in: %w[family professional] }
  validates :subscription_plan, presence: true, inclusion: { in: %w[basic pro] }

  # Role helpers
  ROLES = %w[family professional].freeze
  PLANS = %w[basic pro].freeze

  def family?
    role == "family"
  end

  def professional?
    role == "professional"
  end

  def pro_plan?
    subscription_plan == "pro"
  end

  def basic_plan?
    subscription_plan == "basic"
  end

  def subscription_active?
    return true if basic_plan?
    subscription_expires_at.present? && subscription_expires_at > Time.current
  end

  # Shared routines - routines shared with this user
  def shared_routines
    Routine.shared_with_user(id)
  end

  # All accessible routines (own + shared)
  def accessible_routines
    Routine.accessible_by_user(id)
  end
end
