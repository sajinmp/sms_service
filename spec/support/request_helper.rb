module RequestHelper
  def set_auth_header(account)
    {'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(account.username, account.auth_id)}
  end

  def json_resp
    JSON.parse(response.body)
  end
end
