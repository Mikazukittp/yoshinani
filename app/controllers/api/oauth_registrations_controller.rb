class Api::OauthRegistrationsController < ApplicationController
  before_action :deny_unpermitted_third_party
  # before_action :validate_hash_token!

  def create
    if exist_auth_registration?
      # ログイン
      user = OauthRegistration.find_by(third_party_id: params[:oauth][:third_party_id], oauth_id: params[:oauth][:oauth_id]).user
      user.new_token
      if user.save(context: :oauth_registration)
        status = :ok
      else
        render json: {error: "ログインに失敗しました"}, status: :internal_server_error and return
      end
    else
      # 新規作成
      begin
        ActiveRecord::Base.transaction do
          user = User.new
          user.save!(context: :oauth_registration)
          user.oauth_registrations.create!(oauth_params)
        end

      rescue ActiveRecord::RecordInvalid => invalid
        render json: invalid.record.errors.full_messages, status: :internal_server_error
      end
    end

    render json: user, status: status
  end

  private

  def oauth_params
    params.require(:oauth).permit(:third_party_id, :oauth_id)
  end

  def exist_auth_registration?
    OauthRegistration.exists?(third_party_id: params[:oauth][:third_party_id], oauth_id: params[:oauth][:oauth_id])
  end

  def deny_unpermitted_third_party
    unless Oauth.exists?(id: params[:oauth][:oauth_id])
      render json: {error: "許可されていないSNSです。"}, status: :bad_request
      return
    end
  end

  def validate_hash_token!
    target_id = params[:oauth][:third_party_id]
    salt = ENV["YOSHINANI_SALT"]

    unless Digest::MD5.hexdigest(password + salt) == params[:oauth][:sns_hash_id]
      render json: {error: "不正な操作です"}, status: :bad_request
      return
    end
  end
end
