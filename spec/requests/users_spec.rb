require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:sign_in_user) { create(:user, email: 'sign-in-email@example.com', account: 'sign_in_user') }
  let(:env) { { UID: sign_in_user.id, TOKEN: sign_in_user.token } }

  describe 'GET /api/users' do
    let(:user_1) { create(:user, email: 'love-soccer1@example.com', account: 'Neymar') }
    let(:user_2) { create(:user, email: 'love-soccer2@example.com', account: 'Puyol') }
    let(:group) { create(:group) }

    context '指定したグループにuserが存在する場合' do
      before do
        create(:group_user, user_id: user_1.id, group_id: group.id)
        create(:group_user, user_id: user_2.id, group_id: group.id)
        get api_users_path, {group_id: group.id}, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータの一覧が取得されていること' do
        expect(@json[0]['account']).to eq 'Neymar'
        expect(@json[1]['account']).to eq 'Puyol'
      end
    end

    context '指定したグループにuserが存在しなかった場合' do
      let(:group_2) { create(:group) }

      before do
        create(:group_user, user_id: user_1.id, group_id: group.id)
        create(:group_user, user_id: user_2.id, group_id: group.id)
        get api_users_path, {group_id: group_2.id}, env
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

    context 'グループIDを指定しなかった場合' do
      before do
        create(:group_user, user_id: user_1.id, group_id: group.id)
        create(:group_user, user_id: user_2.id, group_id: group.id)
        get api_users_path, {}, env
        @json = JSON.parse(response.body)
      end

      example '500が返ってくること' do
        expect(response).not_to be_success
        expect(response.status).to eq 500
      end

      example '適切なエラーメッセージが返されること' do
        expect(@json['error']).to eq 'グループidが入力されていません'
      end
    end
  end

  describe 'GET /api/users/:id' do
    let(:user) { create(:user, username: 'goroumaru') }

    before do
      get api_user_path(user), {}, env
      @json = JSON.parse(response.body)
    end

    example '200が返ってくること' do
      expect(response).to be_success
      expect(response.status).to eq 200
    end

    example '期待したデータが取得されていること' do
      expect(@json['username']).to eq 'goroumaru'
    end
  end

  describe 'POST /api/users/sign_in' do
    before do
      @user = create(:user, account: 'deikun_char', email: 'red-suisei@example.com', password: 'password1!')
      @user.new_token
      @user.hash_password
      @user.save!
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