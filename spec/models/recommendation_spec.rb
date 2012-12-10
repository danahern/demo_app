require 'spec_helper'

describe Recommendation do
  context "factories" do
    it "should be a valid recommendation" do
      @recommendation = FactoryGirl.create(:recommendation)
      @recommendation.should be_valid
    end
  end

  context "associations" do
    it { should belong_to(:user) }
  end
end