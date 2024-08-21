class User < ApplicationRecord

  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable,
  :jwt_authenticatable, jwt_revocation_strategy: self


  before_create :set_jti

  private

  def set_jti
    self.jti ||= SecureRandom.uuid
  end
end