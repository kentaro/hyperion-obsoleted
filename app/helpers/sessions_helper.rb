module SessionsHelper
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
end
