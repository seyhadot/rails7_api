class Api::V1::BaseController < ApplicationController
  include ActionController::MimeResponds
  include ActionController::Cookies
  before_action :authenticate_user!
  respond_to :json
end
