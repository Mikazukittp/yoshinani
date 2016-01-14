require 'rails_helper'

RSpec.describe 'Groups', type: :request do
  let(:sign_in_user) { create(:user, email: 'sign-in-email@example.com', account: 'sign_in_user') }
  let(:env) { { UID: sign_in_user.id, TOKEN: sign_in_user.token } }
  let(:group) { create(:group, name: '幻影旅団', description: '所詮虫けらの戯言、俺の心には響かない') }

  describe 'GET /api/v1/groups' do
    context '指定されたユーザがグループに所属している場合' do
      before do
        create(:group_user, user_id: sign_in_user.id, group_id: group.id)
        get api_groups_path, {}, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータの一覧が取得されていること' do
        expect(@json[0]['name']).to eq '幻影旅団'
      end
    end

    context '指定されたユーザがグループに所属していなかった場合' do
      before do
        get api_groups_path, {}, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '空のjsonが取得されること' do
        expect(@json).to be_empty
      end
    end
  end

  describe 'GET /api/groups/:id' do
    context '自分が所属するグループを指定した場合' do
      before do
        create(:group_user, user_id: sign_in_user.id, group_id: group.id)
        get api_group_path(group), {}, env
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

    context '自分が所属していないグループを指定した場合' do
      before do
        get api_group_path(group), {}, env
        @json = JSON.parse(response.body)
      end

      example '404が返ってくること' do
        expect(response).not_to be_success
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST /api/groups' do
    let(:group_params) {{
      group: {
        name: '十本刀',
        description: '尖閣は入れなかった'
      }
    }}

    context '正しいパラメータを送った場合' do
      before do
        post api_groups_path, group_params, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータが取得されていること' do
        expect(@json['name']).to eq '十本刀'
      end
    end
  end

  describe 'PATCH /api/groups/:id' do
    let!(:group_1) { create(:group, name: 'ふんばり温泉チーム') }
    let!(:group_2) { create(:group, name: 'THE蓮') }

    before do
      create(:group_user, user_id: sign_in_user.id, group_id: group_1.id)
    end

    context '正しいパラメータを送った場合' do
      before do
        patch api_group_path(group_1), { group:{ name: 'X-LAWS' } }, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータが取得されていること' do
        expect(@json['name']).to eq 'X-LAWS'
      end
    end

    context '自分が所属しないグループのidを指定した場合' do
      before do
        patch api_group_path(group_2), { group:{ name: 'X-LAWS' } }, env
        @json = JSON.parse(response.body)
      end

      example '404が返ってくること' do
        expect(response).not_to be_success
        expect(response.status).to eq 404
      end

      example '適切なエラーメッセージが返されること' do
        expect(@json['error']).to eq '指定されたIDのグループが見つかりません'
      end
    end
  end

  describe 'DELETE /api/groups/:id' do
    let!(:group_1) { create(:group, name: '南斗五車星') }

    before do
      create(:group_user, user_id: sign_in_user.id, group_id: group_1.id)
    end

    context '自分が所属しているグループのidを指定した場合' do
      before do
        delete api_group_path(group_1), {}, env
        @json = JSON.parse(response.body)
        @group = Group.find_by(id: group_1.id)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '指定したデータが削除されていること' do
        expect(@json['name']).to eq '南斗五車星'
        expect(@group).to be_nil
      end
    end
  end
end
