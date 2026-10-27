# frozen_string_literal: true

Rails.application.routes.draw do
  mount Automation::Engine => "/automation"
end
