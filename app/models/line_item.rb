class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  paginates_per 15

  def self.build_from_hash(h)
    # ActionController::Parameters のハッシュから，LineItem の Array を生成
    # する．
    line_items = []
    h.each do |index, h|
      line_items << new(
      h.permit(:id, :revision, :product_id, :quantity, :total_price))
    end
    line_items
  end

  def product_remain
    product.present? && 0 <= product.remain ? product.remain : ''
  end

  def product_name
    product.present? ? (product.title.present? ? product.title.name : '') : ''
  end

  def product_price
    product.present? ? product.price : ''
  end

  def product_size
    product.present? ? product.size : ''
  end

  def reserved
    persisted? ? quantity : 0
  end

  def total_price_delimited
    total_price.present? ? total_price.to_s(:delimited) : ''
  end
end
