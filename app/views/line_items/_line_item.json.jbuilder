json.extract! line_item, :id, :order_id, :product_id, :quantity, :total_price, :created_at, :updated_at
json.url line_item_url(line_item, format: :json)
