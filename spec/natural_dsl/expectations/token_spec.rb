RSpec.describe NaturalDSL::Expectations::Token do
  let(:expectation) { described_class.new }

  describe "#keyword?" do
    subject { expectation.keyword? }

    it { is_expected.to eq(false) }
  end

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
  end
end
