require 'has_authlogic_extensions'
ActionController::Base.class_eval do
  include HasAuthlogicExtensions::ActionController
end
