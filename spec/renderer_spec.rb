require 'spec_helper'


describe Pixo::Renderer do
  let(:renderer) { Pixo::Renderer.new }

  after(:each) do
    renderer.service.shutdown
  end

  describe "#active_pattern" do
    subject { renderer.active_pattern }

    it { is_expected.to match /\.glsl$/ }
  end

  describe "#active_pattern=" do
    let(:pattern_name) { renderer.pattern_names.sample }

    subject { renderer.active_pattern = pattern_name }

    it {is_expected.to eq pattern_name}
  end

  describe "#leds_on" do
    subject { renderer.leds_on }

    it { is_expected.to be_truthy }
  end

  describe "#leds_on=" do
    let(:leds_on) { false }

    subject { renderer.leds_on = leds_on }

    it {is_expected.to eq leds_on}
  end
  
  describe "#brightness" do
    subject { renderer.brightness }

    it { is_expected.to eq 1.0 }
  end

  describe "#brightness=" do
    let(:brightness) { 0.5 }

    subject { renderer.brightness = brightness }

    it {is_expected.to eq brightness}
  end
  
  describe "#pattern_names" do
    subject { renderer.pattern_names }

    it { is_expected.to_not be_empty }
  end

end
