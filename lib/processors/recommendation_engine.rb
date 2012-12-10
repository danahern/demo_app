class RecommendationEngine
  @queue = :recommendations
  class << self
    def perform(user_id)
      @user = User.find(user_id)
      @user.create_or_update_starred_repositories!
      @github = Github.new(oauth_token: @user.token)
      @popular_star_gazers = star_gazers(@user, @github, 10)
      @all_repositories = popular_star_gazers_repositories(@popular_star_gazers, @github)
      @recommended_repositories = recommended_repositories(@user, @all_repositories)
      create_recommendations!(@user, @recommended_repositories)
    end

    def star_gazers(user, github, count)
      star_gazers = []
      user.starred_repositories.each do |repo|
        local_star_gazers = github.activity.starring.list(repo.owner, repo.repo_name, per_page: 1000)
        star_gazers << local_star_gazers.map(&:login)
      end
      popular_star_gazers = star_gazers.flatten.reject{|sg| sg == user.login}.group_by(&:to_s).map{|k,v| [k, v.length]}.sort_by{|a,b| b}.reverse
      popular_star_gazers[0..count]
    end

    def popular_star_gazers_repositories(popular_star_gazers, github)
      all_repositories = []
      popular_star_gazers.each do |login, count|
        recommended = github.activity.starring.starred(user: login, per_page: 1000)
        all_repositories << recommended
      end
      all_repositories = all_repositories.flatten
      all_repositories
    end

    def recommended_repositories(user, all_repositories)
      recommended_repositories = []
      all_repositories.each do |repo|
        if appears_more_than_once(all_repositories, repo) && not_currently_starred(user, repo) && not_users_repo(user, repo) && not_in_recommended_repositories(recommended_repositories, repo)
          recommended_repositories << repo
        end
      end
      recommended_repositories
    end

    def appears_more_than_once(all_repositories, repo)
      all_repositories.select{|r| r.full_name == repo.full_name}.size > 1
    end

    def not_currently_starred(user, repo)
      user.starred_repositories.map(&:full_name).exclude?(repo.full_name)
    end

    def not_users_repo(user, repo)
      repo.owner.login != user.login
    end

    def not_in_recommended_repositories(recommended_repositories, repo)
      !recommended_repositories.any?{|r| r.full_name == repo.full_name}
    end

    def create_recommendations!(user, recommended_repositories)
      user.recommendations.destroy_all
      recommended_repositories.each do |rec_repo|
        user.recommendations.create({full_name: rec_repo.full_name, repo_name: rec_repo.name, owner: rec_repo.owner.login, owner_avatar_url: rec_repo.owner.avatar_url, description: rec_repo.description, language: rec_repo.language, homepage: rec_repo.homepage, html_url: rec_repo.html_url}, without_protection: true)
      end
    end
  end
end