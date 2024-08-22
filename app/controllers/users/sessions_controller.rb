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
    jwt_token = request.headers['Authorization']&.split(' ')&.last
    if jwt_token
      begin
        jwt_payload = JWT.decode(jwt_token, ENV['DEVISE_JWT_SECRET_KEY'], true, { algorithm: 'HS256' }).first
        current_user = User.find(jwt_payload['user_id'])
        current_user.update(jti: SecureRandom.uuid)
        render json: { status: 200, message: 'Logged out successfully.' }, status: :ok
      rescue JWT::DecodeError => e
        render json: { status: 401, message: "Invalid token: #{e.message}" }, status: :unauthorized
      rescue ActiveRecord::RecordNotFound
        render json: { status: 404, message: "User not found" }, status: :not_found
      rescue StandardError => e
        render json: { status: 500, message: "An error occurred: #{e.message}" }, status: :internal_server_error
      end
    else
      render json: { status: 401, message: "No token provided." }, status: :unauthorized
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