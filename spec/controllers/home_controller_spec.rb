require 'spec_helper'

describe HomeController do
  context "index" do
    it "should return the homepage" do
      get :index
    end
  end
end