class Users::PasswordsController < Devise::PasswordsController
  respond_to :json
  # protect_from_forgery with: :null_session
  before_action :authenticate_user!, only: [:change_password]

  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    if successfully_sent?(resource)
      render json: { status: { code: 200, message: 'Reset password instructions sent successfully.' } }
    else
      render json: { status: { code: 422, message: 'Failed to send reset password instructions.' }, errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      render json: { status: { code: 200, message: 'Password reset successfully.' } }
    else
      render json: { status: { code: 422, message: 'Failed to reset password.' }, errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /resource/change_password
  def change_password
    if current_user.update_with_password(password_change_params)
      sign_out(current_user)
      render json: { status: { code: 200, message: 'Password changed successfully. Please log in with your new password.' } }
    else
      render json: { status: { code: 422, message: 'Failed to change password.' }, errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def password_change_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end