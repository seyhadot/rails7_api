class Api::V1::UsersController < Api::V1::BaseController
  def current
    render json: UserSerializer.new(current_user).serializable_hash
  end
end