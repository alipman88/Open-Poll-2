class Answer < ApplicationRecord
  belongs_to :question
  has_one_attached :image
end
