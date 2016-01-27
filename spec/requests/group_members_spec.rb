require 'rails_helper'

RSpec.describe 'GroupUsers', type: :request do
  let(:sign_in_user) { create(:user, email: 'sign-in-email@example.com', account: 'sign_in_user') }
  let(:env) { { UID: sign_in_user.id, TOKEN: sign_in_user.token } }
  let(:group) { create(:group, name: '幻影旅団', description: '所詮虫けらの戯言、俺の心には響かない') }

  describe 'GET /api/v1/groups/:group_id/uesrs' do
    context 'ログインユーザがそのグループに所属している場合' do
      before do
        create(:group_user, user_id: sign_in_user.id, group_id: group.id)
        get api_group_users_path(group), {}, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータの一覧が取得されていること' do
        expect(@json[0]['email']).to eq 'sign-in-email@example.com'
      end
    end

    context 'ログインユーザがそのグループに所属していなかった場合' do
      before do
        get api_group_users_path(group), {}, env
        @json = JSON.parse(response.body)
      end

      example '400が返ってくること' do
        expect(response).not_to be_success
        expect(response.status).to eq 400
      end
    end
  end

  describe 'POST /api/v1/groups/:group_id/users' do
    let(:user_1) { create(:user, email: 'love-soccer1@example.com', account: 'Neymar') }
    let(:user_2) { create(:user, email: 'love-soccer2@example.com', account: 'Puyol') }
    let(:group_user_params) {{
      group_user: [
        {user_id: user_1.id},
        {user_id: user_2.id}
      ]
    }}

    context 'ログインユーザがそのグループに所属している場合' do
      before do
        create(:group_user, user_id: sign_in_user.id, group_id: group.id)
        post api_group_users_path(group), group_user_params, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータが取得されていること' do
        expect(@json['name']).to eq '幻影旅団'
      end
    end

    context 'ログインユーザがそのグループに所属していなかった場合' do
      before do
        get api_group_users_path(group), {}, env
        @json = JSON.parse(response.body)
      end

      example '400が返ってくること' do
        expect(response).not_to be_success
        expect(response.status).to eq 400
      end
    end
  end

  describe 'PATCH /api/v1/groups/:group_id/users/accept' do
    context 'ログインユーザがそのグループに所属している場合' do
      let!(:group_user) { create(:group_user, user_id: sign_in_user.id, group_id: group.id) }

      before do
        patch accept_api_group_user_path(group_id: group.id, id: group_user.id), {}, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータが取得されていること' do
        expect(@json['status']).to eq 'active'
      end
    end

    context 'ログインユーザがそのグループに所属していなかった場合' do
      let(:user_1) { create(:user, email: 'love-soccer1@example.com', account: 'Neymar') }
      let!(:group_user) { create(:group_user, user_id: user_1.id, group_id: group.id) }

      before do
        patch accept_api_group_user_path(group_id: group.id, id: group_user.id), {}, env
        @json = JSON.parse(response.body)
      end

      example '400が返ってくること' do
        expect(response).not_to be_success
        expect(response.status).to eq 400
      end
    end
  end

  describe 'DELETE /api/v1/groups/:group_id/users/:id' do
    context 'ログインユーザがそのグループに所属している場合' do
      let!(:group_user) { create(:group_user, user_id: sign_in_user.id, group_id: group.id) }

      before do
        delete api_group_user_path(group_id: group.id, id: group_user.id), {}, env
      end

      example '204が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 204
      end
    end

    context 'ログインユーザがそのグループに所属していなかった場合' do
      let(:user_1) { create(:user, email: 'love-soccer1@example.com', account: 'Neymar') }
      let!(:group_user) { create(:group_user, user_id: user_1.id, group_id: group.id) }

      before do
        delete api_group_user_path(group_id: group.id, id: group_user.id), {}, env
      end

      example '400が返ってくること' do
        expect(response).not_to be_success
        expect(response.status).to eq 400
      end
    end
  end
end
