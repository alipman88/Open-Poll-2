class Poll < ApplicationRecord
  has_one_attached :logo
  has_one_attached :share_image
  has_many :domains, foreign_key: :slug, primary_key: :slug
  has_many :questions, dependent: :delete_all
  accepts_nested_attributes_for :questions, reject_if: ->(q) { q['field_name'].blank? && q['question'].blank? }, allow_destroy: :true
  has_many :answers, through: :questions, dependent: :delete_all
  scope :with_associations, -> { with_attached_logo.with_attached_share_image.includes(questions: {answers: :image_attachment}) }

  def after_action_results question_id = nil
    first_question_id = self.questions.first.try(:id)

    results = Answer.find_by_sql("
      SELECT
        a.*,
        COUNT(DISTINCT v.email) AS total,
        0 AS percent
      FROM questions q
      JOIN answers a ON q.id = a.question_id
      JOIN responses r ON q.id = r.question_id AND r.frst_choice = a.field_value
      JOIN votes v ON v.id = r.vote_id
      JOIN polls p ON p.id = v.poll_id
      LEFT JOIN votes w ON w.poll_id = v.poll_id AND w.id > v.id AND w.email = v.email
      LEFT JOIN votes x ON x.poll_id = v.poll_id AND x.id > v.id AND x.ip_address = v.ip_address
      LEFT JOIN responses s ON x.id = s.vote_id AND q.id = s.question_id AND r.frst_choice = s.frst_choice
      WHERE
        w.id IS NULL AND
        (
          (v.i IS NULL AND v.verified_auth_token AND s.id IS NULL) OR v.created_at > NOW() - INTERVAL (v.id % 30) MINUTE
        ) AND
        q.id = #{ question_id || first_question_id || 0 } AND
        a.show_on_ballot = 1 AND
        (p.end_voting_at IS NULL OR v.created_at <= p.end_voting_at)
      GROUP BY a.id
      ORDER BY total DESC
    ")

    total = results.map(&:total).inject(&:+)
    results.each { |r| r.percent = (100.0 * r.total / total).round(1) }

    return results
  end

  def cached_after_action_results **opts
    Rails.cache.fetch_async("polls/#{ self.id }/after_action_results?#{ opts.try(:to_query) }", expires_in: 10.minutes, race_condition_ttl: 1.minute) do
      self.after_action_results(opts[:question_id]).each { |a| a.image.attached? }
    end
  end

  def open?
    self.end_voting_at.nil? || Time.now <= self.end_voting_at
  end
end
