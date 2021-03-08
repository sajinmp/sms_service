Rails.application.routes.draw do
  post 'inbound/sms', to: 'sms#inbound', as: 'inbound_sms'
  post 'outbound/sms', to: 'sms#outbound', as: 'outbound_sms'
end
