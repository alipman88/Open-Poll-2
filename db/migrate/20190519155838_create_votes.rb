class CreateVotes < ActiveRecord::Migration[6.0]
  def change
    create_table :votes do |t|
      t.references :poll, null: false, foreign_key: true
      t.string :email, index: true
      t.string :name
      t.string :zip
      t.string :phone
      t.boolean :sms_opt_in
      t.string :source
      t.integer :referring_vote_id, index: true
      t.string :candidate_slug
      t.string :akid
      t.string :message_id
      t.integer :actionkit_id
      t.string :auth_token
      t.boolean :verified_auth_token, index: true
      t.string :ip_address, index: true
      t.string :session_cookie
      t.string :full_querystring, limit: 1023
      t.string :i, index: true
      t.string :extra_1
      t.string :extra_2
      t.string :extra_3

      t.timestamps
    end

    add_index :votes, :created_at

    create_table :responses do |t|
      t.references :vote, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.string :frst_choice, index: true
      t.string :scnd_choice, index: true
      t.string :thrd_choice, index: true

      t.timestamps
    end
  end
end
