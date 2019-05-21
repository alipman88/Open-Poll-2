class String
  def normalize
    self.to_s.parameterize.gsub(/[^a-z]/i, '')
  end
end