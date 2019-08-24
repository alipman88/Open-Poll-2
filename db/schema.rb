# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_19_155838) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "answers", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.string "field_value"
    t.string "caption"
    t.boolean "show_on_ballot"
    t.boolean "show_in_results"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["question_id"], name: "index_answers_on_question_id"
  end

  create_table "domains", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "domain"
    t.string "slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["domain"], name: "index_domains_on_domain"
  end

  create_table "polls", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "slug"
    t.string "title"
    t.string "subtitle"
    t.string "logo_url"
    t.datetime "end_voting_at"
    t.datetime "show_results_at"
    t.string "sms_disclaimer", limit: 511
    t.text "results_html"
    t.boolean "show_after_action_results"
    t.string "donate_url"
    t.string "twitter_message"
    t.string "index_share_title"
    t.string "index_share_description", limit: 511
    t.string "vote_share_title"
    t.string "vote_share_description", limit: 511
    t.string "promote_share_title"
    t.string "promote_share_description", limit: 511
    t.string "results_share_title"
    t.string "results_share_description", limit: 511
    t.string "after_action_email_fromline"
    t.string "after_action_email_subject"
    t.text "after_action_email_body"
    t.string "actionkit_domain"
    t.string "actionkit_page"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_polls_on_slug"
  end

  create_table "questions", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "poll_id", null: false
    t.integer "position", limit: 1
    t.string "slug"
    t.string "field_name"
    t.string "question", limit: 511
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["poll_id"], name: "index_questions_on_poll_id"
    t.index ["position"], name: "index_questions_on_position"
    t.index ["slug"], name: "index_questions_on_slug"
  end

  create_table "responses", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "vote_id", null: false
    t.bigint "question_id", null: false
    t.string "frst_choice"
    t.string "scnd_choice"
    t.string "thrd_choice"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["frst_choice"], name: "index_responses_on_frst_choice"
    t.index ["question_id"], name: "index_responses_on_question_id"
    t.index ["scnd_choice"], name: "index_responses_on_scnd_choice"
    t.index ["thrd_choice"], name: "index_responses_on_thrd_choice"
    t.index ["vote_id"], name: "index_responses_on_vote_id"
  end

  create_table "votes", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.bigint "poll_id", null: false
    t.string "email"
    t.string "name"
    t.string "zip"
    t.string "phone"
    t.boolean "sms_opt_in"
    t.string "source"
    t.integer "referring_vote_id"
    t.string "candidate_slug"
    t.string "akid"
    t.string "message_id"
    t.integer "actionkit_id"
    t.string "auth_token"
    t.boolean "verified_auth_token"
    t.string "ip_address"
    t.string "session_cookie"
    t.string "full_querystring", limit: 1023
    t.string "i"
    t.string "extra_1"
    t.string "extra_2"
    t.string "extra_3"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "index_votes_on_created_at"
    t.index ["email"], name: "index_votes_on_email"
    t.index ["i"], name: "index_votes_on_i"
    t.index ["ip_address"], name: "index_votes_on_ip_address"
    t.index ["poll_id"], name: "index_votes_on_poll_id"
    t.index ["referring_vote_id"], name: "index_votes_on_referring_vote_id"
    t.index ["verified_auth_token"], name: "index_votes_on_verified_auth_token"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "answers", "questions"
  add_foreign_key "questions", "polls"
  add_foreign_key "responses", "questions"
  add_foreign_key "responses", "votes"
  add_foreign_key "votes", "polls"
end
