Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: 'static#home'

  match '/logout', to: 'static#logout', via: [:get, :post]

  # This route is for develoment only, allows to impersonate random site user
  get 'impersonate/:email', to: 'static#impersonate', constraints: {email: /[^\/]+/} if Rails.env.development?

  scope protocol: 'https' do
    get 'me', to: 'redirect#me'
    get '/login', to: 'static#login'
    post '/login', to: 'static#login_post'
    post '/123contacts_signup', to: 'static#contacts_signup'
    get 'httpsify', to: 'static#httpsify'

    resource :request_reset, only: [:show, :create],  path: '/request-reset'
    resources :validation_tokens, only: [:show, :update]


    # top level status-reports must precede the nested routes
    # otherwise the nested routes hijack the collection methods
    resources :status_reports,
        except: [:new, :create],
        path: 'status-reports' do
      collection do
        get 'my', to: 'status_reports#my'
        get 'my/edit', to: 'status_reports#my_edit'
        post 'my/edit', to: 'status_reports#my_edit_post'
      end
    end

    {volunteers: 'voluntari', fellows: 'membri', coordinators: 'advisors'}.each do |k,v|
      resources k, path: v do
        collection do
          match 'search', via: [:get, :post]
          get 'assignments' if k == :volunteers
        end
        if k == :fellows
          resources :status_reports, shallow: true, path: 'status-reports' if k == :fellows
        end
      end
    end

    post 'projects/search', to: 'projects#search', as: :search_projects
    resources :projects do
      resources :members, except: [:new] do
        collection do
          get 'new_volunteer'
          get 'new_fellow'
        end
      end
      resources :status_reports, shallow: true, path: 'status-reports'
      resource :openings, shallow: true
    end

    resources :openings
    resources :meetings
    # resources :templates

  end

end
