class Api::GroupsController < ApplicationController
  before_action :authenticate!
  before_action :set_group, only: %i(show update destroy)

  def index
    render json: @user.groups, status: :ok
  end

  def show
    render json: @group, status: :ok
  end

  def create
    begin
      @group = @user.groups.new(group_params)

      ActiveRecord::Base.transaction do
        @group.save!
        @group.group_users.create!(user_id: @user.id, status: 'active')
      end

      render json: @group, status: :ok

    rescue ActiveRecord::RecordInvalid => invalid
      render json: {message: "グループの作成に失敗しました" ,errors: invalid.record.errors.messages}, status: :internal_server_error
    end
  end

  def update
    if @group.update(group_params)
      render json: @group, status: :ok
    else
      render json: {message: "グループの更新に失敗しました", errors: @group.errors.messages}, status: :internal_server_error
    end
  end

  def destroy
    if @group.destroy
      render json: @group, status: :ok
    else
      render json: {message: "グループの削除に失敗しました", errors: @group.errors.messages}, status: :internal_server_error
    end
  end

  private

  def set_group
    @group = @user.groups.find_by(id: params[:id])
    unless @group.present?
      render json: {message: "指定されたIDのグループが見つかりません"}, status: :not_found
      return
    end
  end

  def group_params
    params.require(:group).permit(:name, :description)
  end
end
