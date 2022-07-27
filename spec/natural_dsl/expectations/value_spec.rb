RSpec.describe NaturalDSL::Expectations::Value do
  let(:expectation) { described_class.new }

  describe "#keyword?" do
    subject { expectation.keyword? }

    it { is_expected.to eq(false) }
  end

  describe "#read_arguments" do
    subject { expectation.read_arguments(stack) }

    let(:stack) { NaturalDSL::Stack.new }

    it "raises error from stack" do
      expect { subject }.to raise_error(RuntimeError, "Expected Value but stack was empty")
    end

    context "when stack has value on top" do
      let(:value) { NaturalDSL::Primitives::Value.new(42) }

      before { stack << value }

      it { is_expected.to eq([value]) }

      it "removes value from stack" do
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

      context "when stack has value on top" do
        let(:value) { NaturalDSL::Primitives::Value.new(42) }

        before { stack << value }

        it { is_expected.to eq([value]) }

        it "removes value from stack" do
          subject
          expect(stack).to be_empty
        end

        context "when stack has another value" do
          let(:another_token) { NaturalDSL::Primitives::Value.new(77) }

          before { stack << another_token }

          it { is_expected.to eq([another_token, value]) }

          it "removes values from stack" do
            subject
            expect(stack).to be_empty
          end
        end
      end
    end
  end
end
