require 'rails_helper'

RSpec.describe Entities::ProjectAnalysis do
  let(:date) { Time.current }

  let(:iteration) do
    double(
      :iteration,
      velocity: 10,
      volatility: 0,
      current_iteration_number: 32,
      next_iteration_date: date,
      date_for_iteration_number: date,
      backlog: [1, 2, 3],
      backlog_iterations: [3, 2, 1],
      current_iteration_details: {
        "started": 8,
        "finished": 5
      },
      backlog_date: [59, date],
      worst_backlog_date: [59, date]
    )
  end

  subject { described_class.represent(iteration).as_json }

  it { expect(subject[:velocity]).to eq(10) }
  it { expect(subject[:volatility]).to eq(0) }
  it { expect(subject[:current_iteration_number]).to eq(32) }
  it { expect(subject[:next_iteration_date]).to eq(date) }
  it { expect(subject[:backlog]).to eq([1, 2, 3]) }
  it { expect(subject[:backlog_iterations]).to eq([3, 2, 1]) }
  it { expect(subject[:current_iteration_details]).to eq({ "started": 8, "finished": 5 }) }
  it { expect(subject[:backlog_date]).to eq([59, date]) }
  it { expect(subject[:worst_backlog_date]).to eq([59, date]) }
end
