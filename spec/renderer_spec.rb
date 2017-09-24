require 'spec_helper'


describe Pixo::Renderer do
  let(:renderer) { Pixo::Renderer.new }

  describe "#active_pattern" do
    subject { renderer.active_pattern }

    it { is_expected.to match /\.glsl$/ }
  end

  describe "#pattern_names" do
    subject { renderer.pattern_names }

    it { is_expected.to_not be_empty }
  end

  describe "#set_pattern" do
    let(:pattern_name) { renderer.pattern_names.sample }

    subject { renderer.set_pattern(pattern_name) }

    it {is_expected.to eq renderer.active_pattern}
  end
end
