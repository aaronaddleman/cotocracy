require './project'
# require 'spec_helper'
 
describe Project do
  context "error handling" do
    let(:helloWorld){Project.new}

    describe "#new" do
      it "accept name" do
        helloWorld.name = "hello world"
        expect(helloWorld.name).to eq("hello world")
      end

      it "accept description" do
        helloWorld.description = "making the world a better place"
        expect(helloWorld.description).to eq("making the world a better place")
      end
    end
  end
end