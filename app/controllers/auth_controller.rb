class AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :signin_new, :sign_in ]

  def signin_new
  end

  def sign_in
    response = supabase_client.sign_in(user_params[:email], user_params[:password])

    if response.success?
      session[:token] = response.parsed_response["access_token"]
      session[:email] = user_params[:email]
      Rails.logger.debug "Session token: #{session[:token]}"

      user_info = supabase_client.get_user_info(response.parsed_response["access_token"])
      user_data = UserData.find_by(id: user_info["id"])

      if user_data
        Rails.logger.debug "User data: #{user_data.inspect}"
        session[:user_type] = user_data.is_supervisor
        session[:club_id] = user_data.club_id

        if user_data.is_supervisor
          redirect_to supervisor_dashboard_path and return
        else
          redirect_to pic_dashboard_path and return
        end
      else
        flash[:error] = "User data not found. Please contact support."
        redirect_to signin_path
      end
    else
      flash.now[:error] = "Invalid email or password"
      render :signin_new, status: :unauthorized
    end
  end

  def sign_out
    session.delete(:token)
    session.delete(:email)
    session.delete(:user_type)
    session.delete(:club_id)
    flash[:notice] = "Successfully signed out"
    redirect_to signin_path
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end

  def supabase_client
    @supabase_client ||= Supabase::Client.new
  end
end
