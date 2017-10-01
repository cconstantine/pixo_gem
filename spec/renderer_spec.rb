require 'spec_helper'


describe Pixo::Renderer do
  let(:renderer) { Pixo::Renderer.new }

  after(:each) do
    renderer.shutdown
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

  describe "#add_fadecandy" do
    subject { renderer.add_fadecandy('localhost', 8) }

    it {is_expected.to eq "localhost"}
  end

  describe "#add_pattern" do
    subject { renderer.add_pattern("basic.glsl", Pixo.seed_patterns["basic.glsl"])}

    context 'with a fadecandy' do
      before(:each) { renderer.add_fadecandy('localhost', 8) }

      it {is_expected.to eq "basic.glsl"}

      context "adding all the seeds" do
        it "should work" do
          Pixo.seed_patterns.each do |name, code|
            expect(renderer.add_pattern(name, code)).to eq name
          end
        end
      end
    end

    it {is_expected.to eq "basic.glsl"}
  end

  describe "#list_patterns" do
    subject { renderer.list_patterns }

    it { is_expected.to be_empty }


    context "with an added pattern" do
      let(:pattern_name) { "basic.glsl" }

      before(:each) do
        renderer.add_pattern(pattern_name, Pixo.seed_patterns[pattern_name])
      end

      it { is_expected.to have(1).item  }
    end
  end

  describe "#pattern" do
    subject { renderer.pattern }

    it { is_expected.to be_nil }

    context 'with a fadecandy' do
      before(:each) { renderer.add_fadecandy('localhost', 8) }

      it { is_expected.to be_nil }

      context "with a pattern set" do
        before(:each) do
          renderer.add_pattern("basic.glsl", Pixo.seed_patterns["basic.glsl"])
          renderer.pattern = "basic.glsl"
        end

        it {is_expected.to eq "basic.glsl"}
      end
    end
  end

  describe "#pattern=" do
    let(:pattern_name) { "basic.glsl" }
    subject { renderer.pattern = pattern_name }

    context "with no added patterns" do
      it { is_expected.to eq "basic.glsl" }
    end

    context "with an added pattern" do
      before(:each) do
        renderer.add_pattern(pattern_name, Pixo.seed_patterns[pattern_name])
      end

      it { is_expected.to eq pattern_name }
    end
  end
end
