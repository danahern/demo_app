require 'spec_helper'

describe User do
  def check_user(user)
    user.should be_present
    user.name.should == "Dan Example"
    user.provider.should == "github"
    user.login.should == "example"
  end

  def default_starred_repositories
    FactoryGirl.create(:starred_repository, full_name: "example/test", user: user)
    FactoryGirl.create(:starred_repository, full_name: "example/demo", user: user)
  end

  context "factories" do
    it "should be a valid user" do
      @user = FactoryGirl.create(:user)
      @user.should be_valid
    end
  end

  context "associations" do
    it { should have_many(:starred_repositories) }
    it { should have_many(:recommendations) }
  end

  context "class methods" do
    context "find_for_github_oauth" do
      let(:auth){ auth = OmniAuth::AuthHash.new(credentials: {token: "12345"}, extra: {raw_info: {name: "Dan Example", login: "example", avatar_url: "https://secure.gravatar.com/avatar/c5a551578630f77febda69e391cb2a36?d=https://a248.e.akamai.net/assets.github.com%2Fimages%2Fgravatars%2Fgravatar-user-420.png", email: "dan@example.com"}}, uid: "123", provider: "github") }
      it "should create a new user based on the response from github" do
        lambda{@user = User.find_for_github_oauth(auth)}.should change(User, :count).by(1)
        check_user(@user)
      end

      it "should return the user if they already exist" do
        previous_user = FactoryGirl.create(:user, provider: "github", uid: "123", name: "Joe Example")
        lambda{@user = User.find_for_github_oauth(auth)}.should change(User, :count).by(0)
        check_user(@user)
      end
    end
  end

  context "instance methods" do
    let(:user) { FactoryGirl.create(:user, provider: "github", uid: "123", name: "Dan Example") }
    let(:starred_attributes) { [Hashie::Mash.new({full_name: "example/test", name: "test", owner: {login: "example", avatar_url: "" }, description: "Test Repo", language: "Ruby", homepage: "example.com", html_url: "http://github.com/example/test"}), Hashie::Mash.new({full_name: "example/demo", name: "demo", owner: {login: "example", avatar_url: "" }, description: "Demo Repo", language: "Ruby", homepage: "demo.com", html_url: "http://github.com/example/demo"})] }

    context "create_or_update_starred_repositories!" do
      it "should create records" do
        Github.stub_chain(:new, :activity, :starring, :starred).and_return(starred_attributes)
        lambda{user.create_or_update_starred_repositories!}.should change(StarredRepository, :count).by(2)
        starred_repo = user.starred_repositories.first
        starred_repo.full_name.should == "example/test"
        starred_repo.owner.should == "example"
      end

      it "should update records" do
        Github.stub_chain(:new, :activity, :starring, :starred).and_return(starred_attributes)
        default_starred_repositories
        StarredRepository.where(full_name: "example/test").first.repo_name.should be_nil
        lambda{user.create_or_update_starred_repositories!}.should change(StarredRepository, :count).by(0)
        StarredRepository.where(full_name: "example/test").first.repo_name.should == "test"
      end
    end

    context "destroy_repos_not_in!" do
      it "should destroy repos not in the array" do
        default_starred_repositories
        FactoryGirl.create(:starred_repository, full_name: "example/temp", user: user)
        lambda{ user.destroy_repos_not_in!(starred_attributes) }.should change(StarredRepository, :count).by(-1)
      end
    end


    context "star actions" do
      let(:additional_star_attributes) { starred_attributes << Hashie::Mash.new({full_name: "example/temporary", name: "temporary", owner: {login: "example", avatar_url: "" }, description: "Temporary Repo", language: "Ruby", homepage: "example.com", html_url: "http://github.com/example/temporary"}) }
      context "star" do
        it "should update records " do
          default_starred_repositories
          Github.stub_chain(:new, :activity, :starring, :star).with("example", "temporary").and_return(true)
          Github.stub_chain(:new, :activity, :starring, :starred).and_return(additional_star_attributes)
          lambda{ user.star("example", "temporary") }.should change(StarredRepository, :count).by(1)
        end
      end

      context "unstar" do
        it "should update records " do
          default_starred_repositories
          FactoryGirl.create(:starred_repository, full_name: "example/temp", owner: "exaple", repo_name: "temp", user: user)
          Github.stub_chain(:new, :activity, :starring, :unstar).with("example", "temp").and_return(true)
          Github.stub_chain(:new, :activity, :starring, :starred).and_return(starred_attributes)
          lambda{ user.unstar("example", "temp") }.should change(StarredRepository, :count).by(-1)
        end
      end
    end

    context "needs_recommendations?" do
      it "should return true if recommendations is blank" do
        user.recommendations_generated_at.should be_blank
        user.needs_recommendations?.should == true
      end

      it "should return true if recommendations is more than an hour old" do
        user.update_column(:recommendations_generated_at, Time.now-2.hours)
        user.needs_recommendations?.should == true
      end

      it "should return false if recommendations is less than an hour old" do
        user.update_column(:recommendations_generated_at, Time.now-30.minutes)
        user.needs_recommendations?.should == false
      end
    end
  end
end