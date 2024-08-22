class Users::SessionsController < Devise::SessionsController
  # include RackSessionsFix
  respond_to :json

  def respond_with(resource, _opts = {})
    if resource.persisted?
      token = current_token
      if token
        render json: {
          status: { code: 200, message: 'Logged in successfully.' },
          data: ActiveModelSerializers::SerializableResource.new(resource, serializer: UserSerializer).as_json,
          token: token
        }, status: :ok
      else
        render json: {
          status: { code: 401, message: 'Failed to generate token.' }
        }, status: :unauthorized
      end
    else
      render json: {
        status: { code: 401, message: 'Invalid email or password.' }
      }, status: :unauthorized
    end
  end

  def respond_to_on_destroy
    jwt_token = request.headers['Authorization']&.split(' ')&.last
    if jwt_token
      begin
        jwt_payload = JWT.decode(jwt_token, ENV['DEVISE_JWT_SECRET_KEY'], true, { algorithm: 'HS256' }).first
        user = User.find(jwt_payload['user_id'])

        if user && user.jti == jwt_payload['jti']
          # User is authenticated, proceed with logout
          user.update(jti: SecureRandom.uuid)
          cookies.delete(:jwt_token) if cookies[:jwt_token]
          render json: { status: 200, message: 'Logged out successfully.' }, status: :ok
        else
          render json: { status: 401, message: 'User is not logged in.' }, status: :unauthorized
        end
        # render json: { status: 401, message: "Invalid token: #{e.message}" }, status: :unauthorized
      rescue JWT::DecodeError, JWT::ExpiredSignature
        # Token is invalid or expired
        render json: { status: 401, message: 'Invalid or expired token.' }, status: :unauthorized
      rescue ActiveRecord::RecordNotFound
        render json: { status: 404, message: 'User not found.' }, status: :not_found
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