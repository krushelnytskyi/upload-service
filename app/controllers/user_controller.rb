class UserController < ApplicationController

  def index
    active_param = params[:active] == 'canceled' ? false : true
    
    @target_users_name = active_param ? 'Active Users' : 'Suspended users'
    @user = User.new
    @users = User.where(active: active_param).where.not(id: current_user.id).search(params[:search]).order(created_at: :desc).paginate(page: params[:page], per_page: 20)
  end

  def new
  end

  def create
    user = User.create(user_params)

    if !user.save
      flash[:error] = 'Cannot create user'
    end

    redirect_back fallback_location: user_index_path
  end

  def show
    @user = User.find(params[:id])
    @user_uploads = @user.paginated_uploads(20, params[:page])
  end

  def update
    if params[:user][:password].blank?
      params[:user].delete("password")
    end

    @user = User.find(params[:id])
    @user.update_attributes(user_params)
  end

  def edit
    @user = User.find(params[:id])
  end

  def revoke_access
    user = User.find(params[:id])
    user.active = params[:active] || false
    user.save
    redirect_back fallback_location: user_index_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :role)
  end 

end