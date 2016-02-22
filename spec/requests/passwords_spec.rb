require 'rails_helper'

RSpec.describe 'Groups', type: :request do
  let(:sign_in_user) { create(:user, email: 'sign-in-email@example.com', account: 'sign_in_user', password: 'password1!') }
  let(:env) { { UID: sign_in_user.id, TOKEN: sign_in_user.token } }

  describe 'PATCH /api/groups/:id' do
    context '正しいパラメータを送った場合' do
      let(:params) {{
        password: 'password1!',
        new_password: 'password2!',
        new_password_confirmation: 'password2!'
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
          password: 'password3!',
          new_password: 'password2!',
          new_password_confirmation: 'password2!'
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
          expect(@json['error']).to eq 'パスワードが正しくありません'
        end
      end

      context '確認用パスワードが入力されたパスワードと一致しない場合' do
        let(:params) {{
          password: 'password1!',
          new_password: 'password2!',
          new_password_confirmation: 'password3!'
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
          expect(@json['error']).to eq '新しいパスワードと確認用パスワードが一致していません'
        end
      end
    end
  end
end
