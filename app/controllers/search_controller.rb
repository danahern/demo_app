class SearchController < ApplicationController
  def index
    if params[:keywords]
      @repos = github.search.repositories(keyword: params[:keywords], language: params[:language])
    end
  end

  def users
    if params[:user_name]
      @starred = github.activity.starring.starred(user: params[:user_name])
    end
  end
end
