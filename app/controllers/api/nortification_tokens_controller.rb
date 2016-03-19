class Api::NortificationTokensController < ApplicationController
  before_action :authenticate!
  before_action :set_nortification_token, only: %i(update destroy)

  def create
    if @user.nortification_tokens.create(nortification_token_params)
      render json: @user, status: :ok
    else
      render json: {message: "PUSHキーの作成に失敗しました" ,errors: invalid.record.errors.messages}, status: :internal_server_error
    end
  end

  def update
    if @nortification_token.update(nortification_token_params)
      render json: @user, status: :ok
    else
      render json: {message: "PUSHキーの更新に失敗しました" ,errors: invalid.record.errors.messages}, status: :internal_server_error
    end
  end

  def destroy
    if @nortification_token.destroy
      render json: @user, status: :ok
    else
      render json: {message: "PUSHキーの削除に失敗しました" ,errors: invalid.record.errors.messages}, status: :internal_server_error
    end
  end

  private

  def nortification_token_params
    params.require(:nortification_token).permit(:device_token, :device_type)
  end

  def set_nortification_token
    @nortification_token = @user.nortification_tokens.find_by(device_token: params[:nortification_token][:auth_device_token])
    unless @nortification_token.present?
      render json: {message: "指定されたPUSHキーは見つかりません"}, status: :bad_request
      return
    end
  end
end