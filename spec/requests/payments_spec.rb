require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:sign_in_user) { create(:user, email: 'sign-in-email@example.com', account: 'sign_in_user') }
  let(:env) { { UID: sign_in_user.id, TOKEN: sign_in_user.token } }

  describe 'GET /api/payments' do
    let(:user_1) { create(:user, email: 'love-soccer1@example.com', account: 'Neymar') }
    let(:group) { create(:group) }

    before do
      create(:payment, event: '天下一武道会', paid_user_id: user_1.id, group_id: group.id)
    end

    context '指定したグループに自分が所属している場合' do
      before do
        create(:payment, event: '天下一武道会', paid_user_id: user_1.id, group_id: group.id)
        create(:group_user, user_id: sign_in_user.id, group_id: group.id)

        get api_payments_path, {group_id: group.id}, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータの一覧が取得されていること' do
        expect(@json[0]['event']).to eq '天下一武道会'
      end
    end

    context '指定したグループに自分が所属していない場合' do
      before do
        create(:payment, event: '天下一武道会', paid_user_id: user_1.id, group_id: group.id)

        get api_payments_path, {group_id: group.id}, env
        @json = JSON.parse(response.body)
      end

      example '400が返ってくること' do
        expect(response).not_to be_success
        expect(response.status).to eq 400
      end
    end
  end

  describe 'GET /api/payment/:id' do
    let(:user_1) { create(:user, email: 'love-soccer1@example.com', account: 'Neymar') }
    let(:group) { create(:group) }
    let(:payment) { create(:payment, event: '銀河一武道会', paid_user_id: user_1.id, group_id: group.id) }

    context '指定したグループに自分が所属している場合' do
      before do
        create(:group_user, user_id: sign_in_user.id, group_id: group.id)

        get api_payment_path(payment), {}, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータの一覧が取得されていること' do
        expect(@json['event']).to eq '銀河一武道会'
      end
    end

    context '指定したグループに自分が所属していない場合' do
      before do
        get api_payment_path(payment), {group_id: group.id}, env
        @json = JSON.parse(response.body)
      end

      example '404が返ってくること' do
        expect(response).not_to be_success
        expect(response.status).to eq 404
      end
    end
  end
end