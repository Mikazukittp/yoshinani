RSpec.describe GroupUser do
  describe 'validation' do
    describe '#composite_primary_key' do
      let(:group_user) { GroupUser.new(group_id: group_id, user_id: user_id) }

      context '正常系' do
        let(:group_id) { 1 }
        let(:user_id) { 1 }

        before do
          create(:group, id: 1)
          create(:user, id: 1)
        end

        it { expect(group_user.send(:composite_primary_key)).to be_nil }
      end

      context 'すでに同じgroup_idが存在する場合' do
        let(:group_id) { 1 }
        let(:user_id) { 1 }

        before do
          create(:group, id: 1)
          create(:user, id: 1)
          create(:user, id: 2, email: 'hogehoge@example.com', account: 'hogehoge')
          create(:group_user, group_id: 1, user_id: 2)
        end

        it { expect(group_user.send(:composite_primary_key)).to be_nil }
      end

      context 'すでに同じuser_idが存在する場合' do
        let(:group_id) { 1 }
        let(:user_id) { 1 }

        before do
          create(:group, id: 1)
          create(:group, id: 2)
          create(:user, id: 1)
          create(:group_user, group_id: 2, user_id: 1)
        end

        it { expect(group_user.send(:composite_primary_key)).to be_nil }
      end

      context 'すでに同じgroup_id、user_idが存在する場合' do
        let(:group_id) { 1 }
        let(:user_id) { 1 }

        before do
          create(:group, id: 1)
          create(:user, id: 1)
          create(:group_user, group_id: 1, user_id: 1)
        end

        it { expect(group_user.send(:composite_primary_key)).to include('すでに招待中のユーザがいます') }
      end
    end
  end
end
