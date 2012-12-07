class MyController < ApplicationController
  def starred_repos
    @starred_repos = authenticated_github.activity.starring.starred
  end
end
