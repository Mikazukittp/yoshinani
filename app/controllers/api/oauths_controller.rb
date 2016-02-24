class Api::OauthsController < ApplicationController
  before_action :deny_unpermitted_third_party

  def create

    if exist_auth_registration?
      # ログイン
      user = OauthRegistration.find_by(third_party_id: params[:oauth][:third_party_id], oauth_id: params[:oauth][:oauth_id]).user
      user.new_token
      user.save!
      status = :ok
    else
      # 新規作成
    end

    render json: user, status: status
  end

  private

  def oauth_params
    params.permit(:third_party_id, :oauth_id)
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
end
