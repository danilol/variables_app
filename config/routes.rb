Rails.application.routes.draw do

  root 'welcome#index'

  resources :users, :origins, :origin_fields, :processids, :tables, :campaigns, :variables


  post "index" => "welcome#index"
  get  "index" => "welcome#index"

  post "/create_or_update_origin_field" => "origins#create_or_update_origin_field"
  get "/get_origin_field_to_update"     => "origins#get_origin_field_to_update"
  delete "/destroy_origin_field"        => "origins#destroy_origin_field"

  post "/create_origin_field_upload" => "origins#create_origin_field_upload"

  match '/export_script', to: 'scripts#index', via: [:get, :post]

  match 'variable_name_search'               , to: 'variables#name_search'          , :via => :get
  match 'campaign_variables_search/(:id)'    , to: 'campaigns#variables_search'     , :via => :get
  match 'table_variables_search/(:id)'       , to: 'tables#variables_search'        , :via => :get
  match 'processid_variables_search/(:id)'   , to: 'processids#variables_search'    , :via => :get
  match 'origin_field_name_search'           , to: 'origins#name_search'            , :via => :get
  match 'variable_origin_fields_search/(:id)', to: 'variables#origin_fields_search' , :via => :get

  get "user/index"
  get "/login"             => "users#login"
  post "/signin"           => "users#authenticate"
  get  "/signup"           => "users#new"
  get  "/logout"           => "users#logout"
  get  "/password"         => "users#password"
  post "/password_update"  => "users#password_update"

  get  "/remember_password/:id" => "users#remember_password_index", :as => "remember"
  post "/remember_password"     => "users#remember_password"

  get "/search/origin"    => "origins#search",    :as => "search_origin"
  get "/search/campaign"  => "campaigns#search",  :as => "search_campaign"
  get "/search/table"     => "tables#search",     :as => "search_table"
  get "/search/processid" => "processids#search", :as => "search_processid"
  get "/search/variable"  => "variables#search",  :as => "search_variable"
end
