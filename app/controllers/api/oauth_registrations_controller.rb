class Api::OauthRegistrationsController < ApplicationController
  before_action :authenticate!, only: %i(index add destroy)
  before_action :deny_unpermitted_third_party, only: %i(create add)
  before_action :validate_hash_token!, only: %i(create add)
  before_action :set_oauth_registration, only: %i(destroy)

  def index
    render json: @user.oauth_registrations, status: :ok
  end

  def create
    if exist_auth_registration?
      # ログイン
      user = OauthRegistration.find_by(third_party_id: params[:oauth_registration][:third_party_id],oauth_id: params[:oauth_registration][:oauth_id]).user
      user.new_token
      if user.save(context: :oauth_registration)
        status = :ok
      else
        render json: {message: "ログインに失敗しました", errors: user.errors.messages}, status: :internal_server_error and return
      end
    else
      # 新規作成
      begin
        ActiveRecord::Base.transaction do
          user = User.new
          user.icon_img = upload_file if params[:oauth_registration][:icon_img].present?
          user.save!(context: :oauth_registration)
          user.oauth_registrations.create!(oauth_params)
        end
        status = :created

      rescue ActiveRecord::RecordInvalid => invalid
        render json: {message: "会員登録に失敗しました", errors: invalid.record.errors.messages}, status: :internal_server_error and return
      end
    end

    render json: user, status: status
  end

  def add
    set_user_icon_img if params[:oauth_registration][:icon_img].present? && @user.icon_img.url.blank?
    oauth_registration = @user.oauth_registrations.new(oauth_params)

    if oauth_registration.save
      render json: @user.oauth_registrations, status: :ok
    else
      render json: {message: "Oauth情報の登録に失敗しました", errors: oauth_registration.errors.messages}, status: :internal_server_error
    end
  end

  def destroy
    if @user.password.blank? && @user.oauth_registrations.count <= 1
      render json: {message: "最低でも登録情報は一つ以上必要です"}, status: :bad_request
    end

    if @oauth_registration.destroy
      render json: @user.oauth_registrations, status: :ok
    else
      render json: {message: "Oauth情報の削除に失敗しました", errors: @user.errors.messages}, status: :internal_server_error
    end
  end

  private

  def oauth_params
    params.require(:oauth_registration).permit(:third_party_id, :oauth_id)
  end

  def upload_file
    file = open(params[:oauth_registration][:icon_img])
    ActionDispatch::Http::UploadedFile.new({filename: 'user_icon.jpg', headers: '', tempfile: file, type: file.content_type})
  rescue OpenURI::HTTPError => e
    Rails.logger.error "upload file failed #{e.try!(:message)}"
    return nil
  end

  def set_user_icon_img
    target_file = upload_file
    @user.icon_img = target_file
    @user.save!(context: :oauth_registration)
  rescue ActiveRecord::RecordInvalid => invalid
    Rails.logger.error "saving icon img failed #{invalid.try!(:message)}"
  end

  def set_oauth_registration
    @oauth_registration = @user.oauth_registrations.find_by(oauth_id: params[:oauth_registration][:oauth_id])
  end

  def exist_auth_registration?
    OauthRegistration.exists?(third_party_id: params[:oauth_registration][:third_party_id], oauth_id: params[:oauth_registration][:oauth_id])
  end

  def deny_unpermitted_third_party
    unless Oauth.exists?(id: params[:oauth_registration][:oauth_id])
      render json: {message: "許可されていないSNSです"}, status: :bad_request
      return
    end
  end

  def validate_hash_token!
    target_id = params[:oauth_registration][:third_party_id]
    salt = ENV["YOSHINANI_SALT"]

    unless Digest::MD5.hexdigest(target_id + salt) == params[:oauth_registration][:sns_hash_id]
      render json: {message: "不正な操作です"}, status: :bad_request
      return
    end
  end
end
