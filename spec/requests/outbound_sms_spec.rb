require 'rails_helper'

describe 'Outbound Sms Requests: ' do
  before do
    @account = Account.all.sample
    phone_number = @account.phone_numbers.sample
    @valid_params = {to: ('%010d' % rand(0..9999999999)).to_s, from: phone_number.number}
  end

  describe 'Authentication' do
    it 'if missing should be forbidden' do
      post outbound_sms_path
      expect(response).to have_http_status(401)
    end
  end

  context 'with valid params' do
    it 'should return the message for success' do
      post outbound_sms_path, params: @valid_params, headers: set_auth_header(@account)
      expect(json_resp['message']).to eq('Outbound sms ok')
    end

    it 'should error if numbers are in cache' do
      REDIS.set("stop/#{@valid_params[:to]}-#{@valid_params[:from]}", true)
      post outbound_sms_path, params: @valid_params, headers: set_auth_header(@account)
      expect(json_resp['error']).to eq("Sms from #{@valid_params[:from]} to #{@valid_params[:to]} blocked by STOP request")
    end

    it 'should error if 50 requests from same from number' do
      REDIS.set("from/#{@valid_params[:from]}", 50)
      post outbound_sms_path, params: @valid_params, headers: set_auth_header(@account)
      REDIS.del("from/#{@valid_params[:from]}")
      expect(json_resp['error']).to eq("Limit reached for from #{@valid_params[:from]}")
    end

    context 'from is missing in table' do
      it 'should return error' do
        @valid_params[:from] = '1234567890'
        post outbound_sms_path, params: @valid_params, headers: set_auth_header(@account)
        expect(json_resp['error']).to eq('From parameter not found')
      end
    end
  end

  context 'with invalid params' do
    it 'should return missing parameter if to is missing' do
      @valid_params[:to] = '1234'
      post outbound_sms_path, params: @valid_params, headers: set_auth_header(@account)
      expect(json_resp['error']).to eq('To is invalid')
    end

    it 'should return missing parameter if from is missing' do
      @valid_params[:from] = '1234'
      post outbound_sms_path, params: @valid_params, headers: set_auth_header(@account)
      expect(json_resp['error']).to eq('From is invalid')
    end
  end

  context 'with missing params' do
    it 'should return missing parameter if to is missing' do
      post outbound_sms_path, params: @valid_params.except(:to), headers: set_auth_header(@account)
      expect(json_resp['error']).to eq('To is missing')
    end

    it 'should return missing parameter if from is missing' do
      post outbound_sms_path, params: @valid_params.except(:from), headers: set_auth_header(@account)
      expect(json_resp['error']).to eq('From is missing')
    end
  end
end
