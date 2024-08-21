class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :jti
  # Add any other attributes you want to include in the JSON response
end