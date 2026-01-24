class Routine < ApplicationRecord
  belongs_to :user
  has_many :chat_messages, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :visibility, presence: true, inclusion: { in: %w[private shared] }

  # Scopes
  scope :owned_by, ->(user_id) { where(user_id: user_id) }
  scope :shared, -> { where(visibility: "shared") }
  scope :private_only, -> { where(visibility: "private") }

  # Serialize shared_with_ids as array
  serialize :shared_with_ids, coder: JSON

  # Parse steps as JSON array
  serialize :steps, coder: JSON

  # Class methods for collaborative routines
  def self.shared_with_user(user_id)
    where(visibility: "shared").select do |routine|
      routine.shared_with_user?(user_id)
    end
  end

  def self.accessible_by_user(user_id)
    # Owned routines + routines shared with user
    owned = where(user_id: user_id)
    shared = shared_with_user(user_id)
    (owned.to_a + shared).uniq
  end

  # Instance methods
  def shared_with_user?(user_id)
    return false unless visibility == "shared"
    return true if self.user_id == user_id
    ids = shared_with_ids || []
    ids.include?(user_id.to_i) || ids.include?(user_id.to_s)
  end

  def share_with(user)
    return if user.id == self.user_id
    self.shared_with_ids ||= []
    self.shared_with_ids << user.id unless shared_with_ids.include?(user.id)
    self.visibility = "shared"
    save
  end

  def unshare_with(user)
    return unless shared_with_ids
    self.shared_with_ids.delete(user.id)
    self.visibility = "private" if shared_with_ids.empty?
    save
  end

  def steps_array
    steps.is_a?(Array) ? steps : []
  end

  def add_step(step_content)
    self.steps ||= []
    self.steps << step_content
    save
  end
end
