class Decision < ApplicationRecord
  validates :reason, presence: true, length: { maximum: 65_535 }

  belongs_to :moderator, class_name: 'User', optional: false

  has_many :reports, dependent: :nullify

  enum kind: {
    cleared: 0,
    favor: 1
  }

  after_create :create_event

  def create_event
    case kind
    when 'cleared'
      Event::ClearedDecision.create(event_parameters)
    else
      Event::FavoredDecision.create(event_parameters)
    end
  end

  def event_parameters
    { id: id, moderator_id: moderator.id, reason: reason }
  end
end

# == Schema Information
#
# Table name: decisions
#
#  id           :bigint           not null, primary key
#  kind         :integer          default("cleared")
#  reason       :text(65535)      not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  moderator_id :integer          not null, indexed
#
# Indexes
#
#  index_decisions_on_moderator_id  (moderator_id)
#
# Foreign Keys
#
#  fk_rails_...  (moderator_id => users.id)
#