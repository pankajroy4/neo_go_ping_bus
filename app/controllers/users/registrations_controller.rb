class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, only: [:create, :update]

  def create 
    if params[:user][:role].in?(["user", "bus_owner"])
      super
    else
      build_resource(sign_up_params)
      flash[:alert] = "Invalid role"
      render :new, status: :unprocessable_entity
    end
  end

  def after_sign_up_path_for(resource)
    user_path(resource)
  end

  def after_update_path_for(resource)
    user_path(resource)
  end

  private

  def configure_permitted_parameters 
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :role, :registration_no])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :registration_no])
    unless params[:user][:role] == 'bus_owner' || current_user&.bus_owner?
      params[:user][:registration_no] = nil
    end
  end
end