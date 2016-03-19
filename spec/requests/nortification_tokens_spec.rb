RSpec.describe 'NortificationToken', type: :request do
  let(:sign_in_user) { create(:user, email: 'sign-in-email@example.com', account: 'sign_in_user') }
  let(:env) { { UID: sign_in_user.id, TOKEN: sign_in_user.token } }
  let(:group) { create(:group, name: '幻影旅団', description: '所詮虫けらの戯言、俺の心には響かない') }

  describe 'POST /api/oauth_registration' do
    let(:params) {
      {
        nortification_token: {
          device_token: 'hogehoge',
          device_type: 'ios'
        }
      }
    }

    context '初回作成の場合' do
      before do
        post api_nortification_tokens_path, params, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータの一覧が取得されていること' do
        expect(@json['email']).to eq 'sign-in-email@example.com'
      end
    end

    context 'すでに同じtokenが存在している場合' do
      before do
        create(:nortification_token, device_token: 'hogehoge', user_id: sign_in_user.id)
        post api_nortification_tokens_path, params, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータの一覧が取得されていること' do
        expect(@json['message']).to eq '指定されたPUSHキーはすでに存在しています'
      end
    end
  end

  describe 'PATCH /api/oauth_registration' do
    let!(:old_token) { create(:nortification_token, device_token: 'fugafuga', user_id: sign_in_user.id) }
    let(:params) {
      {
        nortification_token: {
          auth_device_token: old_token.device_token,
          device_token: 'hogehoge',
          device_type: 'ios'
        }
      }
    }

    before do
      patch api_nortification_tokens_path, params, env
      @json = JSON.parse(response.body)
    end

    example '200が返ってくること' do
      expect(response).to be_success
      expect(response.status).to eq 200
    end

    example '期待したデータの一覧が取得されていること' do
      expect(@json['email']).to eq 'sign-in-email@example.com'
    end
  end

  describe 'DELETE /api/oauth_registration' do
    let!(:old_token) { create(:nortification_token, device_token: 'fugafuga', user_id: sign_in_user.id) }
    let(:params) {
      {
        nortification_token: {
          auth_device_token: old_token.device_token
        }
      }
    }

    before do
      delete api_nortification_tokens_path, params, env
      @json = JSON.parse(response.body)
    end

    example '200が返ってくること' do
      expect(response).to be_success
      expect(response.status).to eq 200
    end

    example '期待したデータの一覧が取得されていること' do
      expect(@json['email']).to eq 'sign-in-email@example.com'
    end
  end
end