class Api::V1::Items::MerchantsController < ApplicationController
  def show
    merchant = Item.find(params[:item_id]).merchant
    render_json(MerchantSerializer.new(merchant))
  end
end