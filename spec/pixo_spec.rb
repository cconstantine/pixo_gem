require 'spec_helper'

describe Pixo do
  describe "#seed_patterns" do
    subject { Pixo.seed_patterns }

    it { is_expected.to be_a Hash }
  end

end