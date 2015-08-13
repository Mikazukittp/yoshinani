class Api::PaymentController < ApplicationController

  def index
    # バリデーション
    if params['group_id'].blank?
      render json: {errors: "グループidが入力されていません"}, status: :internal_server_error
      return
    end
    render json: Payment.where(group_id: params['group_id']), status: :ok
  end


  def show
    render json: Payment.first, status: :ok
  end


  def create
    @params = params.require(:payment).permit(:amount, :group_id ,:event, :description, :date, :paid_user_id, :is_repayment)
    @participants_id = JSON.parse(params.require(:payment).permit(:participants_id)['participants_id']||"[]")

    begin
      ActiveRecord::Base.transaction do
        # 立替の作成
        payment = Payment.create!(@params)

        # 立替を参加者に紐付け
        @participants_id.each{ |participant_id|
          payment.participants << User.find(participant_id)
        }

        # 暫定総額の設定
        set_total(@params['amount'], @params['paid_user_id'], @participants_id, @params['group_id'])

        # 結果の返却
        render json: payment.to_json(include: {
          group: {}, paid_user: {}, participants: {}
        }), status: :created
      end
    rescue => error_message
      render json: { errors: error_message }, status: :internal_server_error
    end
  end


  def update
    render json: {}, status: :internal_server_error
  end

  def destroy
    render json: {}, status: :internal_server_error
  end

  private

  def set_total(amount, paid_user_id, participants_id, group_id)
    # 支払ユーザの支払総額に加算
    total = Total.where(group_id: group_id, user_id: paid_user_id).first_or_initialize
    total.paid += amount.to_f
    total.save!

    participants_id.each{ |participant_id|
      # 参加者の借入総額に加算
      total = Total.where(group_id: group_id, user_id: participant_id).first_or_initialize
      total.to_pay += (amount.to_f / participants_id.size).round(3)
      total.save!
    }
  end

end
