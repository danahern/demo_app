class RecommendationEngine
  @queue = :recommendations
  def perform(user_id)
    @user = User.find(user_id)
    @user.create_or_update_starred_repositories!
  end
end