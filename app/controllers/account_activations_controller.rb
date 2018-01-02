class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    #if user && !user.activated? && user.authenticated?(:activation, params[:id])
    if user && !user.activated?
      user.activate
      #log_in user
      flash[:success] = "激活成功，请登录！"
      redirect_to root_url
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
