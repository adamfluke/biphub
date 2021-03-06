require_relative 'api_controller'

class Api::V1::SessionsController < ApiController

  def create
    @user = User.find_by_email(params[:email])
    if @user
      if @user.authenticate(params[:password])
        token = authenticity_token
        render :json => {token: token, id: @user.id, first_name: @user.first_name, last_name: @user.last_name, school_name: @user.school.name }
      else
        render :text => "User and Password Don't Match", :status => 403
      end
    else
      render :text => "User With That Email Not Found", :status => 403
    end
  end

  def show
    @user = User.where(id: params[:user_id]).first
    if @user
      if authenticated_user @user.id, params[:authenticity_token]
        token = authenticity_token
        render :json => {token: token, id: @user.id }
      else
        render :text => "User Id and Token Don't Match", :status => 403
      end
    else
      render :text => "User With That Id Not Found", :status => 403
    end

  end

  private
  def authenticity_token
    @user.create_authenticity_token
  end
end
