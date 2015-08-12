class Api::PaymentController < ApplicationController

  def index
    render :json => Payment.all, status: :ok
  end

  def show
    render :json => Payment.first, status: :ok
  end

  def create
    render :json => {}, status: :internal_server_error
  end

  def update
    render :json => {}, status: :internal_server_error
  end

  def destroy
    render :json => {}, status: :internal_server_error
  end

end
