Rails.application.routes.draw do
  post '/ask', to: 'ask#ask'
  get '/feeling-lucky', to: 'ask#lucky'
end
