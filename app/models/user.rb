class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :registerable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name
  # attr_accessible :title, :body

  def self.find_for_github_oauth(auth, signed_in_resource=nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first
    unless user
      user = User.create({name:auth.extra.raw_info.name, provider:auth.provider, uid:auth.uid, token:auth.credentials.token, login:auth.extra.raw_info.name}, without_protection: true)
    end
    user
  end
end
