RSpec.describe 'Users', type: :request do
  let(:sign_in_user) { create(:user, email: 'sign-in-email@example.com', account: 'sign_in_user') }
  let(:env) { { UID: sign_in_user.id, TOKEN: sign_in_user.token } }

  describe 'GET /api/payments' do
    let(:user_1) { create(:user, email: 'love-soccer1@example.com', account: 'Neymar') }
    let(:group) { create(:group) }

    before do
      create(:group_user, user_id: user_1.id, group_id: group.id)
      create(:payment, event: '天下一武道会', paid_user_id: user_1.id, group_id: group.id)
    end

    context '指定したグループに自分が所属している場合' do
      before do
        create(:group_user, user_id: sign_in_user.id, group_id: group.id)
        create(:payment, event: '銀河一武道会', paid_user_id: user_1.id, group_id: group.id, deleted_at: Time.now)

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

      example '削除されたデータは取得されていないこと' do
        expect(@json[1]).to be_nil
      end
    end

    context '指定したグループに自分が所属していない場合' do
      before do
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
        create(:group_user, user_id: user_1.id, group_id: group.id)
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
        create(:group_user, user_id: user_1.id, group_id: group.id)

        get api_payment_path(payment), {group_id: group.id}, env
        @json = JSON.parse(response.body)
      end

      example '404が返ってくること' do
        expect(response).not_to be_success
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST /api/payments' do
    let(:user_1) { create(:user, email: 'hunter1@example.com', account: 'hunter1') }
    let(:user_2) { create(:user, email: 'hunter2@example.com', account: 'hunter2') }
    let(:group) { create(:group) }
    let(:payment_params) {{
      payment: {
        amount: 10000,
        group_id: group.id,
        event: 'hoge',
        description: 'hogehoge',
        date: Time.now,
        paid_user_id: sign_in_user.id,
        is_repayment: false,
        participants_ids: [
          user_1.id,
          user_2.id
        ]
      }
    }}

    context '正しいパラメータを送った場合' do
      before do
        create(:group_user, user_id: sign_in_user.id, group_id: group.id)
        create(:group_user, user_id: user_1.id, group_id: group.id)
        create(:group_user, user_id: user_2.id, group_id: group.id)

        post api_payments_path, payment_params, env
        @json = JSON.parse(response.body)
      end

      example '201が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 201
      end

      example '期待したデータが取得されていること' do
        expect(@json['amount']).to eq 10000
        expect(@json['paid_user']['account']).to eq 'sign_in_user'
        expect(@json['participants'][0]['account']).to eq 'hunter1'
      end
    end

    context 'グループに存在しないparticipantsがいる場合' do
      before do
        create(:group_user, user_id: sign_in_user.id, group_id: group.id)
        create(:group_user, user_id: user_2.id, group_id: group.id)

        post api_payments_path, payment_params, env
        @json = JSON.parse(response.body)
      end

      example '201が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 201
      end

      example '期待したデータが取得されていること' do
        expect(@json['amount']).to eq 10000
        expect(@json['paid_user']['account']).to eq 'sign_in_user'
        expect(@json['participants'][0]['account']).to eq 'hunter2'
      end
    end

    context 'グループに存在しないユーザが作成した場合' do
      before do
        post api_payments_path, payment_params, env
        @json = JSON.parse(response.body)
      end

      example '500が返ってくること' do
        expect(response).not_to be_success
        expect(response.status).to eq 500
      end
    end
  end

  describe 'PATCH /api/payment/:id' do
    let(:user_1) { create(:user, email: 'hunter1@example.com', account: 'hunter1') }
    let(:user_2) { create(:user, email: 'hunter2@example.com', account: 'hunter2') }
    let(:group) { create(:group) }
    let(:payment_params) {{
      payment: {
        amount: 100000,
        group_id: group.id,
        event: '銀河一武道会',
        description: 'hogehoge',
        date: Time.now,
        paid_user_id: sign_in_user.id,
        is_repayment: false,
        participants_ids: [
          user_1.id
        ]
      }
    }}

    before do
      create(:group_user, user_id: sign_in_user.id, group_id: group.id)
      create(:group_user, user_id: user_1.id, group_id: group.id)
      create(:group_user, user_id: user_2.id, group_id: group.id)
    end

    context '正しいパラメータを送った場合' do
      let!(:payment) { create(:payment,
        event: '天下一武道会',
        paid_user_id: sign_in_user.id,
        group_id: group.id

        )
      }

      before do
        create(:total, paid: 200000, user_id: sign_in_user.id, group_id: group.id)

        patch api_payment_path(payment), payment_params, env
        @json = JSON.parse(response.body)
      end

      example '201が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 201
      end

      example '期待したデータが取得されていること' do
        expect(@json['event']).to eq '銀河一武道会'
        #TODO FactoryGirlで作られるpaymentがデフォルトでamount 10000 なので以下の出力となる。見づらいのでいつか直す。
        expect(@json['paid_user']['totals'][0]['paid']).to eq '290000.0'
        expect(@json['participants'][0]['account']).to eq 'hunter1'
      end
    end

    context '指定した精算のpiad_userが自分じゃない場合' do
      let!(:payment) { create(:payment, event: '天下一武道会', paid_user_id: user_1.id, group_id: group.id) }

      before do
        patch api_payment_path(payment), {payment: {event: '銀河一武道会'}}, env
        @json = JSON.parse(response.body)
      end

      example '403が返ってくること' do
        expect(response).not_to be_success
        expect(response.status).to eq 403
      end
    end
  end

  describe 'DELETE /api/payments/:id' do
    let(:user_1) { create(:user, email: 'hunter1@example.com', account: 'hunter1') }
    let(:user_2) { create(:user, email: 'hunter2@example.com', account: 'hunter2') }
    let(:group) { create(:group) }

    before do
      create(:group_user, user_id: sign_in_user.id, group_id: group.id)
      create(:group_user, user_id: user_1.id, group_id: group.id)
      create(:group_user, user_id: user_2.id, group_id: group.id)
      create(:total, user_id: sign_in_user.id, group_id: group.id)
    end

    context '正しいパラメータを送った場合' do
      let!(:payment) { create(:payment, paid_user_id: sign_in_user.id, group_id: group.id) }

      before do
        delete api_payment_path(payment), {}, env
        @json = JSON.parse(response.body)
      end

      example '200が返ってくること' do
        expect(response).to be_success
        expect(response.status).to eq 200
      end

      example '期待したデータが取得されていること' do
        expect(@json['deleted_at']).not_to be_nil
      end

      example '期待したデータが取得されていること' do
        expect(Total.find_by(user_id: sign_in_user.id).paid).to eq 190000
      end
    end

    context '指定した精算のpiad_userが自分じゃない場合' do
      let!(:payment) { create(:payment, paid_user_id: user_1.id, group_id: group.id) }

      before do
        delete api_payment_path(payment), {}, env
        @json = JSON.parse(response.body)
      end

      example '403が返ってくること' do
        expect(response).not_to be_success
        expect(response.status).to eq 403
      end
    end
  end
end
