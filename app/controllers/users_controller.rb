class UsersController < ApplicationController
  before_action :logged_in, only: [:edit, :update, :destroy]
  before_action :correct_user, only: [:update, :destroy]

  # #A template for code to show only active users.
  # def index
  #   @users = User.where(activated: FILL_IN).paginate(page: params[:page])
  # end
  #
  # def show
  #   @user = User.find(params[:id])
  #   redirect_to root_url and return unless FILL_IN
  # end


  def new
    @user=User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      UserMailer.account_activation(@user).deliver_now
      #@user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url, flash: {success: "新账号注册成功,请登陆"}
    else
      flash[:warning] = "账号信息填写有误,再次尝试"
      render 'new'
    end
  end

  def edit
    #UserMailer.send_email.deliver_now
    @user=User.find_by_id(params[:id])
  end

  def update
    @user = User.find_by_id(params[:id])
    if @user.update_attributes(user_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to root_path, flash: flash
  end

  def destroy
    @user = User.find_by_id(params[:id])
    @user.destroy
    redirect_to users_path(new: false), flash: {success: "用户删除"}
  end


#----------------------------------- students function--------------------



  private

  def user_params
    params.require(:user).permit(:name, :email, :major, :department, :degree, :password,
                                 :password_confirmation)
  end

  # Confirms a logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    unless current_user?(@user)
      redirect_to root_url, flash: {:warning => '此操作需要管理员身份'}
    end
  end

  # Confirms a logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

end
