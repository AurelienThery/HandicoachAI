class ChatMessage < ApplicationRecord
  include ActionView::RecordIdentifier
  include Turbo::Broadcastable

  belongs_to :user
  belongs_to :routine, optional: true

  # Validations
  validates :content, presence: true
  validates :role, presence: true, inclusion: { in: %w[user assistant system] }

  # Scopes
  scope :ordered, -> { order(created_at: :asc) }
  scope :recent, -> { order(created_at: :desc).limit(50) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :for_routine, ->(routine_id) { where(routine_id: routine_id) }
end
