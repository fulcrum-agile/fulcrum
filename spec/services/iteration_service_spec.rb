require 'rails_helper'

describe IterationService do
  let(:project) { FactoryGirl.create :project,
                  iteration_start_day: 2,
                  iteration_length: 1,
                  start_date: Time.parse('2016/05/13') }
  let(:service) { IterationService.new(project) }

  it 'should return the start of the current iteration' do
    expect(service.iteration_start_date).to eq(Time.parse('2016/05/10'))
  end

  it 'should return the iteration number for a date' do
    expect(service.iteration_number_for_date(Time.parse('2016/08/22'))).to eq(15)
    expect(service.iteration_number_for_date(Time.parse('2016/08/23'))).to eq(16)
  end

  it 'should return the starting date of an iteration' do
    expect(service.date_for_iteration_number(15)).to eq(Time.parse('2016/08/16'))
    expect(service.date_for_iteration_number(16)).to eq(Time.parse('2016/08/23'))
  end

  context "same specs from project_spec.js/start date describe block" do
    before do
      project.iteration_start_day = 1
      project.iteration_length = 1
    end

    it 'should return the start date"' do
      # Date is a Monday, and day 1 is Monday
      project.start_date = Time.parse "2011/09/12"
      expect(service.iteration_start_date).to eq(Time.parse("2011/09/12"))

      # If the project start date has been explicitly set to a Thursday, but
      # the iteration_start_day is Monday, the start date should be the Monday
      # that immeadiatly preceeds the Thursday.
      project.start_date = Time.parse "2011/07/28"
      expect(service.iteration_start_date).to eq(Time.parse("2011/07/25"))

      # The same, but this time the iteration start day is 'after' the start
      # date day, in ordinal terms, e.g. iteration start date is a Saturday,
      # project start date is a Thursday.  The Saturday prior to the Thursday
      # should be returned.
      project.iteration_start_day = 6
      expect(service.iteration_start_date).to eq(Time.parse("2011/07/23"))

      # If the project start date is not set, it should be considered as the
      # first iteration start day prior to today.
      expected_date = Time.parse('2011/07/23')
      expect(service.iteration_start_date).to eq(expected_date)
    end
  end

  context "same specs from project_spec.js/iterations describe block" do
    before do
      project.iteration_start_day = 1
      project.iteration_length = 1
    end

    it 'should get the right iteration number for a given date' do
      # This is a Monday
      service.start_date = Time.parse("2011/07/25")

      compare_date = Time.parse("2011/07/25")
      expect(service.iteration_number_for_date(compare_date)).to eq(1)

      compare_date = Time.parse("2011/08/01")
      expect(service.iteration_number_for_date(compare_date)).to eq(2)

      # With a 2 week iteration length, the date above will still be in
      # iteration 1
      service.iteration_length = 2
      expect(service.iteration_number_for_date(compare_date)).to eq(1)
    end

    it 'should get the right iteration number for a given date' do
      # This is a Monday
      service.start_date = Time.parse "2011/07/25"

      expect(service.date_for_iteration_number(1)).to eq(Time.parse("2011/07/25"))
      expect(service.date_for_iteration_number(5)).to eq(Time.parse("2011/08/22"))

      service.iteration_length = 4
      expect(service.date_for_iteration_number(1)).to eq(Time.parse("2011/07/25"))
      expect(service.date_for_iteration_number(5)).to eq(Time.parse("2011/11/14"))

      # Sunday
      service.iteration_start_day = 0
      expect(service.date_for_iteration_number(1)).to eq(Time.parse("2011/07/24"))
      expect(service.date_for_iteration_number(5)).to eq(Time.parse("2011/11/13"))

      # Tuesday - This should evaluate to the Tuesday before the explicitly
      # set start date (Monday)
      service.iteration_start_day = 2
      expect(service.date_for_iteration_number(1)).to eq(Time.parse("2011/07/19"))
      expect(service.date_for_iteration_number(5)).to eq(Time.parse("2011/11/08"))
    end
  end
end
