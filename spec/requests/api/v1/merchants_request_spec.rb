require 'rails_helper'

RSpec.describe "Merchants API" do

  context 'get merchants' do
    it 'sends a list of merchants' do
      create_list(:merchant, 5)

      get '/api/v1/merchants'

      expect(response).to be_successful

      parsed_response = JSON.parse(response.body, symbolize_names: true)

      expect(parsed_response).to have_key(:data)
      expect(parsed_response[:data]).to be_an(Array)
      expect(parsed_response[:data].length).to eq(5)

      merchants = parsed_response[:data]

      merchants.each do |merchant|
        expect(merchant).to have_key(:id)
        expect(merchant[:id]).to be_a(String)
        expect(merchant).to have_key(:type)
        expect(merchant[:type]).to eq("merchant")
        expect(merchant).to have_key(:attributes)
        expect(merchant[:attributes]).to be_a(Hash)
        expect(merchant[:attributes]).to have_key(:name)
        expect(merchant[:attributes][:name]).to be_a(String)
      end
    end

    it 'sends an empty data array if there are no merchants' do
      get '/api/v1/merchants'

      expect(response).to be_successful
      parsed_response = JSON.parse(response.body, symbolize_names: true)

      expect(parsed_response).to have_key(:data)
      expect(parsed_response[:data]).to be_an(Array)
      expect(parsed_response[:data].empty?).to be(true)
    end
  end

  context 'get single merchant' do

    it 'returns the merchant data' do
      merchant_model = create(:merchant)
      get "/api/v1/merchants/#{merchant_model.id}"

      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)

      expect(response_body).to have_key(:data)
      expect(response_body[:data]).to be_a(Hash)

      merchant = response_body[:data]

      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to eq(merchant_model.id.to_s)
      expect(merchant[:type]).to eq("merchant")
      expect(merchant[:attributes]).to be_a(Hash)
      merch_attr = merchant[:attributes]
      expect(merch_attr).to have_key(:name)
      expect(merch_attr[:name]).to eq(merchant_model.name)
    end

    it 'returns expected response when merchant not found' do
      get '/api/v1/merchants/1'

      expect(response).to have_http_status(404)

      response_body = JSON.parse(response.body, symbolize_names: true)
      expected = { message: "your query could not be completed", errors: ["Couldn't find Merchant with 'id'=1"] }

      expect(response_body).to eq(expected)
    end
  end

  context 'get all merchant items' do
    it 'returns list of merchant items' do
      merchant = create(:merchant)
      merchant.items = create_list(:item, 3)

      get "/api/v1/merchants/#{merchant.id}/items"

      expect(response).to be_successful
      
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body).to have_key(:data)
      expect(response_body[:data]).to be_an(Array)
      items = response_body[:data]
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

    it 'returns error merchant not found' do
      get "/api/v1/merchants/1/items"

      expect(response).to have_http_status(404)
      
      response_body = JSON.parse(response.body, symbolize_names: true)
      expected = { message: "your query could not be completed", errors: ["Couldn't find Merchant with 'id'=1"] }

      expect(response_body).to eq(expected)
    end

    it 'returns empty array for data if merchant has no items' do
      merchant = create(:merchant)

      get "/api/v1/merchants/#{merchant.id}/items"

      expect(response).to be_successful

      response_body = JSON.parse(response.body, symbolize_names: true)
      expected = { data: [] }

      expect(response_body).to eq(expected)
    end
  end

  context 'find / find_all' do
    let(:inv_search_error) {{message: "your query could not be completed", errors: ["invalid search parameters"]}}

    it 'errors appropriately' do
      get "/api/v1/merchants/find?name="
      expect(response).to have_http_status(400)
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_search_error)
      get "/api/v1/merchants/find"
      expect(response).to have_http_status(400)
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_search_error)
      get "/api/v1/merchants/find_all?name="
      expect(response).to have_http_status(400)
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_search_error)
      get "/api/v1/merchants/find_all"
      expect(response).to have_http_status(400)
      expect(JSON.parse(response.body, symbolize_names: true)).to eq(inv_search_error)
    end

    it 'returns empty object if no result for find' do
      merchant = create(:merchant, name: "aaa")
      get "/api/v1/merchants/find?name=bbb"
      expect(response).to be_successful
      expect(response).to have_http_status(200)
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body).to eq({data: {}})
    end

    it 'returns empty array if no result for find_all' do
      merchant_1 = create(:merchant, name: "aaa")
      merchant_2 = create(:merchant, name: "bbb")

      get "/api/v1/merchants/find_all?name=ccc"

      expect(response).to be_successful
      expect(response).to have_http_status(200)
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body).to eq({data: []})
    end

    it 'returns single result for find' do
      merchant_1 = create(:merchant, name: "ac")
      merchant_2 = create(:merchant, name: "bbb")
      merchant_3 = create(:merchant, name: "ab")

      get "/api/v1/merchants/find?name=a"
      expect(response).to be_successful
      expect(response).to have_http_status(200)
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body).to have_key(:data)
      expect(response_body[:data]).to be_a(Hash)
      expect(response_body[:data][:id]).to eq(merchant_3.id.to_s) 
    end

    it 'returns multiple results for find_all' do
      merchant_1 = create(:merchant, name: "ac")
      merchant_2 = create(:merchant, name: "bbb")
      merchant_3 = create(:merchant, name: "ab")

      get "/api/v1/merchants/find_all?name=a"
      expect(response).to be_successful
      expect(response).to have_http_status(200)
      response_body = JSON.parse(response.body, symbolize_names: true)
      expect(response_body).to have_key(:data)
      expect(response_body[:data]).to be_an(Array)
      expect(response_body[:data].length).to eq(2)
      expect(response_body[:data][0][:id]).to eq(merchant_3.id.to_s) 
      expect(response_body[:data][1][:id]).to eq(merchant_1.id.to_s) 
    end
    
  end

end