class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.integer  "site_id"
      t.string   "mobile_phone",        :limit => 25
      t.string   "work_phone",          :limit => 25
      t.string   "fax",                 :limit => 25
      t.string   "website"
      t.string   "shepherd"
      t.string   "mail_group",          :limit => 1
      t.string   "description",         :limit => 25
      t.text     "activities"
      t.text     "interests"
      t.text     "music"
      t.text     "tv_shows"
      t.text     "movies"
      t.text     "books"
      t.text     "quotes"
      t.text     "about"
      t.text     "testimony"
      t.boolean  "share_mobile_phone"
      t.boolean  "share_work_phone"
      t.boolean  "share_fax"
      t.boolean  "share_email"
      t.boolean  "share_birthday"
      t.boolean  "share_activity"
      t.string   "business_name",       :limit => 100
      t.text     "business_description"
      t.string   "business_phone",      :limit => 25
      t.string   "business_email"
      t.string   "business_website"
      t.string   "business_category",   :limit => 100
      t.string   "business_address"
      t.datetime "anniversary"
      t.boolean  "get_wall_email",      :default => true
      t.boolean  "wall_enabled"
      t.boolean  "messages_enabled",    :default => true
      t.boolean  "friends_enabled",     :default => true
      t.string   "photo_file_name"
      t.string   "photo_content_type"
      t.string   "photo_fingerprint",   :limit => 50
      t.integer  "photo_file_size"
      t.datetime "photo_updated_at"
      t.string   "twitter_account",     :limit => 100
    end
    Profile.reset_column_information
    Site.each do
      Person.all do |person|
        p = person.profile
        %w(
          mobile_phone work_phone fax website shepherd mail_group
          description activities interests music tv_shows movies books quotes about testimony
          share_mobile_phone share_work_phone share_fax share_email share_birthday share_activity
          business_name business_description business_phone business_email business_website
          business_category business_address
          anniversary get_wall_email wall_enabled messages_enabled friends_enabled
          photo_file_name photo_content_type photo_fingerprint photo_file_size photo_updated_at
          twitter_account
        ).each do |attribute|
          p.attributes[attribute] = person.attributes[attribute]
        end
        p.save!
        print '.'
      end
    end
    change_table :people do |t|
      t.remove "mobile_phone"
      t.remove "work_phone"
      t.remove "fax"
      t.remove "website"
      t.remove "shepherd"
      t.remove "mail_group"
      t.remove "description"
      t.remove "activities"
      t.remove "interests"
      t.remove "music"
      t.remove "tv_shows"
      t.remove "movies"
      t.remove "books"
      t.remove "quotes"
      t.remove "about"
      t.remove "testimony"
      t.remove "share_mobile_phone"
      t.remove "share_work_phone"
      t.remove "share_fax"
      t.remove "share_email"
      t.remove "share_birthday"
      t.remove "share_activity"
      t.remove "business_name"
      t.remove "business_description"
      t.remove "business_phone"
      t.remove "business_email"
      t.remove "business_website"
      t.remove "business_category"
      t.remove "business_address"
      t.remove "anniversary"
      t.remove "get_wall_email"
      t.remove "wall_enabled"
      t.remove "friends_enabled"
      t.remove "photo_file_name"
      t.remove "photo_content_type"
      t.remove "photo_fingerprint"
      t.remove "photo_file_size"
      t.remove "photo_updated_at"
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration, "Can't roll back from a major release."
  end
end
