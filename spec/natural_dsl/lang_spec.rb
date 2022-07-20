RSpec.describe NaturalDSL::Lang do
  describe "#command" do
    let(:command_name) { :command_name }

    before do
      subject.command(command_name, &command_block)
    end

    context "when command block is empty" do
      let(:command_block) { proc {} }

      it "registers command" do
        expect(subject.commands.length).to eq(1)
      end

      it "not registers keywords" do
        expect(subject.keywords).to be_empty
      end
    end

    context "when command block has keyword" do
      let(:command_block) { proc { keyword :something } }

      it "registers command" do
        expect(subject.commands.length).to eq(1)
      end

      it "registers keyword" do
        expect(subject.keywords).to eq([:something])
      end

      context "when command block has same keyword twice" do
        let(:command_block) do
          proc {
            keyword :something
            keyword :something
          }
        end

        it "registers keyword once" do
          expect(subject.keywords).to eq([:something])
        end
      end
    end
  end
end
