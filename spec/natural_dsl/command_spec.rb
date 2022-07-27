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

  describe "#value" do
    subject { command.send(:value, :some_method) }

    include_examples "adds primitive and returns expectation", NaturalDSL::Expectations::Value

    it "adds method_name to value_method_names" do
      subject
      expect(command.value_method_names.size).to eq(1)
      expect(command.value_method_names.last).to eq(:some_method)
    end

    context "when value is called without argument" do
      subject { command.send(:value) }

      include_examples "adds primitive and returns expectation", NaturalDSL::Expectations::Value

      it "adds default method_name to value_method_names" do
        subject
        expect(command.value_method_names.size).to eq(1)
        expect(command.value_method_names.last).to eq(:value)
      end
    end
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

  describe "#zero_or_more" do
    subject { NaturalDSL::Expectations::Token.new }

    before { command.send(:zero_or_more, subject) }

    it { is_expected.to be_zero_or_more }
  end
end
