RSpec.describe NaturalDSL::Expectations::Keyword do
  let(:expectation) { described_class.new(:something) }

  include_context "expectation modifier", modifier: :zero_or_more, conflicts: :with_value
  include_context "expectation modifier", modifier: :with_value, conflicts: :zero_or_more

  describe "#read_arguments" do
    subject { expectation.read_arguments(stack) }

    let(:stack) { NaturalDSL::Stack.new }

    it "raises error from stack" do
      expect { subject }.to raise_error(RuntimeError, "Expected Keyword but stack was empty")
    end

    context "when stack has keyword on top" do
      let(:keyword) { NaturalDSL::Primitives::Keyword.new(:something) }

      before { stack << keyword }

      it { is_expected.to be_empty }

      it "removes keyword from stack" do
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

      it "removes keyword from stack" do
        subject
        expect(stack).to be_empty
      end

      context "when stack has keyword on top" do
        let(:keyword) { NaturalDSL::Primitives::Keyword.new(:something) }

        before { stack << keyword }

        it { is_expected.to be_empty }

        context "when stack has another token" do
          let(:another_keyword) { NaturalDSL::Primitives::Keyword.new(:something) }

          before { stack << another_keyword }

          it { is_expected.to be_empty }

          it "removes keywords from stack" do
            subject
            expect(stack).to be_empty
          end
        end
      end
    end

    context "when with_value is true" do
      before { expectation.with_value }

      it "raises error from stack" do
        expect { subject }.to raise_error(RuntimeError, "Expected Keyword but stack was empty")
      end

      context "when stack has keyword on top" do
        let(:keyword) { NaturalDSL::Primitives::Keyword.new(:something) }

        before { stack << keyword }

        it "raises error from stack" do
          expect { subject }.to raise_error(RuntimeError, "Expected Value but stack was empty")
        end
      end

      context "when stack has keyword and value on top" do
        let(:keyword) { NaturalDSL::Primitives::Keyword.new(:something) }
        let(:value) { NaturalDSL::Primitives::Value.new(42) }

        before do
          stack << value
          stack << keyword
        end

        it { is_expected.to eq([value]) }

        it "removes keyword and value from stack" do
          subject
          expect(stack).to be_empty
        end
      end
    end
  end
end
