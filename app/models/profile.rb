class Profile < ApplicationRecord
  include FlagBitsConcern
  include TagsConcern

  array_field :tags
  array_field :skills
  array_field :hidden_tags
  hash_field :urls, urls: true
  hash_field :contacts

  PROFILE_FLAG_APPLICANT    = 0x00000001
  PROFILE_FLAG_VOLUNTEER    = 0x00000002
  PROFILE_FLAG_FELLOW       = 0x00000004
  PROFILE_FLAG_COORDINATOR  = 0x00000008

  MAX_LENGTH_FULL_NAME = 128
  MAX_LENGTH_NICK_NAME = 50

  flag_bit :applicant
  flag_bit :volunteer
  flag_bit :fellow
  flag_bit :coordinator

  scope :volunteers, -> { where('profiles.flags & ? > 0', PROFILE_FLAG_VOLUNTEER) }
  scope :applicants, -> { where('profiles.flags & ? > 0', PROFILE_FLAG_APPLICANT) }
  scope :fellows, -> { where('profiles.flags & ? > 0', PROFILE_FLAG_FELLOW) }
  scope :coordinators, -> { where('profiles.flags & ? > 0', PROFILE_FLAG_COORDINATOR) }

  validates :full_name, presence: true, length: { maximum: MAX_LENGTH_FULL_NAME }
  validates :nick_name, presence: true, length: { maximum: MAX_LENGTH_NICK_NAME }
  validates :email, presence: true, uniqueness: true, email: true

  has_many :memberships, class_name: 'ProjectMember', dependent: :delete_all
  has_many :projects, through: :memberships
  has_many :lead_projects, foreign_key: 'owner', class_name: 'Project'

  has_many :status_reports, dependent: :delete_all
  has_and_belongs_to_many :meetings

  default_scope { order('full_name ASC') }

  def select_name
    "%-20s: %s" % [full_name, email]
  end

  def has_email?(some_email)
    return true if self.email.casecmp(some_email) == 0
    ["email", "email1", "email2", "email3"].each do |k|
      return true if self.contacts.has_key?(k) and 
        some_email.casecmp(self.contacts[k]) == 0
    end unless self.contacts.nil?
    return false
  end

  def self.for_email(email)
    # TODO: there is no :gin index on :contacts
    # Overall, I'm not happy with how we store emails. Needs refactoring
    sql = <<-SQL
      profiles.email ILIKE :email or 
      profiles.contacts::json->>'email' ILIKE :email or 
      profiles.contacts::json->>'email1' ILIKE :email or 
      profiles.contacts::json->>'email2' ILIKE :email or 
      profiles.contacts::json->>'email3' ILIKE :email
SQL
    self.where(sql,  email: email).first
  end

  def self.from_123contacts(params)
    #Parse the params for 123contactform field
    # 'controlnameXXX_YY' matches 'controlvalueXXX_YYY'
    # if value is 'yes' we assume is a checkbox
    # and we taggify the name
    tags = ''
    params.each do |k, v|
      # Search for marcked checkboxes. Value should be "yes"
      if v == 'yes'
        # Validate that the key is "controlvalueXXX_YY"
        m = /controlvalue([\d\_]+)/.match(k)
        if m
          # if matched, m[1] captured the XXX_YY part
          # Look for its corresponding 'controlvalueXXX_YY'
          choice = params["controlname#{m[1]}"]
          if choice
            # The control name is "category - option". 
            # Remove everything before first -
            mc = /\A.*?-\s*(.*)/.match(choice)
            # if there is no - the control is ignored
            if mc
              # Everything after - is captured in mc[1]
              tagval = mc[1]
              # check if there is a ' - ', ignore everything after it
              mt = /(.+)(\s-\s)/.match(tagval)
              tagval = mt[1] if mt
              # Some controls (Terms & Conditions) also match
              # all conditions up to here, so we remove them based on complexity:
              # no more than 5 words (4 spaces)
              tags += ',' + tagval if tagval.count(' ') < 4
            end
          end
        end
      end
    end

    ht = {
      flags: PROFILE_FLAG_VOLUNTEER,
      full_name: "#{params["last_name"]} #{params["first_name"]}",
      nick_name: params["first_name"],
      email: params["email"],
      contacts: {phone: params["phone"]},
      location: "#{params["city"]}, #{params["country"]}",
      description: params["description"],
      hidden_tags: [
          'NEW PROFILE',
          'FOR REVIEW',
          Date.today.to_s,
          "UID:#{params["uid"]}",
          "FID:#{params["fid"]}",
          "EID:#{params["entry_id"]}"],
      tags_string: tags
      }
    return Profile.create(ht)
  end
end
