require "refinements/string_demodulize"

RSpec.describe StringDemodulize do
  using StringDemodulize

  subject { string.demodulize }

  let(:string) { "Class" }

  it { is_expected.to eq(string) }

  context "when string contains module" do
    let(:string) { "Module::Class" }

    it { is_expected.to eq("Class") }
  end
end
