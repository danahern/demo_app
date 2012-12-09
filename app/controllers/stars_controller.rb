class StarsController < ApplicationController
  def create
    @user_name = params[:user_name]
    @repo_name = params[:repo_name]
    current_user.star(params[:user_name], params[:repo_name])
  end

  def destroy
    @user_name = params[:user_name]
    @repo_name = params[:repo_name]
    current_user.unstar(params[:user_name], params[:repo_name])
  end
end
