class Friendlist < ActiveRecord::Base
  attr_accessible :count, :flid, :name, :type, :user_id

  belongs_to :user
  has_many :friendlistmembers, dependent: :destroy
end
