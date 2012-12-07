class SearchController < ApplicationController
  def index
    if params[:keywords]
      @repos = github.search.repositories(keyword: params[:keywords], language: params[:language])
    end
  end
end
