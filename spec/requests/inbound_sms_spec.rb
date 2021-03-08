require 'rails_helper'

describe 'Inbound Sms Requests: ' do
  before do
    @account = Account.all.sample
    phone_number = @account.phone_numbers.sample
    @valid_params = {from: ('%010d' % rand(0..9999999999)).to_s, to: phone_number.number, text: 'STOP'}
  end

  describe 'Authentication' do
    it 'if missing should be forbidden' do
      post inbound_sms_path
      expect(response).to have_http_status(401)
    end
  end

  context 'with valid params' do
    it 'should return the message for success' do
      post inbound_sms_path, params: @valid_params, headers: set_auth_header(@account)
      expect(json_resp['message']).to eq('Inbound sms ok')
    end

    it 'should store from and to to redis if text is STOP' do
      post inbound_sms_path, params: @valid_params, headers: set_auth_header(@account)
      value = REDIS.get("stop/#{@valid_params[:from]}-#{@valid_params[:to]}")
      expect(value).to be_truthy
    end

    context 'to is missing in table' do
      it 'should return error' do
        @valid_params[:to] = '1234567890'
        post inbound_sms_path, params: @valid_params, headers: set_auth_header(@account)
        expect(json_resp['error']).to eq('To parameter not found')
      end
    end
  end

  context 'with invalid params' do
    it 'should return missing parameter if to is missing' do
      @valid_params[:to] = '1234'
      post inbound_sms_path, params: @valid_params, headers: set_auth_header(@account)
      expect(json_resp['error']).to eq('To is invalid')
    end

    it 'should return missing parameter if from is missing' do
      @valid_params[:from] = '1234'
      post inbound_sms_path, params: @valid_params, headers: set_auth_header(@account)
      expect(json_resp['error']).to eq('From is invalid')
    end
  end

  context 'with missing params' do
    it 'should return missing parameter if to is missing' do
      post inbound_sms_path, params: @valid_params.except(:to), headers: set_auth_header(@account)
      expect(json_resp['error']).to eq('To is missing')
    end

    it 'should return missing parameter if from is missing' do
      post inbound_sms_path, params: @valid_params.except(:from), headers: set_auth_header(@account)
      expect(json_resp['error']).to eq('From is missing')
    end

    it 'should return missing parameter if text is missing' do
      post inbound_sms_path, params: @valid_params.except(:text), headers: set_auth_header(@account)
      expect(json_resp['error']).to eq('Text is missing')
    end
  end
end
