# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_04_18_081646) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "comments", force: :cascade do |t|
    t.text "text"
    t.bigint "user_id", null: false
    t.bigint "update_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["update_id"], name: "index_comments_on_update_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "project_follows", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_follows_on_project_id"
    t.index ["user_id", "project_id"], name: "index_project_follows_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_project_follows_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "readme_link"
    t.string "demo_link"
    t.string "repo_link"
    t.integer "rating"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "banner"
    t.string "category"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "updates", force: :cascade do |t|
    t.text "text"
    t.string "attachment"
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_updates_on_project_id"
    t.index ["user_id"], name: "index_updates_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "slack_id"
    t.string "email"
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.string "display_name"
    t.string "timezone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "avatar"
    t.boolean "has_commented", default: false
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
    t.text "explanation", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_votes_on_project_id"
    t.index ["user_id", "project_id"], name: "index_votes_on_user_id_and_project_id", unique: true
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "comments", "updates"
  add_foreign_key "comments", "users"
  add_foreign_key "project_follows", "projects"
  add_foreign_key "project_follows", "users"
  add_foreign_key "projects", "users"
  add_foreign_key "updates", "projects"
  add_foreign_key "updates", "users"
  add_foreign_key "votes", "projects"
  add_foreign_key "votes", "users"
end
