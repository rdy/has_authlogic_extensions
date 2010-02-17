module HasAuthlogicExtensions
  module ActionController
    def self.included(base)
      base.extend Has
    end

    module Has
      def has_authlogic_extensions
        around_filter :load_current_user
        helper_method :current_user_session, :current_user
        include HasAuthlogicExtensions::ActionController::InstanceMethods
      end
    end

    module InstanceMethods
      protected

      def store_location
        session[:return_to] = request.request_uri
      end

      def login_required
        unless current_user
          store_location
          flash[:notice] = "You must be logged in to access this page"
          redirect_to new_user_session_url
          return false
        end
        if !current_user.verified? && verification_required?
          redirect_to new_polymorphic_url([current_user, :verification])
          return false
        end
      end

      def logout_required
        if current_user
          store_location
          flash[:notice] = "You must be logged out to access this page"
          redirect_to :account
          return false
        end
      end

      def current_user_session
        return @current_user_session if defined?(@current_user_session)
        @current_user_session = UserSession.find
      end

      def current_user
        return @current_user if defined?(@current_user)
        @current_user = current_user_session && current_user_session.user
      end

      def redirect_back_or_default(default)
        redirect_to(session[:return_to] || default)
        session[:return_to] = nil
      end

      def load_current_user
        User.current_user = current_user
        yield
        User.current_user = nil
      end

      def verification_required?
        true
      end
    end
  end
end
