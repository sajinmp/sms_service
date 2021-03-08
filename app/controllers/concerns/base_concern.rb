module BaseConcern
  def authenticate_account
    authenticate_or_request_with_http_basic do |username, password|
      (@current_account = Account.find_by(username: username, auth_id: password)).present?
    end
  end

  def check_presence(key, value)
    raise ActionController::BadRequest.new("#{key} is missing") unless value.present?
  end

  def check_length(key, value, min, max)
    raise Exceptions::InvalidRecord.new("#{key} is invalid") unless value.size >= min && value.size <= max
  end

  def check_account(key, value)
    number = @current_account.phone_numbers.find_by(number: value)
    raise ActiveRecord::RecordNotFound.new("#{key} parameter not found") unless number
  end
  
  def render_error(message = nil, status = nil)
    message ||= 'Unknown failure'
    status ||= 500
    render json: {message: '', error: message}, status: status
  end

  def bad_request(exception = nil, message = nil)
    message = message || exception.message
    render_error(message, 400)
  end

  def invalid_record(exception = nil, message = nil)
    message ||= exception.message
    render_error(message, 422)
  end

  def not_found(exception = nil, message = nil)
    message ||= exception.message
    render_error(message, 404)
  end
end
