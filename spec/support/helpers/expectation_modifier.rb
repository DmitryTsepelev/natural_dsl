RSpec.shared_context "expectation modifier" do |modifier:, conflicts:|
  describe "#modifier" do
    subject { expectation.send("#{modifier}?") }

    it { is_expected.to eq(false) }

    context "when #{modifier} is true" do
      it "returns true" do
        expectation.send(modifier)
        expect(subject).to eq(true)
      end

      Array(conflicts).each do |conflict|
        context "when #{conflict} is true" do
          before { expectation.send(conflict) }

          it "raises error" do
            expect { expectation.send(modifier) }.to raise_error(
              RuntimeError,
              "#{modifier} cannot be configured for #{described_class.name} with #{conflict}"
            )
          end
        end
      end
    end
  end
end
