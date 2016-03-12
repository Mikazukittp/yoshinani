class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  # 例外ハンドル
  if !Rails.env.development?
    rescue_from Exception,                        with: :render_500
    rescue_from ActiveRecord::RecordNotFound,     with: :render_404
    rescue_from ActionController::RoutingError,   with: :render_404
  end

  def routing_error
    raise ActionController::RoutingError.new(params[:path])
  end

  def render_404(e = nil)
    logger.info "Rendering 404 with exception: #{e.message}" if e
    render json: { message: "404 error #{e.try!(:message)}" }, status: 404
  end

  def render_500(e = nil)
    logger.error "Rendering 500 with exception: #{e.message}" if e
    render json: { message: "500 error #{e.try!(:message)}" }, status: 500
  end

  # 認証処理をする
  # 認証に失敗したらログインページにリダイレクトする
  def authenticate!
    uid = request.headers[:UID]
    token = request.headers[:TOKEN]
    @user = User.find_by(id: uid)
    if @user.present? && token == @user.token
      return true
    else
      render json: { message: "認証に失敗しました" }, status: :unauthorized
      return false
    end
  end

end
