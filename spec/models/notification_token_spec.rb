RSpec.describe NotificationToken do
  describe 'validation' do
    describe '#device_type' do
      let(:notification_token) { NotificationToken.new(device_type: device_type) }

      context '正常系' do
        context 'iosの場合' do
          let(:device_type) { 'ios' }

          it { expect(notification_token.errors_on(:device_type)).to be_empty }
        end

        context 'androidの場合' do
          let(:device_type) { 'android' }

          it { expect(notification_token.errors_on(:device_type)).to be_empty }
        end
      end

      context '異常系' do
        context '空の場合' do
          let(:device_type) { nil }

          it { expect(notification_token.errors_on(:device_type)).to include('デバイスタイプを入力してください') }
        end

        context '不正な値の場合' do
          let(:device_type) { 'iphone' }

          it { expect(notification_token.errors_on(:device_type)).to include('デバイスタイプは一覧にありません') }
        end
      end
    end

  end
end
