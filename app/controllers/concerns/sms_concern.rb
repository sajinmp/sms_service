module SmsConcern
  include BaseConcern

  def validate_params(params, keys)
    keys.each { |key| send("validate_#{key}", params[key]) }
  end

  def validate_from(value)
    check_presence('From', value)
    check_length('From', value, 6, 16)
    check_account('From', value) if action_name == 'outbound'
  end

  def validate_to(value)
    check_presence('To', value)
    check_length('To', value, 6, 16)
    check_account('To', value) if action_name == 'inbound'
  end

  def validate_text(value)
    check_presence('Text', value)
    check_length('To', value, 1, 120)
  end

  def store_from_and_to_in_cache(params)
    REDIS.set("stop/#{params[:from]}-#{params[:to]}", true) if params[:text].strip == 'STOP'
  end

  def throttle_request(from)
    request_count = REDIS.get("from/#{from}")
    raise ActionController::BadRequest.new("Limit reached for from #{from}") if request_count.to_i >= 50
  end

  def check_if_numbers_are_in_cache(params)
    val = REDIS.get("stop/#{params[:to]}-#{params[:from]}")
    if val
      raise ActionController::BadRequest.new("Sms from #{params[:from]} to #{params[:to]} blocked by STOP request")
    end
  end

  def store_from_in_cache(from)
    if REDIS.get("from/#{from}")
      REDIS.incr("from/#{from}")
    else
      REDIS.set("from/#{from}", 1, ex: 24.hours)
    end
  end
end
