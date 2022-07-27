RSpec.describe NaturalDSL::Expectations::Keyword do
  let(:expectation) { described_class.new(:something) }

  describe "#keyword?" do
    subject { expectation.keyword? }

    it { is_expected.to eq(true) }
  end

  describe "#read_arguments" do
    subject { expectation.read_arguments(stack) }

    let(:stack) { NaturalDSL::Stack.new }

    it "raises error from stack" do
      expect { subject }.to raise_error(RuntimeError, "Expected Keyword but stack was empty")
    end

    context "when stack has keyword on top" do
      let(:keyword) { NaturalDSL::Primitives::Keyword.new(:something) }

      before { stack << keyword }

      it { is_expected.to eq([]) }

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

      context "when stack has token on top" do
        let(:keyword) { NaturalDSL::Primitives::Keyword.new(:something) }

        before { stack << keyword }

        it { is_expected.to eq([keyword]) }

        context "when stack has another token" do
          let(:another_keyword) { NaturalDSL::Primitives::Keyword.new(:something) }

          before { stack << another_keyword }

          it { is_expected.to eq([another_keyword, keyword]) }

          it "removes keywords from stack" do
            subject
            expect(stack).to be_empty
          end
        end
      end
    end
  end
end
