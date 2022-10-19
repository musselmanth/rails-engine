class Api::V1::Items::FindsController < ApplicationController
  def show
    if valid_search?
      if params[:name]
        result = Item.name_search(params[:name])
      else
        result = Item.price_search(params[:min_price], params[:max_price])
      end
      render_json(ItemSerializer.new(result))
    else
      render_json(ErrorSerializer.format_errors(["Invalid Search Parameters"]), :bad_request)
    end
  end

  private

  def valid_search?
    (params[:name] && !params[:min_price] && !params[:max_price]) ||
    ((params[:min_price] || params[:max_price]) && !params[:name])
  end
end