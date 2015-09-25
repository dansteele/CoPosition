class User < ActiveRecord::Base
  include ApprovalMethods

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable #:omniauthable

  has_many :devices
  has_many :approvals
  has_many :developers, through: :approvals

  def notifications
    x = []
    if pending_approvals.present?
      x << {
        notification: {
            msg: "You have #{pending_approvals.count} pending approvals",
            link_path: "users_approvals_path"
          }
        }
    end
    x
  end

end