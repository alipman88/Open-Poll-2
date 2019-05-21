class Response < ApplicationRecord
  belongs_to :vote
  belongs_to :question

  self.columns.select{ |col| [:text, :string].include? col.type }.each do |col|
    validates_length_of col.name, maximum: col.limit, too_long: "#{ col.name.upcase } too long (#{ col.limit } character max)"
  end

  attr_accessor :choices

  before_save :set_choices

  def set_choices
    self.frst_choice = choices.to_a.first.to_s[0...255]
    self.scnd_choice = choices.to_a.second.to_s[0...255]
    self.thrd_choice = choices.to_a.third.to_s[0...255]
  end
end
