RSpec.describe 'ApplicationController', type: :request do
  let(:sign_in_user) { create(:user, email: 'sign-in-email@example.com', account: 'sign_in_user') }
  let(:env) { { UID: sign_in_user.id, TOKEN: sign_in_user.token } }
  let(:group) { create(:group, name: '幻影旅団', description: '所詮虫けらの戯言、俺の心には響かない') }

  describe 'Render 404 error' do
    context '存在しないルーティングにアクセスしようとした場合' do
      before do
        create(:group_user, user_id: sign_in_user.id, group_id: group.id)
        get 'hogehoge/fugafuga', {}, env
        @json = JSON.parse(response.body)
      end

      example '404が返ってくること' do
        expect(response).not_to be_success
        expect(response.status).to eq 404
      end

      example '期待したデータが取得されていること' do
        expect(@json['message']).to eq '404 error '
      end
    end
  end

  describe 'authenticate' do
    context '異常系' do
      context 'UIDが不正の場合' do
        before do
          create(:group_user, user_id: sign_in_user.id, group_id: group.id)
          get api_group_path(group), {}, { UID: sign_in_user.id + 1, TOKEN: sign_in_user.token }
          @json = JSON.parse(response.body)
        end

        example '401が返ってくること' do
          expect(response).not_to be_success
          expect(response.status).to eq 401
        end

        example '期待したデータが取得されていること' do
          expect(@json['message']).to eq '認証に失敗しました'
        end
      end

      context 'TOKENが不正の場合' do
        before do
          create(:group_user, user_id: sign_in_user.id, group_id: group.id)
          get api_group_path(group), {}, { UID: sign_in_user.id, TOKEN: sign_in_user.token + 'hoge' }
          @json = JSON.parse(response.body)
        end

        example '401が返ってくること' do
          expect(response).not_to be_success
          expect(response.status).to eq 401
        end

        example '期待したデータが取得されていること' do
          expect(@json['message']).to eq '認証に失敗しました'
        end
      end
    end
  end
end
