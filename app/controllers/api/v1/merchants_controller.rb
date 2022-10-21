class Api::V1::MerchantsController < ApplicationController
  before_action :get_merchant, only: [:show]

  def index
    merchants = Merchant.get_page(params[:per_page], params[:page])
    render json: MerchantSerializer.new(merchants)
  end

  def show
    render json: MerchantSerializer.new(@merchant)
  end

  private

  def get_merchant
    @merchant = Merchant.find(params[:id])
  end
  
end