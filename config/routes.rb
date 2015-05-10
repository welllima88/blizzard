Rails.application.routes.draw do
  
  # Register
   # match '/', to: 'pos#index', via: [:get, :post]
   
   match '/', to: 'aurora#index', via: [:get, :post]
  
  # Admin Section
    match '/admin/login', to: 'login#admin_login', via: [:get, :post]
    match '/login', to: 'login#admin_login', via: [:get, :post]
    match '/admin/complete_logoff', to: 'login#complete_logoff', via: [:get, :post]
    
  # Legacy
    match '/:controller(/:action(/:id))(.:format)', to: "#{:controller}#{:action}", via: [:get, :post]
  
end
