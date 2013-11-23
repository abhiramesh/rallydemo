# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131123081840) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0, :null => false
    t.integer  "attempts",   :default => 0, :null => false
    t.text     "handler",                   :null => false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "eventinvites", :force => true do |t|
    t.integer  "user_id"
    t.string   "eid"
    t.string   "rsvp_status"
    t.integer  "event_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "uid"
    t.integer  "friend_id"
  end

  add_index "eventinvites", ["event_id"], :name => "index_eventinvites_on_event_id"
  add_index "eventinvites", ["friend_id"], :name => "index_eventinvites_on_friend_id"
  add_index "eventinvites", ["user_id"], :name => "index_eventinvites_on_user_id"

  create_table "events", :force => true do |t|
    t.string   "eid"
    t.integer  "creator_id"
    t.string   "all_members_count"
    t.string   "attending_count"
    t.string   "declined_count"
    t.text     "name"
    t.text     "pic_big"
    t.string   "start_time"
    t.string   "unsure_count"
    t.text     "location"
    t.text     "description"
    t.string   "source"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "friendlistmembers", :force => true do |t|
    t.integer  "friendlist_id"
    t.string   "uid"
    t.string   "flid"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "friendlistmembers", ["friendlist_id"], :name => "index_friendlistmembers_on_friendlist_id"

  create_table "friendlists", :force => true do |t|
    t.integer  "user_id"
    t.string   "count"
    t.string   "flid"
    t.string   "name"
    t.string   "ftype"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "friendlists", ["user_id"], :name => "index_friendlists_on_user_id"

  create_table "friends", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "uid"
    t.text     "pic_square"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "friends", ["user_id"], :name => "index_friends_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "uid"
    t.string   "provider"
    t.string   "oauth_token"
    t.string   "oauth_expires_at"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,  :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "profile_image"
    t.string   "authentication_token"
    t.string   "location"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
