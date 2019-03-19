Rails.application.routes.draw do
  resources :gp40s, except: [:new]
  resources :gp10s, except: [:new]
  resources :wbgts, except: [:new]
  resources :surveys, except: [:new]
  resources :falls, except: [:new]
  resources :slopes, except: [:new]
  resources :rotations, except: [:new]
  resources :machines do
    get 'rotation' => 'rotations#list'
    get 'rotations' => 'rotations#group'

    get 'slope' => 'slopes#list'
    get 'slopes' => 'slopes#group'

    get 'fall' => 'falls#list'
    get 'falls' => 'falls#group'

    get 'survey' => 'surveys#list'
    get 'surveys' => 'surveys#group'

    get 'wbgt' => 'wbgts#list'
    get 'wbgts' => 'wbgts#group'

    get 'gp10' => 'gp10s#list'
    get 'gp10s' => 'gp10s#group'

    get 'gp40' => 'gp40s#list'
    get 'gp40s' => 'gp40s#group'
  end

  root to: 'home#index'
  post '/', to: 'home#autoupdate'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
