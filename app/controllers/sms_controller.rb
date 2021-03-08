class SmsController < ApplicationController
  include SmsConcern

  def inbound
    validate_params(input_params, [:from, :to, :text])
    store_from_and_to_in_cache(input_params)
    render json: {message: 'Inbound sms ok', error: ''}
  end

  def outbound
    throttle_request(input_params[:from])
    validate_params(input_params, [:from, :to])
    check_if_numbers_are_in_cache(input_params)
    store_from_in_cache(input_params[:from])
    render json: {message: 'Outbound sms ok', error: ''}
  end

private

  def input_params
    params.slice(:from, :to, :text)
  end
end
