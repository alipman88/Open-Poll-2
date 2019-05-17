Rails.application.routes.draw do
  namespace :admin do
    resources :polls do
      resources :questions
    end

    resources :domains
  end

  ['', ':poll/'].each do |slug|
    get "#{ slug }" => 'votes#new'
    post "#{ slug }" => 'votes#create'
    get "#{ slug }v/:vote_hash" => 'votes#show'
    get "#{ slug }s" => 'votes#new'
    post "#{ slug }s" => 'votes#create'
    get "#{ slug }s/:vote_hash" => 'votes#new'
    post "#{ slug }s/:vote_hash" => 'votes#create'
    get "#{ slug }vote/:candidate_slug" => 'votes#new'
    post "#{ slug }vote/:candidate_slug" => 'votes#create'
    get "#{ slug }answers/:answer_id" => 'answers#show'
    get "#{ slug }results" => 'results#show'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
