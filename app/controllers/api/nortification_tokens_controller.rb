class Api::NortificationTokensController < ApplicationController
  before_action :authenticate!
  before_action :valid_uniqueness_token, only: %i(create)
  before_action :set_nortification_token, only: %i(update destroy)

  def create
    @nortification_token = @user.nortification_tokens.new(nortification_token_params)
    if @nortification_token.save
      render json: @user, status: :ok
    else
      render json: {message: "PUSHキーの作成に失敗しました", errors: @nortification_token.errors.messages}, status: :internal_server_error
    end
  end

  def update
    if @nortification_token.update(nortification_token_params)
      render json: @user, status: :ok
    else
      render json: {message: "PUSHキーの更新に失敗しました", errors: @nortification_token.errors.messages}, status: :internal_server_error
    end
  end

  def destroy
    if @nortification_token.destroy
      render json: @user, status: :ok
    else
      render json: {message: "PUSHキーの削除に失敗しました", errors: @nortification_token.errors.messages}, status: :internal_server_error
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

  def valid_uniqueness_token
    if NortificationToken.exists?(device_token: params[:nortification_token][:device_token])
      render json: {message: "指定されたPUSHキーはすでに存在しています"}, status: :ok
    end
  end
end