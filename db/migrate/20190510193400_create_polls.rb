class CreatePolls < ActiveRecord::Migration[6.0]
  def change
    create_table :polls do |t|
      t.string :slug, index: true
      t.string :title
      t.string :subtitle
      t.string :logo_url
      t.datetime :end_voting_at
      t.boolean :show_results
      t.string :sms_disclaimer, limit: 511
      t.text :results_html
      t.boolean :show_after_action_results
      t.string :donate_url
      t.string :twitter_message
      t.string :index_share_title
      t.string :index_share_description, limit: 511
      t.string :vote_share_title
      t.string :vote_share_description, limit: 511
      t.string :promote_share_title
      t.string :promote_share_description, limit: 511
      t.string :results_share_title
      t.string :results_share_description, limit: 511
      t.string :after_action_email_fromline
      t.string :after_action_email_subject
      t.text :after_action_email_body
      t.string :actionkit_domain
      t.string :actionkit_page

      t.timestamps
    end
  end
end
