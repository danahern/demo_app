require 'spec_helper'
describe MyController do
  login_user

  context "starred_repos" do
    let(:starred_attributes) { [Hashie::Mash.new({full_name: "example/test", name: "test", owner: {login: "example", avatar_url: "" }, description: "Test Repo", language: "Ruby", homepage: "example.com", html_url: "http://github.com/example/test"}), Hashie::Mash.new({full_name: "example/demo", name: "demo", owner: {login: "example", avatar_url: "" }, description: "Demo Repo", language: "Ruby", homepage: "demo.com", html_url: "http://github.com/example/demo"})] }

    it "should gather the starred repositories" do
      Github.stub_chain(:new, :activity, :starring, :starred).and_return(starred_attributes)
      get :starred_repos
      assigns(:starred_repos).size.should == 2
      assigns(:starred_repos).map(&:full_name).should == ["example/test", "example/demo"]
    end
  end
end