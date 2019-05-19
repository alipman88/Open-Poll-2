class Question < ApplicationRecord
  belongs_to :poll
  has_many :answers
  default_scope { order("position IS NULL, position, id") }
end
