json.extract! order, :id, :menu_id, :number, :name, :phone, :address, :buyer_id, :due, :due_datenum, :means, :total_price, :amount_paid, :balance, :payment, :state, :note, :created_at, :updated_at
json.url order_url(order, format: :json)
