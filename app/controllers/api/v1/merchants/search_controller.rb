class Api::V1::Merchants::SearchController < ApplicationController

  def show
    if valid_search?
      result = Merchant.name_search(params[:name], 1)
      render_json(MerchantSerializer.new(result))
    else
      invalid_search_params
    end
  end

  def index
    if valid_search?
      result = Merchant.name_search(params[:name])
      render_json(MerchantSerializer.new(result))
    else
      invalid_search_params
    end
  end

  private

  def valid_search?
    params[:name] && !params[:name].empty?
  end
end