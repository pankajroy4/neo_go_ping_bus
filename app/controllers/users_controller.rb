class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all
    authorize User
    respond_to do |format|
      format.json { render json: @users.as_json(except: [:otp, :otp_sent_at]) }
      format.html { render :index }
    end
  end

  def show
    @user = User.includes(profile_pic_attachment: :blob).find(params[:id])
    authorize @user
    respond_to do |format|
      format.html { render :show }
      format.json { render json: @user.as_json(except: [:otp, :otp_sent_at]) }
    end
  end

  def upload_profile_pic
    @user = User.find_by(id: params[:id].to_i)
    if @user == current_user
      profile_pic_file_size(params[:profile_pic])
      if !current_user.errors.any?
        current_user.profile_pic.attach(params[:profile_pic]) if params[:profile_pic].present?
        profile_pic_url = rails_blob_url(current_user.profile_pic)
        render json: { message: "Profile picture uploaded successfully", profile_pic_url: profile_pic_url }
      else
        render json: { error: current_user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "Not Allowed!" }, status: :unprocessable_entity
    end
  end

  def destroy_profile_pic
    @user = User.find_by(id: params[:id].to_i)
    if @user != current_user
      render json: { error: "Not allowed!" }, status: :unprocessable_entity
      return
    end

    if current_user.profile_pic.attached? && !current_user.errors.any?
      current_user.profile_pic.purge
      profile_pic_url = ActionController::Base.helpers.asset_path("profile_logo.jpg")
      render json: { message: "Profile picture deleted successfully", profile_pic_url: profile_pic_url }
    else
      error_message = current_user.errors.any? ? current_user.errors.full_messages : "Profile picture not found!"
      render json: { error: error_message }, status: :unprocessable_entity
    end
  end

  private

  def profile_pic_file_size(pic)
    if !pic.content_type.start_with?("image/")
      current_user.errors.add(:base, "Only image files are allowed.")
    elsif pic.size > 7.megabytes
      current_user.errors.add(:base, "File size too large, Maximum size is 7 MB.")
    end
  end
end
