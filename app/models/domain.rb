class Domain < ApplicationRecord
  belongs_to :poll, foreign_key: :slug, primary_key: :slug
end
