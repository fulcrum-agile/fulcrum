require 'rails_helper'

RSpec.describe Entities::Project do
  let(:project) { create :project }

  subject { described_class.represent(project).as_json }

  it { expect(subject[:slug]).to eq(project.slug) }
  it { expect(subject[:name]).to eq(project.name) }
  it { expect(subject[:point_scale]).to eq(project.point_scale) }
  it { expect(subject[:iteration_start_day]).to eq(project.iteration_start_day) }
  it { expect(subject[:iteration_length]).to eq(project.iteration_length) }
  it { expect(subject[:default_velocity]).to eq(project.default_velocity) }
  it { expect(subject[:start_date]).to eq(project.start_date.iso8601) }
  it { expect(subject[:velocity]).to be_nil }
  it { expect(subject[:volatility]).to be_nil }

  context 'when call it with full type' do
    subject { described_class.represent(project, type: :full).as_json }

    it { expect(subject[:velocity]).to eq(10) }
    it { expect(subject[:volatility]).to eq(0) }
  end
end
