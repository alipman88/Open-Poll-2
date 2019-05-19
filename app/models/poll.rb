class Poll < ApplicationRecord
  has_one_attached :logo
  has_one_attached :share_image
  has_many :domains, foreign_key: :slug, primary_key: :slug
  has_many :questions, dependent: :delete_all
  accepts_nested_attributes_for :questions, reject_if: ->(q) { q['field_name'].blank? && q['question'].blank? }, allow_destroy: :true
  has_many :answers, through: :questions, dependent: :delete_all
  scope :with_associations, -> { with_attached_logo.with_attached_share_image.includes(questions: {answers: :image_attachment}) }
end
