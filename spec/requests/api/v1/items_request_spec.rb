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

  context 'get single item' do

    it 'returns an existing item succesfully' do
      item_model = create(:item)

      get "/api/v1/items/#{item_model.id}"

      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body).to be_a(Hash)
      expect(response_body).to have_key(:data)

      item = response_body[:data]
      expect(item).to be_a(Hash)
      expect(item).to have_key(:id)
      expect(item[:id]).to eq(item_model.id.to_s)
      expect(item).to have_key(:type)
      expect(item[:type]).to eq("item")
      expect(item).to have_key(:attributes)
      item_attr = item[:attributes]
      expect(item_attr).to have_key(:name)
      expect(item_attr[:name]).to eq(item_model.name)
      expect(item_attr).to have_key(:description)
      expect(item_attr[:description]).to eq(item_model.description)
      expect(item_attr).to have_key(:unit_price)
      expect(item_attr[:unit_price]).to eq(item_model.unit_price)
    end

    it 'returns an error if an item doesnt exists' do
      get "/api/v1/items/1"

      expect(response).to have_http_status(404)

      response_body = JSON.parse(response.body, symbolize_names: true)
      expected = { message: "your query could not be completed", errors: ["Couldn't find Item with 'id'=1"] }

      expect(response_body).to eq(expected)
    end
  end

  context 'create item' do
    
    it 'can create a successful item' do
      merchant = create(:merchant)
      item_params = ({
        name: "item name",
        description: "item description",
        unit_price: 150.00,
        merchant_id: merchant.id
      })
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

      expect(response).to be_successful
      expect(response).to have_http_status(201)

      item = Item.last
      expect(item.name).to eq(item_params[:name])
      expect(item.description).to eq(item_params[:description])
      expect(item.unit_price).to eq(item_params[:unit_price])
      expect(item.merchant_id).to eq(merchant.id)
    end

    it 'errors with missing params' do
      item_params = ({})
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
      expect(response).to have_http_status(400)

      response_body = JSON.parse(response.body, symbolize_names: true)
      expected = {
        message: "your query could not be completed",
        errors: ["params are missing or invalid"]
      }
      
      expect(response_body).to eq(expected)
      expect(Item.last).to be(nil)
    end

    it 'errors with incorrect validation' do
      merchant = create(:merchant)
      item_params = ({
        name: "",
        description: "",
        unit_price: "",
        merchant_id: ""
      })
      headers = {"CONTENT_TYPE" => "application/json"}

      post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)

      expect(response).to have_http_status(400)

      response_body = JSON.parse(response.body, symbolize_names: true)
      expected = {
        message: "your query could not be completed",
        errors: [
            "Merchant must exist",
            "Name can't be blank",
            "Description can't be blank",
            "Unit price can't be blank",
            "Unit price is not a number"
        ]
      }

      expect(response_body).to eq(expected)
    end
  end

end