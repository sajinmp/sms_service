class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include BaseConcern
  before_action :authenticate_account

  rescue_from Exception, with: :render_error
  rescue_from Exceptions::InvalidRecord, with: :invalid_record
  rescue_from ActionController::BadRequest, with: :bad_request
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
end
