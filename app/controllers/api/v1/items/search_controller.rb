class Api::V1::Items::SearchController < ApplicationController
  def show
    if name_search?
      render_json(ItemSerializer.new(Item.name_search(params[:name], 1)))
    elsif price_search?
      render_json(ItemSerializer.new(Item.price_search(params[:min_price], params[:max_price], 1)))
    else
      invalid_search_params
    end
  end

  def index
    if name_search?
      render_json(ItemSerializer.new(Item.name_search(params[:name])))
    elsif price_search?
      render_json(ItemSerializer.new(Item.price_search(params[:min_price], params[:max_price])))
    else
      invalid_search_params
    end
  end

  private

  def name_search?
    name = params[:name]; min = params[:min_price]; max = params[:max_price]
    name && !min && !max && !name.empty?
  end

  def price_search?
    name = params[:name]; min = params[:min_price]; max = params[:max_price]
    if min && max
      max.to_f >= min.to_f && min.to_f >= 0 && max.to_f >= 0 && !min.empty? && !max.empty? && !name
    else
      ((min && min.to_f >= 0 && !min.empty?) || (max && max.to_f >= 0 && !max.empty?)) && !name
    end
  end

end