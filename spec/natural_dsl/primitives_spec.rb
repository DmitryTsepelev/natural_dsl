RSpec.describe NaturalDSL::Primitives do
  describe NaturalDSL::Primitives::Value do
    context "#inspect" do
      subject { described_class.new(value).inspect }

      let(:value) { 42 }

      it { is_expected.to eq("Value(#{value})") }
    end
  end

  describe NaturalDSL::Primitives::Token do
    context "#inspect" do
      subject { described_class.new(name).inspect }

      let(:name) { :name }

      it { is_expected.to eq("Token(#{name})") }
    end
  end

  describe NaturalDSL::Primitives::Keyword do
    context "#inspect" do
      subject { described_class.new(type).inspect }

      let(:type) { :type }

      it { is_expected.to eq("Keyword(#{type})") }
    end
  end
end
