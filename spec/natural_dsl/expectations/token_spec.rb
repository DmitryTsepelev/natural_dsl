RSpec.describe NaturalDSL::Expectations::Token do
  let(:expectation) { described_class.new }

  include_context "expectation modifier", modifier: :zero_or_more, conflicts: :with_value
  include_context "expectation modifier", modifier: :with_value, conflicts: :zero_or_more

  describe "#read_arguments" do
    subject { expectation.read_arguments(stack) }

    let(:stack) { NaturalDSL::Stack.new }

    it "raises error from stack" do
      expect { subject }.to raise_error(RuntimeError, "Expected Token but stack was empty")
    end

    context "when stack has token on top" do
      let(:token) { NaturalDSL::Primitives::Token.new(:something) }

      before { stack << token }

      it { is_expected.to eq([token]) }

      it "removes token from stack" do
        subject
        expect(stack).to be_empty
      end
    end

    context "when zero_or_more is true" do
      before { expectation.zero_or_more }

      it "not raises error" do
        expect { subject }.not_to raise_error
      end

      it { is_expected.to eq([]) }

      context "when stack has token on top" do
        let(:token) { NaturalDSL::Primitives::Token.new(:something) }

        before { stack << token }

        it { is_expected.to eq([token]) }

        it "removes token from stack" do
          subject
          expect(stack).to be_empty
        end

        context "when stack has another token" do
          let(:another_token) { NaturalDSL::Primitives::Token.new(:something_else) }

          before { stack << another_token }

          it { is_expected.to eq([another_token, token]) }

          it "removes tokens from stack" do
            subject
            expect(stack).to be_empty
          end
        end
      end
    end

    context "when with_value is true" do
      before { expectation.with_value }

      it "raises error from stack" do
        expect { subject }.to raise_error(RuntimeError, "Expected Token but stack was empty")
      end

      context "when stack has token on top" do
        let(:token) { NaturalDSL::Primitives::Token.new(:something) }

        before { stack << token }

        it "raises error from stack" do
          expect { subject }.to raise_error(RuntimeError, "Expected Value but stack was empty")
        end
      end

      context "when stack has token and value on top" do
        let(:token) { NaturalDSL::Primitives::Token.new(:something) }
        let(:value) { NaturalDSL::Primitives::Value.new(42) }

        before do
          stack << value
          stack << token
        end

        it { is_expected.to eq([token, value]) }

        it "removes token and value from stack" do
          subject
          expect(stack).to be_empty
        end
      end
    end
  end
end
