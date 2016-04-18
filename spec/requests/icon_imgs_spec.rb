include ActionDispatch::TestProcess

RSpec.describe 'IconImgs', type: :request do
  let(:sign_in_user) { create(:user, email: 'sign-in-email@example.com', account: 'sign_in_user') }
  let(:env) { { UID: sign_in_user.id, TOKEN: sign_in_user.token } }

  describe 'POST /api/v1/users/:user_id/icon_imgs' do
    before do
      @file = fixture_file_upload("/images/sample.jpg", "image/jpg", true)
    end

    context '正常系' do
      let(:params) {{
        icon_img: @file
      }}

      before do
        post api_user_icon_imgs_path(sign_in_user), params, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータが取得されていること' do
        expect(@json['icon_img']).not_to be_empty
      end
    end

    context '異常系' do
      context 'ログインユーザ以外のユーザのiconを変更しようとした場合' do
        let(:params) {{
          icon_img: @file
        }}

        before do
          post api_user_icon_imgs_path(user_id: sign_in_user.id + 1), params, env
          @json = JSON.parse(response.body)
        end

        example '400が返ってくること' do
          expect(response).not_to be_success
          expect(response.status).to eq 400
        end

        example '期待したデータが取得されていること' do
          expect(@json['message']).to eq '許可されていない操作です'
        end
      end
    end
  end
end
