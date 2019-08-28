Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'hello', to: 'application#hello', controller: 'application'

  scope :dejima do
    if Rails.application.config.prototype_role == :peer
      post 'detect', to: 'dejima#detect', controller: 'dejima'
      post 'update_peer_groups', to: 'dejima#update_peer_groups', controller: 'dejima'
      post 'propagate', to: 'dejima#propagate', controller: 'dejima'
      post 'update_dejima_table', to: 'dejima#update_dejima_table', controller: 'dejima'
    end
    if Rails.application.config.prototype_role == :client
      get 'create_user', to: 'dejima#create_user', controller: 'dejima'
    end
  end
end
