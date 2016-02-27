require 'rails_helper'

RSpec.describe 'OauthRegistration', type: :request do

  describe 'POST /api/oauth_registration' do
    let(:oauth) { create(:oauth) }

    context '既に登録されている場合' do
      let(:user) { create(:user, account: 'deikun_char', email: 'red-suisei@example.com', password: 'password1!') }

      before do
        create(:oauth_registration, user_id: user.id, oauth_id: oauth.id, third_party_id: 1234)
      end

      context '正常系' do
        let(:params) {{
          oauth_registration: {
            third_party_id: "1234",
            oauth_id: oauth.id,
            sns_hash_id: Digest::MD5.hexdigest("1234" + ENV["YOSHINANI_SALT"])
          }
        }}

        before do
          post api_oauth_registrations_path, params
          @json = JSON.parse(response.body)
        end

        example '200が返ってくること' do
          expect(response).to be_success
          expect(response.status).to eq 200
        end

        example '期待したデータが取得されていること' do
          expect(@json['account']).to eq 'deikun_char'
        end
      end

      context '登録していないoauth_idの場合' do
        let(:params) {{
          oauth_registration: {
            third_party_id: "1234",
            oauth_id: oauth.id + 1,
            sns_hash_id: Digest::MD5.hexdigest("1234" + ENV["YOSHINANI_SALT"])
          }
        }}

        before do
          post api_oauth_registrations_path, params
          @json = JSON.parse(response.body)
        end

        example '400が返ってくること' do
          expect(response).not_to be_success
          expect(response.status).to eq 400
        end

        example '適切なエラーメッセージが返ってくること' do
          expect(@json['message']).to eq '許可されていないSNSです'
        end
      end

      context 'sns_hash_idが不正な値の場合' do
        let(:params) {{
          oauth_registration: {
            third_party_id: "1234",
            oauth_id: oauth.id,
            sns_hash_id: Digest::MD5.hexdigest("1234" + ENV["YOSHINANI_SALT"] + "hoge")
          }
        }}

        before do
          post api_oauth_registrations_path, params
          @json = JSON.parse(response.body)
        end

        example '400が返ってくること' do
          expect(response).not_to be_success
          expect(response.status).to eq 400
        end

        example '適切なエラーメッセージが返ってくること' do
          expect(@json['message']).to eq '不正な操作です'
        end
      end
    end

    describe '新規に登録する場合' do
      context '正常系' do
        let(:params) {{
          oauth_registration: {
            third_party_id: "22222",
            oauth_id: oauth.id,
            sns_hash_id: Digest::MD5.hexdigest("22222" + ENV["YOSHINANI_SALT"])
          }
        }}

        before do
          post api_oauth_registrations_path, params
          @json = JSON.parse(response.body)
        end

        example '201が返ってくること' do
          expect(response).to be_success
          expect(response.status).to eq 201
        end

        example '期待したデータが取得されていること' do
          expect(@json).not_to be_empty
          expect(@json['account']).to be_nil
        end
      end

      context '登録していないoauth_idの場合' do
        let(:params) {{
          oauth_registration: {
            third_party_id: "22222",
            oauth_id: oauth.id + 1,
            sns_hash_id: Digest::MD5.hexdigest("22222" + ENV["YOSHINANI_SALT"])
          }
        }}

        before do
          post api_oauth_registrations_path, params
          @json = JSON.parse(response.body)
        end

        example '400が返ってくること' do
          expect(response).not_to be_success
          expect(response.status).to eq 400
        end

        example '適切なエラーメッセージが返ってくること' do
          expect(@json['message']).to eq '許可されていないSNSです'
        end
      end

      context 'sns_hash_idが不正な値の場合' do
        let(:params) {{
          oauth_registration: {
            third_party_id: "22222",
            oauth_id: oauth.id,
            sns_hash_id: Digest::MD5.hexdigest("22222" + ENV["YOSHINANI_SALT"] + "hoge")
          }
        }}

        before do
          post api_oauth_registrations_path, params
          @json = JSON.parse(response.body)
        end

        example '400が返ってくること' do
          expect(response).not_to be_success
          expect(response.status).to eq 400
        end

        example '適切なエラーメッセージが返ってくること' do
          expect(@json['message']).to eq '不正な操作です'
        end
      end
    end
  end
end
