require 'rails_helper'

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

        it { expect(payment.errors_on(:amount)).to include('can\'t be blank') }
      end

      context '負の値の場合' do
        let(:amount) { -10000 }

        it { expect(payment.errors_on(:amount)).to include('must be greater than or equal to 0') }
      end

      context 'integer以外の値の場合' do
        let(:amount) { 'たくさん' }

        it { expect(payment.errors_on(:amount)).to include('is not a number') }
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

        it { expect(payment.errors_on(:event)).to include('can\'t be blank') }
      end

      context '30文字の場合' do
        let(:event) { 'あ' * 30 }

        it { expect(payment.errors_on(:event)).to be_empty }
      end

      context '31文字の場合' do
        let(:event) { 'あ' * 31 }

        it { expect(payment.errors_on(:event)).to include('is too long (maximum is 30 characters)')}
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

        it { expect(payment.errors_on(:description)).to include('can\'t be blank') }
      end

      context '100文字の場合' do
        let(:description) { 'あ' * 100 }

        it { expect(payment.errors_on(:description)).to be_empty }
      end

      context '101文字の場合' do
        let(:description) { 'あ' * 101 }

        it { expect(payment.errors_on(:description)).to include('is too long (maximum is 100 characters)')}
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

        it { expect(payment.errors_on(:date)).to include('can\'t be blank') }
      end

      context 'date以外の値の場合' do
        let(:date) { 'ふがふが' }

        it { expect(payment.errors_on(:date)).to include('is not a date') }
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

        it { expect(payment.errors_on(:group_id)).to include('can\'t be blank') }
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

        it { expect(payment.errors_on(:paid_user_id)).to include('can\'t be blank') }
      end

      context 'paid_user_idに紐づくuserが存在しない場合' do
        let(:paid_user_id) { 1 }

        before do
          create(:group, id: group_id)
          create(:group_user, user_id: paid_user_id, group_id: group_id)
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
end
