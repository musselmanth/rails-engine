class Api::V1::ItemsController < ApplicationController
  before_action :get_item, only: [:show]

  def index
    render_json(ItemSerializer.new(Item.all))
  end

  def show
    render_json(ItemSerializer.new(@item))
  end

  private

  def get_item
    @item = Item.find(params[:id])
  end
end