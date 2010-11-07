class Profile < ActiveRecord::Base

  belongs_to :person
  belongs_to :site

  scope_by_site_id

  attr_accessible :mobile_phone, :work_phone, :fax, :website, :activities, :interests, :music, :tv_shows, :movies, :books, :quotes, :about, :testimony, :description, :share_mobile_phone, :share_work_phone, :share_fax, :share_email, :share_birthday, :business_name, :business_description, :business_phone, :business_email, :business_website, :business_category, :anniversary, :get_wall_email, :wall_enabled, :messages_enabled, :business_address, :friends_enabled, :share_activity, :twitter_account
  attr_accessible :shepherd, :mail_group, :member, :staff, :elder, :deacon, :if => Proc.new { Person.logged_in and Person.logged_in.admin?(:edit_profiles) }

  validates_format_of :website, :allow_nil => true, :allow_blank => true, :with => /^https?\:\/\/.+/
  validates_format_of :business_website, :allow_nil => true, :allow_blank => true, :with => /^https?\:\/\/.+/
  validates_format_of :business_email, :allow_nil => true, :allow_blank => true, :with => VALID_EMAIL_ADDRESS
  validates_attachment_size :photo, :less_than => PAPERCLIP_PHOTO_MAX_SIZE
  validates_attachment_content_type :photo, :content_type => PAPERCLIP_PHOTO_CONTENT_TYPES

  inherited_attributes    :share_mobile_phone, :share_work_phone, :share_fax, :share_email, :share_birthday, :share_activity, :wall_enabled, :parent => :family
  fall_through_attributes :home_phone, :address, :address1, :address2, :city, :state, :zip, :short_zip, :mapable?, :to => :family
  fall_through_attributes :share_home_phone, :share_home_phone?, :share_address, :share_address?, :share_anniversary, :share_anniversary?, :to => :family
  sharable_attributes     :home_phone, :mobile_phone, :work_phone, :fax, :email, :birthday, :address, :anniversary, :activity

  self.skip_time_zone_conversion_for_attributes = [:birthday, :anniversary]
  self.digits_only_for_attributes = [:mobile_phone, :work_phone, :fax, :business_phone]

  def messages_enabled?
    read_attribute(:messages_enabled) and email.to_s.any?
  end

  def has_favs?
    %w(activities interests music tv_shows movies books quotes).detect do |fav|
      self.send(fav).to_s.any?
    end ? true : false
  end

  # TODO
  def update_from_params(params)
    params = HashWithIndifferentAccess.new(params) unless params.is_a? HashWithIndifferentAccess
    if params[:photo_url] and params[:photo_url].length > 7 # not just "http://"
      self.photo = params[:photo_url]
      'photo'
    elsif params[:photo]
      self.photo = params[:photo] == 'remove' ? nil : params[:photo]
      'photo'
    elsif params[:person] and (BASICS.detect { |a| params[:person][a] } or params[:family])
      self.email = params[:person].delete(:email) # no 'update' necessary for email
      self.save if changed.include?('email')
      if Person.logged_in.can_edit_profile?
        params[:family] ||= {}
        params[:family][:legacy_id] = params[:person][:legacy_family_id] if params[:person][:legacy_family_id]
        params[:person].cleanse(:birthday, :anniversary)
        update_attributes(params[:person]) && family.update_attributes(params[:family])
      else
        params[:person].delete(:family_id)
        Update.create_from_params(params, self)
        self
      end
    elsif params[:freeze] and Person.logged_in.admin?(:edit_profiles)
      if Person.logged_in == self
        self.errors.add(:base, 'Cannot freeze your own account.')
        false
      else
        toggle!(:account_frozen)
      end
    elsif params[:person] # testimony, about, favorites, etc.
      update_attributes params[:person].reject { |k, v| !EXTRAS.include?(k) }
    else
      self
    end
  end

  def show_attribute_to?(attribute, who)
    send(attribute).to_s.strip.any? and
    (not respond_to?("share_#{attribute}_with?") or
    send("share_#{attribute}_with?", who))
  end

  class << self

    def business_categories
      find_by_sql("select distinct business_category from people where business_category is not null and business_category != '' and site_id = #{Site.current.id} order by business_category").map { |p| p.business_category }
    end

  end

end
