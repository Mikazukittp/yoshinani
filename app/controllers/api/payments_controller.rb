class Api::PaymentsController < ApplicationController
  before_action :authenticate!
  before_action :deny_first_and_last_params, only: %i(index)
  before_action :set_payment, only: %i(show update destroy)
  before_action :set_group, only: %i(index)

  def index
    payments = @group.payments.includes(paid_user: [:totals, groups: :group_users],
      participants:  [:totals, groups: :group_users])

    if last_payment = Payment.unscoped.find_by(id: params[:last_id]).presence
      payments = payments.pagenate_next(last_payment)
    elsif first_payment = Payment.unscoped.find_by(id: params[:first_id]).presence
      payments = payments.pagenate_prev(first_payment).reverse
    else
      payments = payments.pagenate_next()
    end

    render json: payments, status: :ok
  end

  def show
    render json: @payment, status: :ok
  end

  def create
    participants_ids = params[:payment][:participants_ids]

    ActiveRecord::Base.transaction do
      payment = Payment.create!(payment_params)

      # 立替を参加者に紐付け
      participants_ids.each{ |participant_id|
        next unless payment.group.users.exists?(id: participant_id)
        payment.participant_reference.create!(user_id: participant_id)
      }
      # 暫定総額の設定
      set_total(payment.amount, payment.paid_user_id, payment.participants.pluck(:id), payment.group_id)
      # 結果の返却
      render json: payment.to_json(include: [:group, :paid_user, :participants]), status: :created
    end

  rescue ActiveRecord::RecordInvalid => invalid
    render json: {message: "支払いの作成に失敗しました", errors: invalid.record.errors.messages}, status: :internal_server_error
  end


  def update
    unless @payment.paid_user.id == @user.id
      render json: {message: "権限のない操作です"}, status: :forbidden
      return
    end

    participants_ids = params[:payment][:participants_ids]
    @params = payment_params
    old_amount = @payment.amount
    old_participants_ids = @payment.participants.pluck(:id)

    ActiveRecord::Base.transaction do
      # 立替の作成
      @payment.update!(@params)

      # 削除された参加者の紐付けを解除
      (old_participants_ids-participants_ids).each{ |removed_participant_id|
        @payment.participant_reference.find_by(user_id: removed_participant_id).destroy!
      }

      # 追加された参加者の紐付けを作成
      (participants_ids-old_participants_ids).each{ |participant_id|
        next unless @payment.group.users.exists?(id: participant_id)
        @payment.participant_reference.create!(user_id: participant_id)
      }

      # 暫定総額の設定
      set_total(-old_amount, @payment.paid_user_id, old_participants_ids, @payment.group_id)
      set_total(@payment.amount, @payment.paid_user_id, participants_ids, @payment.group_id)

      # 結果の返却
      render json: @payment.to_json(include: {
        group: {}, paid_user: {}, participants: {}
      }), status: :created
    end

  rescue ActiveRecord::RecordInvalid => invalid
    render json: {message: "支払いの作成に失敗しました", errors: invalid.record.errors.messages}, status: :internal_server_error
  end

  def destroy
    unless @payment.paid_user.id == @user.id
      render json: {message: "権限のない操作です"}, status: :forbidden
      return
    end

    begin
      ActiveRecord::Base.transaction do
        @payment.update(deleted_at: Time.now)
        set_total(-@payment.amount, @payment.paid_user_id, @payment.participants.pluck(:id), @payment.group_id)
      end

    rescue ActiveRecord::RecordInvalid => invalid
      render json: {message: "支払いの削除に失敗しました", errors: invalid.record.errors.messages}, status: :internal_server_error
      return
    end

    render json: @payment, status: :ok
  end

  private

  def deny_first_and_last_params
    if params[:first_id].present? && params[:last_id].present?
      render json: {message: "first_idかlast_idはどちらか1つしか指定できません"}, status: :bad_request
      return
    end
  end

  def set_payment
    @payment = Payment.find_by(id: params[:id])
    unless @payment.present? && @user.groups.exists?(id: @payment.group_id)
      render json: {message: "指定されたIDの精算が見つかりません"}, status: :not_found
      return
    end
  end

  def set_group
    if params['group_id'].blank?
      render json: {message: "グループidが入力されていません"}, status: :bad_request
      return
    end

    @group = @user.groups.find_by(id: params['group_id'])

    unless @group.present?
      render json: {message: "指定されたIDのグループが見つかりません"}, status: :bad_request
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
