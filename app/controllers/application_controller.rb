class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include ActionController::Cookies
  respond_to :json
  before_action :authenticate_user!
end