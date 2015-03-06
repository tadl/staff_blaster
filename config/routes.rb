Rails.application.routes.draw do
  match "phone/receive" => "phone#receive", via: [:get, :post]
  match "phone/verify_admin" => "phone#verify_admin", via: [:get, :post]
  match "phone/select_location" => "phone#select_location", via: [:get, :post]
  match "phone/record_message" => "phone#record_message", via: [:get, :post]
  match "phone/review_call" => "phone#review_call", via: [:get, :post]
  match "phone/send_message" => "phone#send_message", via: [:get, :post]
  match "phone/prompt_clear_alerts" => "phone#prompt_clear_alerts", via: [:get, :post]
  match "phone/clear_alerts" => "phone#clear_alerts", via: [:get, :post]
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
