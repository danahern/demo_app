class MyController < ApplicationController
  def starred_repos
    current_user.create_or_update_starred_repositories!
    @starred_repos = current_user.starred_repositories
    respond_to do |format|
      format.js
      format.html
    end
  end
end
