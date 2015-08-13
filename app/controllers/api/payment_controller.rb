class Api::PaymentController < ApplicationController

  def index
    render :json => Payment.all, status: :ok
  end

  def show
    render :json => Payment.first, status: :ok
  end

  def create
    @params = params.require(:payment).permit(:amount, :group_id ,:event, :description, :date, :paid_user_id, :participants_id)

    # バリデーション
    if @params['amount'].blank?
      render :json => {errors: "金額が入力されていません"}, status: :internal_server_error
      return
    end

    if @params['group_id'].blank?
      render :json => {errors: "グループidが入力されていません"}, status: :internal_server_error
      return
    end

    if @params['event'].blank?
      render :json => {errors: "立替が発生したイベント内容が入力されていません"}, status: :internal_server_error
      return
    end

    if @params['description'].blank?
      render :json => {errors: "立替の詳細説明が入力されていません"}, status: :internal_server_error
      return
    end

    if @params['date'].blank?
      render :json => {errors: "日付が入力されていません"}, status: :internal_server_error
      return
    end

    if @params['paid_user_id'].blank?
      render :json => {errors: "支払ったユーザのidが入力されていません"}, status: :internal_server_error
      return
    end

    if @params['participants_id'].blank? or JSON.parse(@params['participants_id']).blank?
      render :json => {errors: "参加者のidが入力されていません"}, status: :internal_server_error
      return
    end

    if GroupUser.where({group_id: @params['group_id'], user_id: @params['paid_user_id']}).size.zero?
      render :json => {errors: "支払ったユーザは指定されたグループのユーザではありません"}, status: :internal_server_error
      return
    end

    JSON.parse(@params['participants_id']).each{ |participant_id|
      if GroupUser.where({group_id: @params['group_id'], user_id: participant_id}).size.zero?
      render :json => {errors: "参加者は指定されたグループのユーザではありません"}, status: :internal_server_error
        return
      end
    }

    # payment作成処理
    begin
      ActiveRecord::Base.transaction do
        # 立替の作成
        payment = Payment.create({
          amount: @params['amount'],
          group_id: @params['group_id'],
          event: @params['event'],
          description: @params['description'],
          date: @params['date'],
          paid_user_id: @params['paid_user_id']
        })

        # 支払ユーザの支払総額に加算
        total = Total.where(group_id: @params['group_id'], user_id: @params['paid_user_id']).first_or_initialize
        total.paid = total.paid.to_f + @params['amount'].to_f
        total.save!

        @participants = JSON.parse(@params['participants_id'])
        @participants.each{ |participant_id|
          # 立替を参加者に紐付け
          Participant.create({
            payment_id: payment.id,
            group_id: @params['group_id'],
            user_id: participant_id
          })

          # 参加者の借入総額に加算
          total = Total.where(group_id: @params['group_id'], user_id: participant_id).first_or_initialize
          total.to_pay = total.to_pay.to_f + @params['amount'].to_f.round(2) / @participants.size
          total.save!
        }

        render :json => payment.to_json(include: {
          group: {}, paid_user: {}, participants: {}
        }), status: :created
      end
    rescue => error_message
      render :json => { errors: error_message }, status: :internal_server_error
    end
  end

  def update
    render :json => {}, status: :internal_server_error
  end

  def destroy
    render :json => {}, status: :internal_server_error
  end

end
