Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope :dejima do
    post 'detect', to: 'dejima#detect', controller: "dejima"
  end
  
end