RSpec.describe 'Groups', type: :request do
  let(:sign_in_user) { create(:user, email: 'sign-in-email@example.com', account: 'sign_in_user', password: 'password1!') }
  let(:env) { { UID: sign_in_user.id, TOKEN: sign_in_user.token } }

  describe 'PATCH /api/passwords' do
    context '正しいパラメータを送った場合' do
      let(:params) {{
        user: {
          password: 'password1!',
          new_password: 'password2!',
          new_password_confirmation: 'password2!'
        }
      }}

      before do
        patch api_passwords_path, params, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータが取得されていること' do
        expect(@json['account']).to eq 'sign_in_user'
      end

      example '更新したパスワードでログインできること' do
        post sign_in_api_users_path, { account: 'sign_in_user', password: 'password2!' }

        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '古いパスワードではログインできないこと' do
        post sign_in_api_users_path, { account: 'sign_in_user', password: 'password1!' }

        expect(response).not_to be_success
        expect(response.status).to eq 401
      end
    end

    context '不正なパラメータを送った場合' do
      context 'passwordが間違っている場合' do
        let(:params) {{
          user: {
            password: 'password3!',
            new_password: 'password2!',
            new_password_confirmation: 'password2!'
          }
        }}

        before do
          patch api_passwords_path, params, env
          @json = JSON.parse(response.body)
        end

        example '400が返ってくること' do
          expect(response).not_to be_success
          expect(response.status).to eq 400
        end

        example '適切なエラーメッセージが返されること' do
          expect(@json['message']).to eq 'パスワードが正しくありません'
        end
      end

      context '確認用パスワードが入力されたパスワードと一致しない場合' do
        let(:params) {{
          user: {
            password: 'password1!',
            new_password: 'password2!',
            new_password_confirmation: 'password3!'
          }
        }}

        before do
          patch api_passwords_path, params, env
          @json = JSON.parse(response.body)
        end

        example '400が返ってくること' do
          expect(response).not_to be_success
          expect(response.status).to eq 400
        end

        example '適切なエラーメッセージが返されること' do
          expect(@json['message']).to eq '新しいパスワードと確認用パスワードが一致していません'
        end
      end

      context 'パスワードが不正な値の場合' do
        let(:params) {{
          user: {
            password: 'password1!',
            new_password: 'pass',
            new_password_confirmation: 'pass'
          }
        }}

        before do
          patch api_passwords_path, params, env
          @json = JSON.parse(response.body)
        end

        example '400が返ってくること' do
          expect(response).not_to be_success
          expect(response.status).to eq 400
        end

        example '適切なエラーメッセージが返されること' do
          expect(@json['message']).to eq 'パスワードの更新に失敗しました'
        end
      end

      context 'パラメータが不正な形式の場合' do
        let(:params) {{
          password: 'password1!',
          new_password: 'pass',
          new_password_confirmation: 'pass'
        }}

        before do
          patch api_passwords_path, params, env
          @json = JSON.parse(response.body)
        end

        example '400が返ってくること' do
          expect(response).not_to be_success
          expect(response.status).to eq 400
        end

        example '適切なエラーメッセージが返されること' do
          expect(@json['message']).to eq 'パラメータの形式が不正です'
        end
      end
    end
  end

  describe 'POST /api/passwords/init' do
    let!(:target_user) { create(:user, account: 'graymon', email: 'degimon@example.com') }
    context '正しいパラメータを送った場合' do
      let(:params) {{
        user: {
          account: target_user.account,
          email: target_user.email
        }
      }}

      before do
        post init_api_passwords_path, params
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータが取得されていること' do
        expect(@json['message']).to eq 'パスワード再設定用のメールを送信いたしました'
      end
    end

    context '不正なパラメータを送った場合' do
      context 'accountが間違っている場合' do
        let(:params) {{
          user: {
            account: 'hogehoge',
            email: target_user.email
          }
        }}

        before do
          post init_api_passwords_path, params
          @json = JSON.parse(response.body)
        end

        example '400が返ってくること' do
          expect(response).not_to be_success
          expect(response.status).to eq 400
        end

        example '期待したデータが取得されていること' do
          expect(@json['message']).to eq '一致する情報はみつかりませんでした。'
        end
      end

      context 'emailが間違っている場合' do
        let(:params) {{
          user: {
            account: target_user.account,
            email: 'hoge@example.com'
          }
        }}

        before do
          post init_api_passwords_path, params
          @json = JSON.parse(response.body)
        end

        example '400が返ってくること' do
          expect(response).not_to be_success
          expect(response.status).to eq 400
        end

        example '期待したデータが取得されていること' do
          expect(@json['message']).to eq '一致する情報はみつかりませんでした。'
        end
      end
    end
  end

  describe 'PATCH /api/passwords/reset' do
    let!(:target_user) { create(:user,
      account: 'target',
      reset_password_token: SecureRandom.base64(10),
      reset_password_at: Time.now)
    }

    context '正しいパラメータを送った場合' do
      let(:params) {{
        user: {
          reset_password_token: target_user.reset_password_token,
          new_password: 'hogehoge30',
          new_password_confirmation: 'hogehoge30'
        }
      }}

      before do
        patch reset_api_passwords_path, params
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータが取得されていること' do
        expect(@json['account']).to eq 'target'
        expect(@json['reset_password_token']).to be_nil
      end
    end

    context '不正なパラメータを送った場合' do
      context 'パスワードが確認用と一致しない場合' do
        let(:params) {{
          user: {
            reset_password_token: target_user.reset_password_token,
            new_password: 'hogehoge4000',
            new_password_confirmation: 'hogehoge30'
          }
        }}

        before do
          patch reset_api_passwords_path, params
          @json = JSON.parse(response.body)
        end

        example '400が返ってくること' do
          expect(response).not_to be_success
          expect(response.status).to eq 400
        end

        example '期待したデータが取得されていること' do
          expect(@json['message']).to eq '新しいパスワードと確認用パスワードが一致していません'
        end
      end

      context '再設定用のパスワードが不正な場合' do
        let(:params) {{
          user: {
            reset_password_token: SecureRandom.base64(10),
            new_password: 'hogehoge30',
            new_password_confirmation: 'hogehoge30'
          }
        }}

        before do
          patch reset_api_passwords_path, params
          @json = JSON.parse(response.body)
        end

        example '400が返ってくること' do
          expect(response).not_to be_success
          expect(response.status).to eq 400
        end

        example '期待したデータが取得されていること' do
          expect(@json['message']).to eq '再設定用の認証キーが正しくありません'
        end
      end

      context '有効期限が切れた再設定用パスワードの場合' do
        let!(:target_user) { create(:user,
          reset_password_token: SecureRandom.base64(10),
          reset_password_at: 31.minutes.ago)
        }

        let(:params) {{
          user: {
            reset_password_token: target_user.reset_password_token,
            new_password: 'hogehoge30',
            new_password_confirmation: 'hogehoge30'
          }
        }}

        before do
          patch reset_api_passwords_path, params
          @json = JSON.parse(response.body)
        end

        example '400が返ってくること' do
          expect(response).not_to be_success
          expect(response.status).to eq 400
        end

        example '期待したデータが取得されていること' do
          expect(@json['message']).to eq '再設定用の認証キーの有効期限が切れています'
        end
      end
    end
  end
end
