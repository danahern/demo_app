class SearchController < ApplicationController
  skip_before_filter :authenticate_user!
  def index
    if params[:keywords]
      @repos = github.search.repositories(keyword: Rack::Utils.escape(params[:keywords]), language: params[:language])
      if user_signed_in?
        @starred_repos = current_user.starred_repositories
      end
    end
  end
end
