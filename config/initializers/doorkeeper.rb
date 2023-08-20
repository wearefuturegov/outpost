Doorkeeper.configure do  
  default_scopes :public
  
  # This block will be called to check whether the resource owner is authenticated or not.
  resource_owner_authenticator do
    current_user || begin
      session[:user_return_to] = request.fullpath
      redirect_to new_user_session_url
    end
  end

  # If you didn't skip applications controller from Doorkeeper routes in your application routes.rb
  # file then you need to declare this block in order to restrict access to the web interface for
  # adding oauth authorized applications. In other case it will return 403 Forbidden response
  # every time somebody will try to access the admin web interface.
  #
  admin_authenticator do
    unless current_user.admin_users === true
      redirect_to new_user_session_url
    end
  end

end
