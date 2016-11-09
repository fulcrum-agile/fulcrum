require 'rails_helper'

describe LocalesController, type: :controller do

  describe "PUT #update" do
    it "sets the locale session if valdi" do
      put :update, locale: 'es'
      expect(session[:locale]).to eq('es')
      expect(response).to redirect_to root_path
    end

    it "does nothing if invalid locale" do
      put :update, locale: 'xx'
      expect(session[:locale]).to be_nil
      expect(response).to redirect_to root_path
    end
  end

end
