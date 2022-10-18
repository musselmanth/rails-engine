require 'rails_helper'

RSpec.describe 'Items API' do

  context 'get items' do

    it 'returns a list of items' do
      create_list(:item, 10)

      get '/api/v1/items'

      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body).to have_key(:data)

      items = response_body[:data]

      expect(items).to be_an(Array)
      expect(items.length).to eq(10)

      items.each do |item|
        expect(item).to be_a Hash
        expect(item).to have_key(:id)
        expect(item[:id]).to be_a(String)
        expect(item).to have_key(:type)
        expect(item[:type]).to eq("item")
        expect(item).to have_key(:attributes)
        expect(item[:attributes]).to be_a(Hash)

        item_atts = item[:attributes]

        expect(item_atts).to have_key(:name)
        expect(item_atts[:name]).to be_a(String)
        expect(item_atts).to have_key(:description)
        expect(item_atts[:description]).to be_a(String)
        expect(item_atts).to have_key(:unit_price)
        expect(item_atts[:unit_price]).to be_a(Float)
      end
    end

    it 'returns an empty data array if there are no items' do
      get '/api/v1/items'

      expect(response).to be_successful
      parsed_response = JSON.parse(response.body, symbolize_names: true)

      expect(parsed_response).to have_key(:data)
      expect(parsed_response[:data]).to be_an(Array)
      expect(parsed_response[:data].empty?).to be(true)
    end

  end

end