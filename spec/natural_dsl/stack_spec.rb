RSpec.describe NaturalDSL::Stack do
  let(:stack) { described_class.new }

  describe "#pop_if" do
    subject { stack.pop_if(expected_class, raise: raise) }

    let(:raise) { true }
    let(:expected_class) { NaturalDSL::Primitives::Value }

    context "when stack is empty" do
      it "raises error" do
        expect { subject }.to raise_error(RuntimeError, "Expected Value but stack was empty")
      end

      context "when raise is false" do
        let(:raise) { false }

        it "not raises error" do
          expect { subject }.not_to raise_error
        end
      end
    end

    context "when stack has matching object on top" do
      let(:value) { NaturalDSL::Primitives::Value.new(42) }

      before { stack.push(value) }

      it { is_expected.to eq(value) }

      it "removes object from the top" do
        expect { subject }.to change { stack.size }.by(-1)
      end
    end

    context "when stack has no matching object on top" do
      let(:keyword) { NaturalDSL::Primitives::Keyword.new(:something) }

      before do
        stack.push(keyword)
      end

      it "raises error" do
        expect { subject }.to raise_error(RuntimeError, "Expected Value but got Keyword")
        expect(stack.size).to eq(1)
      end

      context "when raise is false" do
        let(:raise) { false }

        it "not raises error" do
          expect { subject }.not_to raise_error
        end
      end
    end
  end

  describe "#pop_if_keyword" do
    subject { stack.pop_if_keyword(expected_keyword, raise: raise) }

    let(:raise) { true }
    let(:expected_keyword) { :expected_keyword }

    context "when stack is empty" do
      it "raises error" do
        expect { subject }.to raise_error(RuntimeError, "Expected Keyword but stack was empty")
      end
    end

    context "when stack has no matching object on top" do
      let(:keyword) { NaturalDSL::Primitives::Value.new(42) }

      before { stack.push(keyword) }

      it "raises error" do
        expect { subject }.to raise_error(RuntimeError, "Expected Keyword but got Value")
        expect(stack.size).to eq(1)
      end

      context "when raise is false" do
        let(:raise) { false }

        it "not raises error" do
          expect { subject }.not_to raise_error
        end
      end
    end

    context "when stack has matching keyword on top" do
      let(:value) { NaturalDSL::Primitives::Keyword.new(expected_keyword) }

      before { stack.push(value) }

      it { is_expected.to eq(value) }

      it "removes object from the top" do
        expect { subject }.to change { stack.size }.by(-1)
      end
    end

    context "when stack has no matching keyword on top" do
      let(:keyword) { NaturalDSL::Primitives::Keyword.new(:unexpected_keyword) }

      before { stack.push(keyword) }

      it "raises error" do
        expect { subject }.to raise_error(RuntimeError, "Expected #{expected_keyword} but got #{keyword.type}")
        expect(stack.size).to eq(1)
      end

      context "when raise is false" do
        let(:raise) { false }

        it "not raises error" do
          expect { subject }.not_to raise_error
        end
      end
    end
  end
end
