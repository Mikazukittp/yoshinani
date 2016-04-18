RSpec.describe 'OauthRegistration', type: :request do
  let(:sign_in_user) { create(:user, email: 'sign-in-email@example.com', account: 'sign_in_user') }
  let(:env) { { UID: sign_in_user.id, TOKEN: sign_in_user.token } }

  describe 'GET /api/oauth_registrations' do
    let(:oauth) { create(:oauth) }

    before do
      create(:oauth_registration, user_id: sign_in_user.id, oauth_id: oauth.id, third_party_id: 1234)
    end

    context '正常系' do
      before do
        get api_oauth_registrations_path, {}, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータが取得されていること' do
        expect(@json.first['oauth_id']).to eq oauth.id
      end
    end
  end

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
        context '画像が取得できなかった場合' do
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

        context '画像が取得できた場合' do
          let(:params) {{
            oauth_registration: {
              third_party_id: "22222",
              oauth_id: oauth.id,
              sns_hash_id: Digest::MD5.hexdigest("22222" + ENV["YOSHINANI_SALT"]),
              icon_img: "https://s3-ap-northeast-1.amazonaws.com/yoshinani/uploads/user/icon_img/3/Ruby_3_0.jpg"
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
            expect(@json['icon_img']['url']).not_to be_nil
          end
        end
      end

      context '画像のURLが存在しない場合' do
        let(:params) {{
          oauth_registration: {
            third_party_id: "22222",
            oauth_id: oauth.id,
            sns_hash_id: Digest::MD5.hexdigest("22222" + ENV["YOSHINANI_SALT"]),
            icon_img: "http://example.com/example.jpg"
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
          expect(@json['icon_img']['url']).to be_nil
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

  describe 'POST /api/oauth_registration/add' do
    let(:oauth) { create(:oauth) }

    context '正常系' do
      let(:params) {{
        oauth_registration: {
          third_party_id: "1234",
          oauth_id: oauth.id,
          sns_hash_id: Digest::MD5.hexdigest("1234" + ENV["YOSHINANI_SALT"])
        }
      }}

      before do
        post add_api_oauth_registrations_path, params, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータが取得されていること' do
        expect(@json.first['oauth_id']).to eq oauth.id
      end
    end

    context '異常系' do
      context '登録していないoauth_idの場合' do
        let(:params) {{
          oauth_registration: {
            third_party_id: "1234",
            oauth_id: oauth.id + 1,
            sns_hash_id: Digest::MD5.hexdigest("1234" + ENV["YOSHINANI_SALT"])
          }
        }}

        before do
          post add_api_oauth_registrations_path, params, env
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
            third_party_id: "4321",
            oauth_id: oauth.id,
            sns_hash_id: Digest::MD5.hexdigest("1234" + ENV["YOSHINANI_SALT"])
          }
        }}

        before do
          post add_api_oauth_registrations_path, params, env
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

  describe 'DELETE /api/oauth_registration/add' do
    let(:oauth) { create(:oauth) }

    before do
      create(:oauth_registration, user_id: sign_in_user.id, oauth_id: oauth.id, third_party_id: 1234)
    end

    context '正常系' do
      let(:params) {{
        oauth_registration: {
          oauth_id: oauth.id,
        }
      }}

      before do
        delete api_oauth_registrations_path, params, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータが取得されていること' do
        expect(@json).to be_empty
      end
    end
  end
end
