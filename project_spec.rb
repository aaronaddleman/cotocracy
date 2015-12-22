require './project'
# require 'spec_helper'
 
describe Project do
  before :each do
    @helloWorld = Project.new(:name => "hello world", :description => "making the world a better place")
  end

  describe "#new" do
    it "accept name" 
    it "accept description" 
  end

  describe "#delete" do
    it "asks for name"
    it "confirms delete"
  end
end