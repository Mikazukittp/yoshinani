RSpec.describe Payment do
  describe 'validation' do
    describe '#amount' do
      let(:payment) { Payment.new(amount: amount) }

      context '正常系' do
        let(:amount) { 10000 }

        it { expect(payment.errors_on(:amount)).to be_empty }
      end

      context '空の場合' do
        let(:amount) { nil }

        it { expect(payment.errors_on(:amount)).to include('金額を入力してください') }
      end

      context '負の値の場合' do
        let(:amount) { -10000 }

        it { expect(payment.errors_on(:amount)).to include('金額は0以上の値にしてください') }
      end

      context 'integer以外の値の場合' do
        let(:amount) { 'たくさん' }

        it { expect(payment.errors_on(:amount)).to include('金額は数値で入力してください') }
      end
    end

    describe '#event' do
      let(:payment) { Payment.new(event: event) }

      context '正常系' do
        let(:event) { '魔界トーナメント' }

        it { expect(payment.errors_on(:event)).to be_empty }
      end

      context '空の場合' do
        let(:event) { nil }

        it { expect(payment.errors_on(:event)).to include('イベントを入力してください') }
      end

      context '30文字の場合' do
        let(:event) { 'あ' * 30 }

        it { expect(payment.errors_on(:event)).to be_empty }
      end

      context '31文字の場合' do
        let(:event) { 'あ' * 31 }

        it { expect(payment.errors_on(:event)).to include('イベントは30文字以内で入力してください')}
      end

      context '精算の場合' do
        let(:payment) { Payment.new(event: nil, is_repayment: true) }

        example 'nilでもバリデーションエラーにならないこと' do
          expect(payment.errors_on(:event)).to be_empty
        end
      end
    end

    describe '#description' do
      let(:payment) { Payment.new(description: description) }

      context '正常系' do
        let(:description) { '戸愚呂（弟）がパフォーマンスで持ってきた会場用の石みたいなやつ代' }

        it { expect(payment.errors_on(:description)).to be_empty }
      end

      context '空の場合' do
        let(:description) { nil }

        it { expect(payment.errors_on(:description)).to include('説明を入力してください') }
      end

      context '100文字の場合' do
        let(:description) { 'あ' * 100 }

        it { expect(payment.errors_on(:description)).to be_empty }
      end

      context '101文字の場合' do
        let(:description) { 'あ' * 101 }

        it { expect(payment.errors_on(:description)).to include('説明は100文字以内で入力してください')}
      end

      context '精算の場合' do
        let(:payment) { Payment.new(description: nil, is_repayment: true) }

        example 'nilでもバリデーションエラーにならないこと' do
          expect(payment.errors_on(:description)).to be_empty
        end
      end
    end

    describe '#date' do
      let(:payment) { Payment.new(date: date) }

      context '正常系' do
        let(:date) { '2015-01-04' }

        it { expect(payment.errors_on(:date)).to be_empty }
      end

      context '空の場合' do
        let(:date) { nil }

        it { expect(payment.errors_on(:date)).to include('日付を入力してください') }
      end

      context 'date以外の値の場合' do
        let(:date) { 'ふがふが' }

        it { expect(payment.errors_on(:date)).to include('は日付ではありません') }
      end
    end

    describe '#group_id' do
      let(:payment) { Payment.new(group_id: group_id) }

      context '正常系' do
        let(:group_id) { 1 }

        it { expect(payment.errors_on(:group_id)).to be_empty }
      end

      context '空の場合' do
        let(:group_id) { nil }

        it { expect(payment.errors_on(:group_id)).to include('Groupを入力してください') }
      end
    end

    describe '#paid_user_id' do
      let(:payment) { Payment.new(paid_user_id: paid_user_id, group_id: 1) }
      let(:group_id) { 1 }

      context '正常系' do
        let(:paid_user_id) { 1 }

        before do
          create(:user, id: paid_user_id)
          create(:group, id: group_id)
          create(:group_user, user_id: paid_user_id, group_id: group_id)
        end

        it { expect(payment.errors_on(:paid_user_id)).to be_empty }
      end

      context '空の場合' do
        let(:paid_user_id) { nil }

        it { expect(payment.errors_on(:paid_user_id)).to include('立替者の会員番号を入力してください') }
      end

      context 'paid_user_idに紐づくuserが存在しない場合' do
        let(:paid_user_id) { 1 }

        before do
          create(:group, id: group_id)
        end

        it { expect(payment.errors_on(:paid_user_id)).to include('指定されたuserは存在しません') }
      end

      context 'paid_user_idがgroup_idのグループに所属していない場合' do
        let(:paid_user_id) { 1 }

        before do
          create(:user, id: paid_user_id)
          create(:group, id: group_id)
        end

        it { expect(payment.errors_on(:paid_user_id)).to include('指定されたgroupに所属されておりません') }
      end
    end
  end

  describe 'pagenation' do
    let!(:user) { create(:user, id: 1) }
    let!(:group) { create(:group, id: 1) }

    before do
      create(:group_user, user_id: user.id, group_id: group.id)
    end

    describe '#pagenate_next' do
      context 'paymentを引数で指定していない場合' do
        before do
          30.times {|i| create(:payment, id: i + 1, group_id: group.id, paid_user_id: user.id)}
        end

        example '20件で区切られていること' do
          expect(Payment.pagenate_next().count).to eq 20
        end

        example '最新のものを取得できていること' do
          expect(Payment.pagenate_next().first.id).to eq 30
        end
      end

      context 'paymentを引数で指定している場合' do
        before do
          create(:payment, id: 200, date: '2016-06-15', group_id: group.id, paid_user_id: user.id)
          create(:payment, id: 100, date: '2015-06-15', group_id: group.id, paid_user_id: user.id)
          create(:payment, id: 120, date: '2014-06-15', group_id: group.id, paid_user_id: user.id)
          create(:payment, id: 110, date: '2014-06-15', group_id: group.id, paid_user_id: user.id)
        end

        let(:last_payment) { Payment.find(200) }

        example '第一ソートDate, 第二ソートIdで並んでいること' do
          expect(Payment.pagenate_next(last_payment).pluck(:id)).to eq [100, 120, 110]
        end
      end
    end

    describe '#pagenate_prev' do
      describe 'num of list' do
        before do
          30.times {|i| create(:payment, id: i + 1, group_id: group.id, paid_user_id: user.id)}
        end

        example '20件で区切られていること' do
          expect(Payment.pagenate_next().count).to eq 20
        end
      end

      describe 'sort' do
        before do
          create(:payment, id: 200, date: '2016-06-15', group_id: group.id, paid_user_id: user.id)
          create(:payment, id: 100, date: '2015-06-15', group_id: group.id, paid_user_id: user.id)
          create(:payment, id: 120, date: '2014-06-15', group_id: group.id, paid_user_id: user.id)
          create(:payment, id: 110, date: '2014-06-15', group_id: group.id, paid_user_id: user.id)
        end

        let(:first_payment) { Payment.find(110) }

        example '第一ソートDate, 第二ソートIdで並んでいること' do
          expect(Payment.pagenate_prev(first_payment).pluck(:id)).to eq [120, 100, 200]
        end
      end
    end
  end
end
