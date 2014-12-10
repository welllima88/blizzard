Rails.application.routes.draw do
  
  # Register
    match '/', to: 'pos#index', via: [:get, :post]
  
  # Admin Section
    match '/admin/login', to: 'login#admin_login', via: [:get, :post]
    #match '/admin/sales', to: 'admin#sales', via: [:get, :post]
    
  # Legacy
    match '/:controller(/:action(/:id))(.:format)', to: "#{:controller}#{:action}", via: [:get, :post]
  
end
