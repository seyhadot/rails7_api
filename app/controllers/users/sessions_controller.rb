class Users::SessionsController < Devise::SessionsController
  include RackSessionsFix
  respond_to :json

  def respond_with(resource, _opts = {})
    token = current_token
    if token
      render json: {
        status: { code: 200, message: 'Logged in successfully.' },
        data: ActiveModelSerializers::SerializableResource.new(resource, serializer: UserSerializer).as_json,
        token: token
      }
    else
      render json: {
        status: { code: 401, message: 'Failed to generate token.' }
      }, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    if request.headers['Authorization'].present?
      begin
        jwt_payload = JWT.decode(request.headers['Authorization'].split(' ').last, ENV['DEVISE_JWT_SECRET_KEY']).first
        current_user = User.find_by(id: jwt_payload['sub'])
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound
        current_user = nil
      end
    end

    if current_user
      render json: {
        status: 200,
        message: 'Logged out successfully.'
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end

  def current_token
    request.env['warden-jwt_auth.token'] || generate_jwt_token(current_user)
  end

  private

  def generate_jwt_token(user)
    JWT.encode(
      {
        user_id: user.id,
        exp: 24.hours.from_now.to_i,
        jti: user.jti || SecureRandom.uuid
      },
      ENV['DEVISE_JWT_SECRET_KEY']
    )
  end

end