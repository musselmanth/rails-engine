class Api::V1::ItemsController < ApplicationController
  before_action :get_item, only: [:show, :update, :destroy]

  def index
    items = Item.get_page(params[:per_page], params[:page])
    render_json(ItemSerializer.new(items))
  end

  def show
    render_json(ItemSerializer.new(@item))
  end

  def create
    item = Item.new(item_params)
    if item.save
      render_json(ItemSerializer.new(item), :created)
    else
      render_json(ErrorSerializer.format_errors(item.errors.full_messages), :bad_request)
    end
  end

  def update
    if @item.update(item_params)
      render_json(ItemSerializer.new(@item), :accepted)
    else
      render_json(ErrorSerializer.format_errors(@item.errors.full_messages), :bad_request)
    end
  end

  def destroy
    @item.destroy!
  end

  private

  def get_item
    @item = Item.find(params[:id])
  end

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end