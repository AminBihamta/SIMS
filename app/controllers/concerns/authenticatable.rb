module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    helper_method :current_user, :supervisor?, :pic?
  end

  private

  def authenticate_user!
    unless current_user
      respond_to do |format|
        format.html { redirect_to signin_path, alert: "Please sign in to continue" }
        format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
      end
    end
  end

  def current_user
    return @current_user if defined?(@current_user)

    # Try session-based auth first
    if session[:token]
      token = session[:token]
    else
      # Try header-based auth for API requests
      header = request.headers["Authorization"]
      return nil unless header
      token = header.split(" ").last
    end

    payload = Supabase::Client.new.verify_jwt(token)
    return nil unless payload

    user_id = payload.first["sub"]
    @current_user = User.new(
      id: user_id,
      email: session[:email]
    )
  end

  def require_supervisor!
    unless current_user && session[:user_type]
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Access denied. Supervisor privileges required." }
        format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
      end
    end
  end

  def require_pic!
    unless current_user && !session[:user_type]
      respond_to do |format|
        format.html { redirect_to root_path, alert: "Access denied. PIC privileges required." }
        format.json { render json: { error: "Unauthorized" }, status: :unauthorized }
      end
    end
  end

  def supervisor?
    session[:user_type]
  end

  def pic?
    !session[:user_type]
  end
end
