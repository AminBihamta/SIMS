class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Authenticatable

  private

  def authenticate_user!
    Rails.logger.debug "Current user in authenticate_user!: #{current_user.inspect}"
    unless current_user
      flash[:error] = "Please sign in to continue"
      redirect_to signin_path
    end

     # Store PIC's club_id in session
     if current_user && !current_user.is_supervisor?
        session[:club_id] = current_user.club_id
     end
  end

  def current_user
    Rails.logger.debug "Session token in current_user: #{session[:token].inspect}"
    return @current_user if defined?(@current_user)

    token = session[:token]
    return nil unless token

    payload = Supabase::Client.new.verify_jwt(token)
    Rails.logger.debug "JWT payload: #{payload.inspect}"
    return nil unless payload

    user_id = payload.first["sub"]
    user_data = UserData.find_by(id: user_id)

    if user_data
      @current_user = User.new(
        id: user_data.id,
        email: session[:email],
        club_id: user_data.club_id,
        is_supervisor: user_data.is_supervisor
      )
    else
      @current_user = nil
    end
  rescue JWT::DecodeError => e
    Rails.logger.debug "JWT DecodeError: #{e.message}"
    nil
  end


  def require_supervisor!
    Rails.logger.debug "Current user in require_supervisor!: #{current_user.inspect}"
    unless current_user&.is_supervisor
      flash[:error] = "Access restricted to supervisors only."
      redirect_to root_path unless current_user.is_supervisor?
    end
  end


  def require_pic!
    unless current_user && !current_user.is_supervisor?
      flash[:error] = "Access restricted to PIC users only."
      redirect_to root_path unless current_user.is_supervisor?
    end
  end
end
