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

  describe 'POST /api/users' do
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

  describe 'PATCH /api/users/:id' do
    let!(:user) { create(:user, username: 'goroumaru') }

    context '正しいパラメータを送った場合' do
      before do
        patch api_user_path(user), { user:{ username: 'ganbare_goemon' } }, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータが取得されていること' do
        expect(@json['username']).to eq 'ganbare_goemon'
      end
    end

    context '存在しないidを指定' do
      before do
        patch api_user_path(id: 10000), { user:{ username: 'ganbare_goemon' } }, env
        @json = JSON.parse(response.body)
      end

      example '404が返ってくること' do
        expect(response).not_to be_success
        expect(response.status).to eq 404
      end

      example '適切なエラーメッセージが返されること' do
        expect(@json['error']).to eq '指定されたIDのユーザが見つかりません'
      end
    end
  end

  describe 'POST /api/users/sign_in' do
    before do
      @user = create(:user, account: 'deikun_char', email: 'red-suisei@example.com', password: 'password1!')
    end

    context '正しいパラメータを送った場合' do
      before do
        post sign_in_api_users_path, { account: 'deikun_char', password: 'password1!' }
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータが取得されていること' do
        expect(@json['account']).to eq 'deikun_char'
      end

      example '新しくtokenが発行されていること' do
        expect(@json['token']).not_to eq @user.token
      end
    end

    context '不正なパラメータ(account)を送った場合' do
      before do
        post sign_in_api_users_path, { account: 'nise_char', password: 'password1!' }
        @json = JSON.parse(response.body)
      end

      example '401が返ってくること' do
        expect(response).not_to be_success
        expect(response.status).to eq 401
      end

      example '適切なエラーメッセージが返されること' do
        expect(@json['error']).to eq 'アカウント名かパスワードが正しくありません'
      end
    end

    context '不正なパラメータ(password)を送った場合' do
      before do
        post sign_in_api_users_path, { account: 'deikun_char', password: 'password100!' }
        @json = JSON.parse(response.body)
      end

      example '401が返ってくること' do
        expect(response).not_to be_success
        expect(response.status).to eq 401
      end

      example '適切なエラーメッセージが返されること' do
        expect(@json['error']).to eq 'アカウント名かパスワードが正しくありません'
      end
    end
  end
end
