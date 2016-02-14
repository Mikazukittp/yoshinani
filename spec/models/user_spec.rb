require 'rails_helper'

RSpec.describe User do
  describe 'validation' do
    describe '#account' do
      let(:user) { User.new(account: account) }

      context '正常系' do
        let(:account) { 'hayato-kobayashi' }

        it { expect(user.errors_on(:account)).to be_empty }
      end

      context '空の場合' do
        let(:account) { nil }

        it { expect(user.errors_on(:account)).to include('can\'t be blank') }
      end

      context '重複する値の場合' do
        let(:account) { 'amuro_rei' }

        before do
          create(:user, account: 'amuro_rei')
        end

        it { expect(user.errors_on(:account)).to include('has already been taken') }
      end

      context '30文字の場合' do
        let(:account) { 'hogehogehogehogehogehogehogeho' }

        it { expect(user.errors_on(:account)).to be_empty }
      end

      context '31文字の場合' do
        let(:account) { 'hogehogehogehogehogehogehogehog' }

        it { expect(user.errors_on(:account)).to include('is too long (maximum is 30 characters)') }
      end
    end

    describe '#username' do
      let(:user) { User.new(username: username) }

      context '正常系' do
        let(:username) { 'ハヤト・コバヤシ' }

        it { expect(user.errors_on(:username)).to be_empty }
      end

      context '空の場合' do
        let(:username) { nil }

        it { expect(user.errors_on(:username)).to include('can\'t be blank') }
      end

      context '30文字の場合' do
        let(:username) { 'hogehogehogehogehogehogehogeho' }

        it { expect(user.errors_on(:username)).to be_empty }
      end

      context '31文字の場合' do
        let(:username) { 'hogehogehogehogehogehogehogehog' }

        it { expect(user.errors_on(:username)).to include('is too long (maximum is 30 characters)') }
      end
    end

    describe 'email' do
      let(:user) { User.new(email: email) }

      context '正常系' do
        let(:email) { 'kobayashi@example.com' }

        it { expect(user.errors_on(:email)).to be_empty }
      end

      context '空の場合' do
        let(:email) { nil }

        it { expect(user.errors_on(:email)).to include('can\'t be blank') }
      end

      context '重複する値の場合' do
        let(:email) { 'gandum-rx78-2@example.com' }

        before do
          create(:user, email: 'gandum-rx78-2@example.com')
        end

        it { expect(user.errors_on(:email)).to include('has already been taken') }
      end

      context '不正な値の場合' do
        let(:email) { 'gandum-rx78-2@zakuzaku' }

        it { expect(user.errors_on(:email)).to include('is invalid') }
      end

      context '256文字以上の場合' do
        let(:email) { 'x' * 256 + '@example.com' }

        it { expect(user.errors_on(:email)).to include('is too long (maximum is 256 characters)') }
      end
    end

    describe '#password' do
      let(:user) { User.new(password: password) }

      context '正常系' do
        let(:password) { '123456a-' }

        it { expect(user.errors_on(:password)).to be_empty }
      end

      context '空の場合' do
        let(:password) { nil }

        it { expect(user.errors_on(:password)).to include('can\'t be blank') }
      end

      context '6文字の場合' do
        let(:password) { 'p' * 6 }

        it { expect(user.errors_on(:password)).to include('is too short (minimum is 7 characters)') }
      end

      context '7文字の場合' do
        let(:password) { 'p' * 7 }

        it { expect(user.errors_on(:password)).to be_empty }
      end

      context '20文字の場合' do
        let(:password) { 'p' * 20 }

        it { expect(user.errors_on(:password)).to be_empty }
      end

      context '21文字の場合' do
        let(:password) { 'p' * 21 }

        it { expect(user.errors_on(:password)).to include('is too long (maximum is 20 characters)') }
      end
    end

    describe '#role' do
      let(:user) { User.new(role: role) }

      context '正常系' do
        let(:role) { 1 }

        it { expect(user.errors_on(:role)).to be_empty }
      end

      context 'integer以外の値の場合' do
        let(:role) { '大佐' }

        it { expect(user.errors_on(:role)).to include('is not a number') }
      end
    end
  end

  describe 'trim space account and password' do
    describe '#account' do
      let(:user) { create(:user, account: '  space man  ') }

      it { expect(user.account).to eq 'space man' }
    end

    # TODO 途中でハッシュ化の処理を挟むのでfeature testの方に書く
    describe '#password' do
    end
  end
end
