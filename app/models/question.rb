class Question < ApplicationRecord
  belongs_to :poll
  default_scope { order("position IS NULL, position, id") }
end
