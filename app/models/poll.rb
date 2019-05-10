class Poll < ApplicationRecord
  has_one_attached :logo
  has_one_attached :share_image
end
