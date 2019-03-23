# -*- coding: utf-8 -*-
require 'barby/barcode/code_39'
require 'barby/outputter/png_outputter'

module OrdersHelper
  def barcode(order_id, *args)
    #return Barby::Code39::new('%06d' % [order_id]).to_svg.html_safe
    return Barby::Code39::new('%06d' % [order_id]).to_image(*args).to_data_url
  end
end
