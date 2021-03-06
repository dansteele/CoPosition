class User < ActiveRecord::Base
  extend FriendlyId
  include ApprovalMethods
  include SlackNotifiable

  acts_as_token_authenticatable

  friendly_id :username, use: [:slugged, :finders]

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, 
         :authentication_keys => { username: false, email: true }

  validates :username, uniqueness: true, 
                       allow_blank: true, 
                       format: { with: /\A[-a-zA-Z_]+\z/, 
                         message: "only allows letters, underscores and dashes" }

  has_many :devices, dependent: :destroy
  has_many :checkins, through: :devices
  has_many :requests
  has_many :approvals, dependent: :destroy
  has_many :developers, -> { where "status = 'accepted'" }, through: :approvals, source: :approvable, :source_type => "Developer"
  has_many :friends, -> { where "status = 'accepted'" }, through: :approvals, source: :approvable, :source_type => "User"
  has_many :pending_friends, -> { where "status = 'pending'" }, :through => :approvals, source: :approvable, :source_type => "User"
  has_many :friend_requests, -> { where "status = 'requested'" }, :through => :approvals, source: :approvable, :source_type => "User"
  has_many :developer_requests, -> { where "status = 'developer-requested'" }, :through => :approvals, source: :approvable, :source_type => "Developer"
  has_many :permissions, :as => :permissible, dependent: :destroy
  has_many :permitted_devices, through: :permissions, source: :permissible, :source_type => "Device"

  ## Pathing

  def url_id
    username.empty? ? id : username.downcase
  end

  ## Approvals

  def approved_developer?(dev)
    developers.include? dev
  end

  def has_request_from(approvable)
    friend_requests.include?(approvable) || developer_requests.include?(approvable)
  end

  ## Devices

  def approve_devices(permissible)
    if permissible.class.to_s == 'Developer'
      devices.each do |device|
        device.developers << permissible unless device.developers.include? permissible
      end
    else
      devices.each do |device|
        device.permitted_users << permissible unless device.permitted_users.include? permissible
      end
    end
  end

  ################

  ## Checkins

  def last_checkin
    checkins.sort_by(&:created_at).last
  end

  ##############

  def slack_message
    "A new user has registered, there are now #{User.count} users."
  end

  def notifications
    @notes ||= begin
      @notes = []
      if pending_approvals.present?
        @notes << {
          notification: {
              msg: "You have #{pending_approvals.count} pending approvals",
              link_path: "user_approvals_path"
            }
          }
      end
      @notes
    end
  end

end