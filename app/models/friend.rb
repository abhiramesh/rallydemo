class Friend < ActiveRecord::Base
  attr_accessible :user_id, :name, :uid, :pic_square

  belongs_to :user

  has_many :eventinvites, dependent: :destroy
  has_many :events, through: :eventinvites
  
end
