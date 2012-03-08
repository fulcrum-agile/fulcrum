require 'spec_helper'

describe ProjectsHelper do

  describe '#point_scale_options' do

    specify { point_scale_options.should be_instance_of(Array) }

    it "returns an array of arrays" do
      point_scale_options.each do |option|
        option.should be_instance_of(Array)
      end
    end

  end

  describe '#iteration_length_options' do

    specify { iteration_length_options.should be_instance_of(Array) }

    it "returns an array of arrays" do
      iteration_length_options.each do |option|
        option.should be_instance_of(Array)
      end
    end

  end

  describe '#day_name_options' do

    specify { day_name_options.should be_instance_of(Array) }

    it "returns an array of arrays" do
      day_name_options.each do |option|
        option.should be_instance_of(Array)
      end
    end

  end
end
