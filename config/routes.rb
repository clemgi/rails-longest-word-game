Rails.application.routes.draw do
  get '/game', to:'longword#game'
  get '/score', to:'longword#score'

  root to: 'longword#game'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
