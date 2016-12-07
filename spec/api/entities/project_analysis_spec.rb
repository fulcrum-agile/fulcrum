require 'rails_helper'

RSpec.describe Entities::ProjectAnalysis do
  let(:iteration) do
    double(
      :iteration,
      velocity: 10,
      volatility: 0,
      current_iteration_number: 32,
      backlog: [1, 2, 3],
      backlog_iterations: [3, 2, 1]
    )
  end

  subject { described_class.represent(iteration).as_json }

  it { expect(subject[:velocity]).to eq(10) }
  it { expect(subject[:volatility]).to eq(0) }
  it { expect(subject[:current_iteration_number]).to eq(32) }
  it { expect(subject[:backlog]).to eq([1, 2, 3]) }
  it { expect(subject[:backlog_iterations]).to eq([3, 2, 1]) }
end
