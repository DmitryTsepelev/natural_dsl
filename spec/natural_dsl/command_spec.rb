RSpec.describe NaturalDSL::Command do
  describe "#build" do
    subject { described_class.build(command_name, &command_block) }

    let(:command_name) { :some_command }

    shared_examples "adds primitive" do |primitive_class|
      it "adds #{primitive_class} to expectations" do
        expect(subject.expectations.size).to eq(1)
        expect(subject.expectations.last).to eq(primitive_class)
      end
    end

    context "when token is called inside block" do
      let(:command_block) { proc { token } }

      include_examples "adds primitive", NaturalDSL::Primitives::Token
    end

    context "when value is called inside block" do
      let(:command_block) { proc { value :some_method } }

      include_examples "adds primitive", NaturalDSL::Primitives::Value

      it "adds method_name to value_method_names" do
        expect(subject.value_method_names.size).to eq(1)
        expect(subject.value_method_names.last).to eq(:some_method)
      end

      context "when value is called without argument" do
        let(:command_block) { proc { value } }

        include_examples "adds primitive", NaturalDSL::Primitives::Value

        it "adds default method_name to value_method_names" do
          expect(subject.value_method_names.size).to eq(1)
          expect(subject.value_method_names.last).to eq(:value)
        end
      end
    end

    context "when keyword is called inside block" do
      let(:command_block) { proc { keyword :something } }

      it "adds Keyword to expectations" do
        expect(subject.expectations.size).to eq(1)
        expect(subject.expectations.last).to eq(NaturalDSL::Primitives::Keyword.new(:something))
      end
    end

    context "when execute is called inside block" do
      let(:command_block) { proc { execute {} } }

      it "sets execution_block" do
        expect(subject.execution_block).to be_a(Proc)
      end
    end
  end
end
