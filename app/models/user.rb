class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :omniauthable, :registerable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name
  # attr_accessible :title, :body

  has_many :starred_repositories

  def self.find_for_github_oauth(auth, signed_in_resource=nil)
    user = User.where(provider: auth.provider, uid: auth.uid).first
    unless user
      user = User.create({name: auth.extra.raw_info.name, provider: auth.provider, uid: auth.uid, token: auth.credentials.token, login: auth.extra.raw_info.name}, without_protection: true)
    else
      user.update_attributes({token: auth.credentials.token}, without_protection: true)
    end
    user
  end

  def create_or_update_starred_repositories!
    starred_repos = Github.new(oauth_token: self.token).activity.starring.starred(per_page: 1000)
    starred_repos.each do |starred|
      repo = self.starred_repositories.where(full_name: starred.full_name).first_or_create
      repo.update_attributes({repo_name: starred.name, owner: starred.owner.login, owner_avatar_url: starred.owner.avatar_url, description: starred.description, language: starred.language, homepage: starred.homepage, html_url: starred.html_url}, without_protection: true)
    end
    self.starred_repositories.where("full_name not in (?)", starred_repos.map(&:full_name)).destroy_all
  end

  def star(user, repo)
    Github.new(oauth_token: self.token).activity.starring.star(user, repo)
    create_or_update_starred_repositories!
  end

  def unstar(user, repo)
    Github.new(oauth_token: self.token).activity.starring.unstar(user, repo)
    create_or_update_starred_repositories!
  end
end
