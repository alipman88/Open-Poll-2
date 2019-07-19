Rails.application.routes.draw do
  namespace :admin do
    get '' => 'admin#index'

    resources :polls do
      get 'results' => 'results#results'
      get 'results/:question_id_1' => 'results#results'
      get 'results/:question_id_1/:question_id_2' => 'results#results'
      get 'crosstabs' => 'results#crosstabs'
      get 'crosstabs/:question_id_1' => 'results#crosstabs'
      get 'crosstabs/:question_id_1/:question_id_2' => 'results#crosstabs'
      resources :answers

      resources :questions do
        resources :answers
      end
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
    get "#{ slug }results" => 'results#results'
    get "#{ slug }results/:question_id" => 'results#results'
    get "#{ slug }results/:question_id_1/:question_id_2" => 'results#results'
    get "#{ slug }crosstabs" => 'results#crosstabs'
    get "#{ slug }crosstabs/:question_id_1" => 'results#crosstabs'
    get "#{ slug }crosstabs/:question_id_1/:question_id_2" => 'results#crosstabs'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
