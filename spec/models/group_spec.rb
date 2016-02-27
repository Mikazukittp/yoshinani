require 'rails_helper'

RSpec.describe Group do
  describe 'validation' do
    describe '#name' do
      let(:group) { Group.new(name: name) }

      context '正常系' do
        let(:name) { '幻影旅団' }

        it { expect(group.errors_on(:name)).to be_empty }
      end

      context '正常系' do
        let(:name) { nil }

        it { expect(group.errors_on(:name)).to include('名前を入力してください') }
      end
    end
  end
end
