class MyController < ApplicationController
  def starred_repos
    current_user.create_or_update_starred_repositories!
    @starred_repos = current_user.starred_repositories
    respond_to do |format|
      format.js
      format.html
    end
  end

  def recommendations
    if current_user.needs_recommendations?
      @generating_new_recommendations
      current_user.update_column(:recommendations_generated_at, Time.now)
      Resque.enqueue(RecommendationEngine, current_user.id)
    end
    @recommendations = current_user.recommendations
    respond_to do |format|
      format.js
      format.html
    end
  end
end
