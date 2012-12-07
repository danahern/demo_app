class MyController < ApplicationController
  def starred_repos
    @starred_repos = authenticated_github.activity.starring.starred
    respond_to do |format|
      format.js
      format.html
    end
  end
end
