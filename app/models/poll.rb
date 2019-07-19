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

  def crosstabs **opts
    question_id_1 = opts[:question_id_1] || self.questions.try(:first ).try(:id)
    question_id_2 = opts[:question_id_2] || self.questions.try(:second).try(:id)

    results = ActiveRecord::Base.connection_pool.with_connection { |con| con.exec_query("
      SELECT
        CASE
        WHEN a11.show_in_results THEN a11.id
        WHEN r1.frst_choice IS NULL OR r1.frst_choice = '' THEN NULL
        ELSE '0' END AS pry_frst_choice,
        CASE
        WHEN a12.show_in_results THEN a12.id
        WHEN r1.scnd_choice IS NULL OR r1.scnd_choice = '' THEN NULL
        ELSE '0' END AS pry_scnd_choice,
        CASE
        WHEN a13.show_in_results THEN a13.id
        WHEN r1.thrd_choice IS NULL OR r1.thrd_choice = '' THEN NULL
        ELSE '0' END AS pry_thrd_choice,
        CASE
        WHEN a21.show_in_results THEN a21.id
        WHEN r2.frst_choice IS NULL OR r2.frst_choice = '' THEN NULL
        ELSE '0' END AS xtb_frst_choice,
        CASE
        WHEN a22.show_in_results THEN a22.id
        WHEN r2.scnd_choice IS NULL OR r2.scnd_choice = '' THEN NULL
        ELSE '0' END AS xtb_scnd_choice,
        CASE
        WHEN a23.show_in_results THEN a23.id
        WHEN r2.thrd_choice IS NULL OR r2.thrd_choice = '' THEN NULL
        ELSE '0' END AS xtb_thrd_choice,
        COUNT(DISTINCT v.email) AS total
      FROM polls p
      JOIN votes v ON p.id = v.poll_id
      JOIN questions q1 ON p.id = q1.poll_id
      JOIN questions q2 ON p.id = q2.poll_id
      JOIN responses r1 ON v.id = r1.vote_id AND q1.id = r1.question_id
      JOIN responses r2 ON v.id = r2.vote_id AND q2.id = r2.question_id
      LEFT JOIN answers a11 ON q1.id = a11.question_id AND r1.frst_choice = a11.field_value
      LEFT JOIN answers a12 ON q1.id = a12.question_id AND r1.scnd_choice = a12.field_value
      LEFT JOIN answers a13 ON q1.id = a13.question_id AND r1.thrd_choice = a13.field_value
      LEFT JOIN answers a21 ON q2.id = a21.question_id AND r2.frst_choice = a21.field_value
      LEFT JOIN answers a22 ON q2.id = a22.question_id AND r2.scnd_choice = a22.field_value
      LEFT JOIN answers a23 ON q2.id = a23.question_id AND r2.thrd_choice = a23.field_value
      LEFT JOIN votes w ON w.poll_id = v.poll_id AND w.id > v.id AND w.email = v.email
      WHERE
        p.id = #{ self.id } AND
        (p.end_voting_at IS NULL OR v.created_at <= p.end_voting_at) AND
        w.id IS NULL AND
        v.i IS NULL AND v.verified_auth_token AND
        q1.id = #{ question_id_1 || 0 } AND q2.id = #{ question_id_2 || 0 }
        #{ opts[:extra_1] ? '' : '--' } AND v.extra_1 = '#{ opts[:extra_1] }'
      GROUP BY pry_frst_choice, pry_scnd_choice, pry_thrd_choice, xtb_frst_choice, xtb_scnd_choice, xtb_thrd_choice
    ") }

    _total = "total".freeze
    total = results.inject(0.0) { |t, row| t + row[_total] }
    lookup = {}
    json = "["

    # The following code produces a chunk of JSON. It could be performed via a one-liner .map function,
    # but to avoid memory bloat we'll do it manually with frozen strings.

    pry_frst_choice = 'pry_frst_choice'.freeze
    pry_scnd_choice = 'pry_scnd_choice'.freeze
    pry_thrd_choice = 'pry_thrd_choice'.freeze
    xtb_frst_choice = 'xtb_frst_choice'.freeze
    xtb_scnd_choice = 'xtb_scnd_choice'.freeze
    xtb_thrd_choice = 'xtb_thrd_choice'.freeze
    comma = ",".freeze
    _p = "{p:[".freeze
    _c = "],c:[".freeze
    _t = "],t:".freeze
    _z = "},".freeze
    _f = "%.10f".freeze

    results.each do |row|
      lookup[row[pry_frst_choice]] ||= row[pry_frst_choice].freeze
      lookup[row[pry_scnd_choice]] ||= row[pry_scnd_choice].freeze
      lookup[row[pry_thrd_choice]] ||= row[pry_thrd_choice].freeze
      lookup[row[xtb_frst_choice]] ||= row[xtb_frst_choice].freeze
      lookup[row[xtb_scnd_choice]] ||= row[xtb_scnd_choice].freeze
      lookup[row[xtb_thrd_choice]] ||= row[xtb_thrd_choice].freeze
      json << _p

      [pry_frst_choice, pry_scnd_choice, pry_thrd_choice].each do |col|
        if row[col]
          json << lookup[row[col]]
          json << comma
        end
      end

      json << _c

      [xtb_frst_choice, xtb_scnd_choice, xtb_thrd_choice].each do |col|
        if row[col]
          json << lookup[row[col]]
          json << comma
        end
      end

      json << _t
      json << sprintf(_f, row[_total] / total).freeze
      json << _z
    end

    json << "]"

    json.freeze
  end

  def cached_crosstabs **opts
    # Rails.cache.delete "polls/#{ self.id }/crosstabs?#{ opts.try(:to_query) }"
    Rails.cache.fetch_async("polls/#{ self.id }/crosstabs?#{ opts.try(:to_query) }", expires_in: 1.hour, race_condition_ttl: 1.minute) do
      self.crosstabs(opts)
    end
  end

  def open?
    self.end_voting_at.nil? || Time.now <= self.end_voting_at
  end
end
