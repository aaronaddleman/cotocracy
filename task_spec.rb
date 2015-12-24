require_relative 'task'
 
describe Task do
  context "task" do
    let(:task){Task.new}

    describe "#new_command" do
      it "creates a new command" do
        task.add_command("ls /")
        expect(task.command).to eq("ls /")
      end
    end
  end
end