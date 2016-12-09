require 'rails_helper'

describe ApiTokensController, type: :controller do
  let(:user)            { create(:user, :with_team_and_is_admin) }
  let(:request_params)  { { team_id: user.teams.first } }

  context 'when not logged in' do
    context '#create' do
      specify do
        xhr :post, :create, request_params
        is_expected.to respond_with 401
      end
    end

    context '#destroy' do
      specify do
        xhr :delete, :destroy, request_params.merge(id: 1)
        is_expected.to respond_with 401
      end
    end
  end

  context 'when logged in' do
    before do
      sign_in user
      allow(subject).to receive_messages(current_user: user, current_team: user.teams.first)
    end

    describe '#create' do
      specify do
        xhr :post, :create, request_params
        expect(response).to redirect_to(edit_team_path(user.teams.first))
      end
    end

    context '#destroy' do
      let!(:api_token) { user.teams.first.api_tokens.create }

      specify do
        xhr :delete, :destroy, request_params.merge(id: api_token.id)
        expect(response).to redirect_to(edit_team_path(user.teams.first))
      end
    end
  end
end
