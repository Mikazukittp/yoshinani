require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /api/users/:id" do
    let(:user) { FactoryGirl.create(:user, username: "goroumaru") }
    let(:env) { { UID: user.id, TOKEN: user.token } }

    before do
      get api_user_path(user), {}, env
      @json = JSON.parse(response.body)
    end

    example '200が返ってくること' do
      expect(response).to be_success
      expect(response.status).to eq 200
    end

    example '期待したデータが取得されていること' do
      expect(@json["username"]).to eq "goroumaru"
    end
  end
end