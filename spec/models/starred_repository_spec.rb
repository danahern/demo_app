require 'spec_helper'

describe StarredRepository do
  context "factories" do
    it "should be a valid starred repository" do
      @starred_respository = FactoryGirl.create(:starred_repository)
      @starred_respository.should be_valid
    end
  end

  context "associations" do
    it { should belong_to(:user) }
  end
end