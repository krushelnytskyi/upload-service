class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :restrict_user

  protected

  def restrict_user
    if user_signed_in? && current_user.active != true
      sign_out
      flash[:alert] = 'User login not allowed'
      redirect_to new_user_session_path
    elsif current_user && current_user.role == 'user' && params[:controller] != 'devise/sessions'
      render 'user/no_permissions'
    end   
  end

end
