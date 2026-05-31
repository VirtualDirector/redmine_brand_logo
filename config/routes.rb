# frozen_string_literal: true
Rails.application.routes.draw do
  post 'redmine_brand_logo/upload', to: 'redmine_brand_logo#upload', as: 'redmine_brand_logo_upload'
  get  'redmine_brand_logo/serve',  to: 'redmine_brand_logo#serve',  as: 'redmine_brand_logo_serve'
  post 'redmine_brand_logo/remove', to: 'redmine_brand_logo#remove', as: 'redmine_brand_logo_remove'
end
