#
# Migrate Payment Data From Heroku Application
#
# Usage:
#   bundle exec rails r ./script/migration_payment.rb migrate -f=#{path}
#
# Example:
#   bundle exec rails r ./script/migration_payment.rb migrate -f ./lib/tasks/input.json

class MigrationPayment < Thor
require 'json'

ID_MAPPING_TABLE = {
  '54d30a520b0add03001dc06c' => 1,
  '54d30a520b0add03001dc06e' => 2,
  '54d30a520b0add03001dc06b' => 3,
  '54d30a520b0add03001dc065' => 4,
  '54d30a520b0add03001dc06a' => 5,
  '54d30a520b0add03001dc067' => 6,
  '54d30a520b0add03001dc069' => 7,
  '54d30a520b0add03001dc066' => 8,
  '54d30a520b0add03001dc068' => 9,
  '54d30a520b0add03001dc06d' => 10
}

EVENT_SEEM_TO_BE_SEISAN = %w(精算 はいじに清算 はいじに返還 キャンプ返済 返済 建て替え清算 もろもろ)

  desc 'migrate', 'input.jsonをパースしてpayment情報をmigrationします'
  option :file, required: :ture,  type: :string, aliases: '-f', desc: '読み込むjsonファイルを指定してください'
  def migrate
    file = open(options[:file])

    open(options[:file]) do |io|
      payment_data_arr = JSON.load(io)

      # 逆にしないと新しい情報からcreateしてしまう
      payment_data_arr.reverse!

      ActiveRecord::Base.transaction do

        payment_data_arr.each do |payment_data|
          payment = Payment.new(
            amount: payment_data['amount'],
            description: payment_data['description'],
            event: payment_data['event'],
            date: payment_data['date'],
            group_id: 1,
            paid_user_id: ID_MAPPING_TABLE[payment_data['paidUserId']]
          )

          if payment_data['participantsIds'].size == 1 && EVENT_SEEM_TO_BE_SEISAN.include?(payment.event)
            payment.is_repayment = true
          end

          payment.save!

          payment_data['participantsIds'].each do |participants_id|
            participant = Participant.new(payment_id: payment.id, user_id: ID_MAPPING_TABLE[participants_id])

            participant.save!
          end

          set_total(payment.amount, payment.paid_user_id, payment.participants.pluck(:id), payment.group_id)

        end
      end
    end
  end

  private

  # PaymentControllerと同じものを持ってきてるんだけど、一旦このままで、ゆくゆくはmodelに移したい
  def set_total(amount, paid_user_id, participants_ids, group_id)

    total = Total.where(group_id: group_id, user_id: paid_user_id).first_or_initialize
    total.paid += amount.to_f
    total.save!

    participants_ids.each{ |participant_id|
      total = Total.where(group_id: group_id, user_id: participant_id).first_or_initialize
      total.to_pay += (amount.to_f / participants_ids.size).round(3)
      total.save!
    }
  end
end

MigrationPayment.start
