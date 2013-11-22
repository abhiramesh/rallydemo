class Friend < ActiveRecord::Base
  attr_accessible :user_id, :name, :uid, :pic_square

  belongs_to :user
end
