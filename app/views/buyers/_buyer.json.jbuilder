json.extract! buyer, :id, :name, :phone, :address, :customer_id, :created_at, :updated_at
json.url buyer_url(buyer, format: :json)
