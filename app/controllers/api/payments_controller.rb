class Api::PaymentsController < ApplicationController
  before_action :authenticate!
  before_action :set_payment, only: %i(show update)
  before_action :set_group, only: %i(index)

  def index
    @payments = @group.payments.order(date: :desc, created_at: :desc)
    render json: @payments, status: :ok
  end

  def show
    render json: @payment, status: :ok
  end

  def create
    @params = params.require(:payment).permit(:amount, :group_id ,:event, :description, :date, :paid_user_id, :is_repayment)
    participants_ids = JSON.parse(params.require(:payment).permit(:participants_ids)['participants_ids']||"[]")

    ActiveRecord::Base.transaction do
      # 立替の作成
      payment = Payment.create!(@params)

      # 立替を参加者に紐付け
      participants_ids.each{ |participant_id|
        payment.participants << User.find(participant_id)
      }

      # 暫定総額の設定
      set_total(@params['amount'], @params['paid_user_id'], participants_ids, @params['group_id'])

      # 結果の返却
      render json: payment.to_json(include: {
        group: {}, paid_user: {}, participants: {}
      }), status: :created
    end

  rescue ActiveRecord::RecordInvalid => invalid
    render json: invalid.record.errors.full_messages, status: :internal_server_error
  end


  def update
    @payment = Payment.find(params['id'])

    @params = params.require(:payment).permit(:amount, :group_id ,:event, :description, :date, :paid_user_id, :is_repayment)
    amount = @params['amount']
    paid_user_id = @params['paid_user_id']
    participants_ids = JSON.parse(params.require(:payment).permit(:participants_ids)['participants_ids']||"[]")
    group_id = @params['group_id']

    old_amount = @payment.amount
    old_paid_user_id = @payment.paid_user_id
    old_participants_ids = @payment.participants.pluck(:id)
    old_group_id = @payment.group_id

    ActiveRecord::Base.transaction do
      # 立替の作成
      @payment.attributes = @params
      @payment.save!

      # 削除された参加者の紐付けを解除
      (old_participants_ids-participants_ids).each{ |removed_participant_id|
        Participant.delete_all(payment_id: @payment.id, user_id: removed_participant_id)
      }
      # 追加された参加者の紐付けを作成
      (participants_ids-old_participants_ids).each{ |added_participant_id|
        @payment.participants << User.find(added_participant_id)
      }

      # 暫定総額の設定
      set_total(-old_amount, old_paid_user_id, old_participants_ids, old_group_id)
      set_total(amount, paid_user_id, participants_ids, group_id)

      # 結果の返却
      render json: @payment.to_json(include: {
        group: {}, paid_user: {}, participants: {}
      }), status: :created
    end

  rescue ActiveRecord::RecordInvalid => invalid
    render json: invalid.record.errors.full_messages, status: :internal_server_error
  end

  def destroy
    render json: {}, status: :internal_server_error
  end

  private

  def set_payment
    @payment = Payment.find_by(id: params[:id])
    unless @payment.present? && @user.groups.exists?(id: @payment.group_id)
      render json: {error: "指定されたIDの精算が見つかりません"}, status: :not_found
      return
    end
  end

  def set_group
    if params['group_id'].blank?
      render json: {errors: "グループidが入力されていません"}, status: :bad_request
      return
    end

    @group = @user.groups.find_by(id: params['group_id'])

    unless @group.present?
      render json: {error: "指定されたIDのグループが見つかりません"}, status: :bad_request
      return
    end
  end

  def payment_params
    params.require(:payment).permit(:amount, :group_id ,:event, :description, :date, :paid_user_id, :is_repayment)
  end

  def set_total(amount, paid_user_id, participants_ids, group_id)
    # 支払ユーザの支払総額に加算
    total = Total.where(group_id: group_id, user_id: paid_user_id).first_or_initialize
    total.paid += amount.to_f
    total.save!

    participants_ids.each{ |participant_id|
      # 参加者の借入総額に加算
      total = Total.where(group_id: group_id, user_id: participant_id).first_or_initialize
      total.to_pay += (amount.to_f / participants_ids.size).round(3)
      total.save!
    }
  end
end
