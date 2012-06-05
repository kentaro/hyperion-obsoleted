module ApplicationHelper
  def sign_in(user)
    return if user.nil?

    cookies.permanent[:token] = user.token
    current_user = user
  end

  def sign_out
    cookies.permanent[:token] = nil
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user
    if (token = cookies[:token])
      @_current_user ||= User.find_by_token(token)
    end
  end

  def current_user=(user)
    @_current_user = user
  end

  def return_to
    session[:return_to]
  end

  def set_return_to
    session[:return_to] = params[:return_to]
  end

  def return_to_or(target, *args)
    redirect_to(return_to || target, *args)
  end

  def toast
    flash[:toast]
  end

  def set_toast(toast)
    flash[:toast] = toast
  end
end
