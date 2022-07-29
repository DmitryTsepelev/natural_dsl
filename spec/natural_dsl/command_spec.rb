RSpec.describe NaturalDSL::Command do
  let(:command) { described_class.new(:some_command) }

  shared_examples "adds primitive and returns expectation" do |primitive_class|
    it "adds #{primitive_class} to expectations" do
      subject
      expect(command.expectations.size).to eq(1)
      expect(command.expectations.last).to be_a(primitive_class)
    end

    it "returns #{primitive_class} instance" do
      expect(subject).to be_a(primitive_class)
    end
  end

  describe "#token" do
    subject { command.send(:token) }

    include_examples "adds primitive and returns expectation", NaturalDSL::Expectations::Token
  end

  describe "#keyword" do
    subject { command.send(:keyword, :something) }

    it "adds Keyword to expectations" do
      subject
      expect(command.expectations.size).to eq(1)
      expect(command.expectations.last).to be_a(NaturalDSL::Expectations::Keyword)
      expect(command.expectations.last.type).to eq(:something)
    end
  end

  describe "#execute" do
    subject { command.send(:execute, &proc {}) }

    it "sets execution_block" do
      subject
      expect(command.execution_block).to be_a(Proc)
    end
  end

  describe "#build" do
    subject { command.build(&build_block) }

    let(:build_block) { proc {} }

    it { is_expected.to eq(command) }

    context "when block has expectation" do
      let(:build_block) { proc { token } }

      it "registers expectation" do
        subject
        expect(command.expectations.size).to eq(1)
      end

      context "when block has expectation with value at the last place" do
        let(:build_block) { proc { token.with_value } }

        it "not raises error" do
          expect { subject }.not_to raise_error
        end
      end

      context "when block has expectation with value in the middle" do
        let(:build_block) do
          proc {
            keyword(:something).with_value
            token.with_value
          }
        end

        it "raises error" do
          expect { subject }.to raise_error(
            RuntimeError,
            "Command some_command attempts to consume value after keyword :something"
          )
        end
      end
    end
  end
end
