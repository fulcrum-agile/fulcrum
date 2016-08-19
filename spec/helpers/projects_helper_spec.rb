require 'rails_helper'

describe ProjectsHelper do

  describe '#point_scale_options' do

    specify { expect(point_scale_options).to be_instance_of(Array) }

    it "returns an array of arrays" do
      point_scale_options.each do |option|
        expect(option).to be_instance_of(Array)
      end
    end

  end

  describe '#iteration_length_options' do

    specify { expect(iteration_length_options).to be_instance_of(Array) }

    it "returns an array of arrays" do
      iteration_length_options.each do |option|
        expect(option).to be_instance_of(Array)
      end
    end

  end

  describe '#day_name_options' do

    specify { expect(day_name_options).to be_instance_of(Array) }

    it "returns an array of arrays" do
      day_name_options.each do |option|
        expect(option).to be_instance_of(Array)
      end
    end

  end
end
