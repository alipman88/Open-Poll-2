class Vote < ApplicationRecord
  belongs_to :poll
  has_many :responses
  accepts_nested_attributes_for :responses

  default_scope { Vote.eager_load( {responses: {question: :answers}} ).order("votes.id, questions.position IS NULL, questions.position, questions.id") }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_ZIP_REGEX = /\A\d{5}(-\d{4})?\z/
  VALID_NAME_REGEX = /\S+\s+\S+/
  VALID_PHONE_REGEX = /(\d.*){10,}/

  before_validation :strip_fields

  def strip_fields
    self.email = self.email.to_s.strip
    self.name = self.name.to_s.strip
    self.zip = self.zip.to_s.strip
    self.phone = self.phone.to_s.strip
  end

  validates :email, presence: { message: "Email address required"}, format: { with: VALID_EMAIL_REGEX, message: "Invalid email address" }
  validates :name, format: { with: VALID_NAME_REGEX, message: "First and last name required" }
  validates :zip, format: { with: VALID_ZIP_REGEX, message: "Five digit zip code required" }
  validates :phone, format: { with: VALID_PHONE_REGEX, message: "Please enter a ten-digit phone", allow_blank: true }
  
  self.columns.select{ |col| [:text, :string].include? col.type }.each do |col|
    validates_length_of col.name, maximum: col.limit, too_long: "#{ col.name.upcase } too long (#{ col.limit } character max)"
  end

  # Vote ID hashing
  def self.dec_to_b62 int
    encoding = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a

    return '0' if int == 0

    res = ''
    while int > 0
      d = int % 62
      res << encoding[d]
      int -= d
      int /= 62
    end

    return res.reverse
  end

  def self.b62_to_dec str
    encoding = ('0'..'9').to_a + ('a'..'z').to_a + ('A'..'Z').to_a

    res = 0

    for char in str.chars
      res *= 62
      res += encoding.index(char)
    end

    return res
  end

  def self.encode_hash cleartext
    hash = Digest::SHA256.base64digest(ENV['VOTE_HASH_SECRET'] + '-' + cleartext.to_s).gsub(/[\+\/]/, '+' => '-', '/' => '_').gsub(/=+$/, '').first(6)
    return cleartext.to_s + '-' + hash
  end

  def self.valid_hash? hash
    if hash.blank?
      return false
    else
      cleartext = hash.partition('-').first
      urlsafe_digest = Digest::SHA256.base64digest(ENV['VOTE_HASH_SECRET'] + '-' + cleartext.to_s).gsub(/[\+\/]/, '+' => '-', '/' => '_').gsub(/=+$/, '').first(6)
      return hash.partition('-').last == urlsafe_digest
    end
  end

  def self.find_by_hash hash
    if Vote.valid_hash? hash
      vote_id = Vote.b62_to_dec(hash.split('-')[0])
      return Vote.find_by id: vote_id
    end
  end

  def self.find_by_hash! hash
    return Vote.find_by_hash(hash) || Vote.find_by!(id: 0)
  end

  def hash
    Vote.encode_hash(Vote.dec_to_b62(self.id))
  end

  # Helpers
  def share_url(domain, slug)
    [domain, slug, 's', self.hash].reject(&:blank?).join('/')
  end

  def twitter_url(domain, slug)
    "https://twitter.com/intent/tweet?url=#{ ERB::Util.url_encode self.share_url(domain, slug) }&text=#{ ERB::Util.url_encode self.poll.twitter_message }"
  end

  def facebook_url(domain, slug)
    "https://www.facebook.com/sharer/sharer.php?u=#{self.share_url(domain, slug)}"
  end

  def top_choice
    r = self.responses.first

    if r
      return [r.frst_choice, r.scnd_choice, r.thrd_choice].reject(&:blank?).first
    end
  end

  def rank
    results = self.poll.cached_after_action_results
    votes = results.select{ |r| r.field_value == self.top_choice }.first.try(:total) || 0
    (results.select{ |r| r.total > votes }.length + 1).ordinalize
  end

  def sync_to_actionkit
    if self.poll.actionkit_domain.present? && self.poll.actionkit_page.present?
      actionfields = self.responses.map{ |r| {
        "action_#{ r.question.field_name.parameterize.gsub('-', '_') }_frst_choice" => r.frst_choice.to_s,
        "action_#{ r.question.field_name.parameterize.gsub('-', '_') }_scnd_choice" => r.scnd_choice.to_s,
        "action_#{ r.question.field_name.parameterize.gsub('-', '_') }_thrd_choice" => r.thrd_choice.to_s
      } }.reduce({}, :merge)

      body = {
        page: self.poll.actionkit_page,
        name: self.name,
        email: self.email,
        zip: self.zip,
        phone: self.phone,
        action_sms_opt_in: self.sms_opt_in,
        action_provided_mobile_phone: self.phone,
        action_vote_id: self.id,
        referring_akid: self.akid,
        source: self.source
      }.merge(actionfields)

      result = HTTParty.get("https://#{ self.poll.actionkit_domain }/act?#{ body.to_query }")
      action_id = CGI::parse(result.request.last_uri.to_s.split('?')[1])['action_id'][0]
      self.update_column(:actionkit_id, action_id)

      return action_id
    end
  end
end
