RSpec.describe NaturalDSL::VM do
  describe ".build" do
    subject { described_class.build(lang) }

    context "when lang has command" do
      context "when command has no value method names" do
        let(:lang) do
          NaturalDSL::Lang.define do
            command :some_command do
              keyword :something
            end
          end
        end

        it "defines command method" do
          expect(subject).to respond_to(:some_command)
        end
      end
    end
  end

  describe ".run" do
    subject { described_class.run(lang, &run_block) }

    let(:run_block) { proc { some_command something } }
    let(:lang) do
      NaturalDSL::Lang.define do
        command :some_command do
          token

          execute { |_, token| token.name }
        end
      end
    end

    it "performs block" do
      expect(subject).to eq(:something)
    end
  end

  describe "#assign_variable" do
    subject { vm.read_variable(token) }

    let(:vm) { described_class.new(lang) }
    let(:lang) { NaturalDSL::Lang.define {} }
    let(:token) { NaturalDSL::Primitives::Token.new(:some_token) }
    let(:value) { NaturalDSL::Primitives::Value.new(42) }

    it "assigns variable" do
      expect { vm.assign_variable(token, value) }.to \
        change { vm.read_variable(token) }.from(nil).to(value)
    end
  end

  describe "#read_variable" do
    subject { vm.read_variable(token) }

    let(:vm) { described_class.new(lang) }
    let(:lang) { NaturalDSL::Lang.define {} }
    let(:token) { NaturalDSL::Primitives::Token.new(:some_token) }

    context "when variable is not set" do
      it { is_expected.to be_nil }
    end

    context "when variable is set" do
      let(:value) { NaturalDSL::Primitives::Value.new(42) }

      before { vm.assign_variable(token, value) }

      it { is_expected.to eq(value) }
    end
  end

  describe "#method_missing" do
    let(:method_name) { :something }
    let(:args) { [] }

    let(:vm) { described_class.new(lang) }

    before { vm.send(method_name, *args) }

    context "when missing method name is not registered as a keyword" do
      let(:lang) { NaturalDSL::Lang.define {} }

      it "adds token to the stack" do
        expect(vm.stack.size).to eq(1)
        expect(vm.stack.last).to eq(NaturalDSL::Primitives::Token.new(method_name))
      end

      context "when there is a value in args" do
        let(:args) { [42] }

        it "adds token and value to the stack" do
          expect(vm.stack.size).to eq(2)
          expect(vm.stack).to eq [
            NaturalDSL::Primitives::Value.new(42),
            NaturalDSL::Primitives::Token.new(method_name)
          ]
        end
      end
    end

    context "when missing method name is registered as a keyword" do
      let(:lang) do
        NaturalDSL::Lang.define do
          command :some_command do
            keyword :something
          end
        end
      end

      it "adds keyword to the stack" do
        expect(vm.stack.size).to eq(1)
        expect(vm.stack.last).to eq(NaturalDSL::Primitives::Keyword.new(method_name))
      end

      context "when there is a value in args" do
        let(:args) { [42] }

        it "adds token and value to the stack" do
          expect(vm.stack.size).to eq(2)
          expect(vm.stack).to eq [
            NaturalDSL::Primitives::Value.new(42),
            NaturalDSL::Primitives::Keyword.new(method_name)
          ]
        end
      end
    end
  end
end
