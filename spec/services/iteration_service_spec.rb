require 'rails_helper'

describe IterationService do
  let(:project) { create :project,
                  iteration_start_day: 2,
                  iteration_length: 1,
                  start_date: Time.zone.parse('2016-05-13') }
  let(:service) { IterationService.new(project) }

  it 'should return the start of the current iteration' do
    expect(service.iteration_start_date).to eq(Time.zone.parse('2016/05/10'))
  end

  it 'should return the iteration number for a date' do
    expect(service.iteration_number_for_date(Time.zone.parse('2016/08/22'))).to eq(15)
    expect(service.iteration_number_for_date(Time.zone.parse('2016/08/23'))).to eq(16)
  end

  it 'should return the starting date of an iteration' do
    expect(service.date_for_iteration_number(15)).to eq(Time.zone.parse('2016/08/16'))
    expect(service.date_for_iteration_number(16)).to eq(Time.zone.parse('2016/08/23'))
  end

  context "same specs from project_spec.js/start date describe block" do
    before do
      project.iteration_start_day = 1
      project.iteration_length = 1
    end

    it 'should return the start date"' do
      # Date is a Monday, and day 1 is Monday
      project.start_date = Time.zone.parse "2011/09/12"
      expect(service.iteration_start_date).to eq(Time.zone.parse("2011/09/12"))

      # If the project start date has been explicitly set to a Thursday, but
      # the iteration_start_day is Monday, the start date should be the Monday
      # that immeadiatly preceeds the Thursday.
      project.start_date = Time.zone.parse "2011/07/28"
      expect(service.iteration_start_date).to eq(Time.zone.parse("2011/07/25"))

      # The same, but this time the iteration start day is 'after' the start
      # date day, in ordinal terms, e.g. iteration start date is a Saturday,
      # project start date is a Thursday.  The Saturday prior to the Thursday
      # should be returned.
      project.iteration_start_day = 6
      expect(service.iteration_start_date).to eq(Time.zone.parse("2011/07/23"))

      # If the project start date is not set, it should be considered as the
      # first iteration start day prior to today.
      expected_date = Time.zone.parse('2011/07/23')
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
      service.start_date = Time.zone.parse("2011/07/25")

      compare_date = Time.zone.parse("2011/07/25")
      expect(service.iteration_number_for_date(compare_date)).to eq(1)

      compare_date = Time.zone.parse("2011/08/01")
      expect(service.iteration_number_for_date(compare_date)).to eq(2)

      # With a 2 week iteration length, the date above will still be in
      # iteration 1
      service.iteration_length = 2
      expect(service.iteration_number_for_date(compare_date)).to eq(1)
    end

    it 'should get the right iteration number for a given date' do
      # This is a Monday
      service.start_date = Time.zone.parse "2011/07/25"

      expect(service.date_for_iteration_number(1)).to eq(Time.zone.parse("2011/07/25"))
      expect(service.date_for_iteration_number(5)).to eq(Time.zone.parse("2011/08/22"))

      service.iteration_length = 4
      expect(service.date_for_iteration_number(1)).to eq(Time.zone.parse("2011/07/25"))
      expect(service.date_for_iteration_number(5)).to eq(Time.zone.parse("2011/11/14"))

      # Sunday
      service.iteration_start_day = 0
      expect(service.date_for_iteration_number(1)).to eq(Time.zone.parse("2011/07/24"))
      expect(service.date_for_iteration_number(5)).to eq(Time.zone.parse("2011/11/13"))

      # Tuesday - This should evaluate to the Tuesday before the explicitly
      # set start date (Monday)
      service.iteration_start_day = 2
      expect(service.date_for_iteration_number(1)).to eq(Time.zone.parse("2011/07/19"))
      expect(service.date_for_iteration_number(5)).to eq(Time.zone.parse("2011/11/08"))
    end
  end

  context 'complete set of stories in many different iterations' do
    let(:today) { Time.utc(2016, 8, 31, 12, 0, 0) }
    let(:dummy) { create(:user, username: "dummy", email: "dummy@foo.com", name: "Dummy", initials: "XX")}
    before do
      I18n.locale = :en
      Time.zone = 'Brasilia'
      Timecop.freeze(today)
      project.start_date = Time.zone.parse("2016-07-01")
      project.users << dummy
      project.save
      story_types = ['feature', 'feature', 'bug', 'feature'] # 3 times more features than bugs, in average

      # it was previously using a fixed random seed of 666, but for some reason the results were not always deterministic, so fixing the exact random sequences to make sure it always pass, but it's the same as Random.new(666).rand
      random_numbers_1 = [0, 1, 2, 0, 2, 3, 3, 2, 1, 2, 0, 0, 3, 0, 0, 0, 3, 1, 2, 1, 3, 0, 3, 0, 2, 1, 2, 2, 3, 2, 3, 1, 2, 1, 1, 0, 3, 3, 3, 0, 3, 1, 0, 2, 1, 1, 0, 3, 2, 0, 2, 1, 3, 2, 0, 0, 0, 3, 2, 2, 2, 2, 0, 1, 3, 2, 0, 3, 3, 1, 0, 3, 2, 3, 1]
      random_numbers_2 = [3, 2, 5, 8, 8, 1, 3, 8, 1, 8, 1, 3, 1, 8, 3, 2, 1, 1, 5, 5, 1, 1, 5, 5, 3, 1, 5, 8, 5, 5, 2, 8, 8, 3, 8, 2, 5, 8, 2, 3, 3, 3, 2, 8, 1, 1, 2, 1, 8, 3, 8, 1, 8, 1, 3]

      65.times do |i|
        story_type = story_types[random_numbers_1.shift]
        estimate = story_type == 'bug' ? nil : random_numbers_2.shift
        project.stories.create!(title: "Story #{i}", story_type: story_type, estimate: estimate, state: 'accepted', accepted_at: project.start_date + i.days, requested_by: dummy)
      end
      10.times do |i|
        story_type = story_types[random_numbers_1.shift]
        estimate = story_type == 'bug' ? nil : random_numbers_2.shift
        project.stories.create!(title: "Story #{65 + i}", story_type: story_type, estimate: estimate, requested_by: dummy)
      end
    end

    after { Timecop.return }

    it '#group_by_iteration' do
      groups = service.group_by_iteration
      expect(groups).to eq({1 => [3, 2, 0, 5],
                            2 => [0, 8, 8, 0, 1, 0, 3],
                            3 => [8, 1, 8, 1, 3, 1, 8],
                            4 => [0, 3, 2, 1, 1, 5, 0],
                            5 => [5, 0, 0, 1, 0, 1, 5],
                            6 => [0, 5, 3, 1, 5, 8, 5],
                            7 => [5, 2, 8, 8, 0, 3, 8],
                            8 => [2, 5, 0, 8, 0, 2, 3],
                            9 => [0, 3, 3, 2, 8]})
    end

    it '#group_by_velocity' do
      groups = service.group_by_velocity
      expect(groups).to eq({1=>10, 2=>20, 3=>30, 4=>12, 5=>12, 6=>27, 7=>34, 8=>20, 9=>16})
    end

    it '#group_by_bugs' do
      groups = service.group_by_bugs
      expect(groups).to eq({1=>1, 2=>3, 3=>0, 4=>2, 5=>3, 6=>1, 7=>1, 8=>2, 9=>1})
    end

    it '#velocity' do
      expect(service.velocity).to eq(23)
    end

    it '#group_by_developer' do
      groups = service.group_by_developer
      expect(groups).to eq([{:name=>"Dummy", :data=>{1=>10, 2=>20, 3=>30, 4=>12, 5=>12, 6=>27, 7=>34, 8=>20, 9=>16}}])
    end

    it '#backlog_iterations' do
      # there were 75 stories total
      # 59 stories in the done column
      # there are 10 in the in_progress and 6 in the backlog
      iterations = service.backlog_iterations
      expect(iterations.size).to eq(2)
      expect(iterations.first.size).to eq(11)
      expect(iterations.last.size).to eq(6)

      # override velocity to simulate different iterations
      iterations = service.backlog_iterations(10)
      expect(iterations.size).to eq(6)
      expect(iterations.first.size).to eq(9)
    end

    it '#current_iteration_details' do
      iterations = service.backlog_iterations
      current_iteration = iterations.first
      current_iteration[-1].start

      current_iteration[-2].start
      current_iteration[-2].finish

      current_iteration[-3].start
      current_iteration[-3].finish
      current_iteration[-3].deliver
      current_iteration[-3].reject

      details = service.current_iteration_details
      expect(details).to eq({"started"=>3, "finished"=>8, "delivered"=>0, "accepted"=>4, "rejected"=>1})
    end

    it '#standard_deviation' do
      standard_deviation = service.standard_deviation([])
      expect(standard_deviation).to eq(0)

      # calculate for population
      standard_deviation = service.standard_deviation(service.group_by_velocity.values)
      expect("%.4f" % standard_deviation).to eq("8.0890")

      # calculate for sample (N - 1) for correction
      standard_deviation = service.standard_deviation(service.group_by_velocity.values, true)
      expect("%.4f" % standard_deviation).to eq("8.5797")

      # last 3 iterations
      standard_deviation = service.standard_deviation(service.group_by_velocity.values.reverse.take(3))
      expect("%.4f" % standard_deviation).to eq("7.7172")
    end

    it '#volatility' do
      volatility = service.volatility(9)
      expect("%.4f" % volatility).to eq("0.4045")

      volatility = service.volatility
      expect("%.4f" % volatility).to eq("0.4109")
    end
  end
end
