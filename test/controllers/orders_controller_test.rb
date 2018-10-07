require 'test_helper'

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @order = orders(:one)
  end

  test "should get index" do
    get orders_url
    assert_response :success
  end

  test "should get new" do
    get new_order_url
    assert_response :success
  end

  test "should create order" do
    assert_difference('Order.count') do
      post orders_url, params: { order: { address: @order.address, amount_paid: @order.amount_paid, balance: @order.balance, buyer_id: @order.buyer_id, due: @order.due, due_datenum: @order.due_datenum, means: @order.means, menu_id: @order.menu_id, name: @order.name, note: @order.note, number: @order.number, payment: @order.payment, phone: @order.phone, state: @order.state, total_price: @order.total_price } }
    end

    assert_redirected_to order_url(Order.last)
  end

  test "should show order" do
    get order_url(@order)
    assert_response :success
  end

  test "should get edit" do
    get edit_order_url(@order)
    assert_response :success
  end

  test "should update order" do
    patch order_url(@order), params: { order: { address: @order.address, amount_paid: @order.amount_paid, balance: @order.balance, buyer_id: @order.buyer_id, due: @order.due, due_datenum: @order.due_datenum, means: @order.means, menu_id: @order.menu_id, name: @order.name, note: @order.note, number: @order.number, payment: @order.payment, phone: @order.phone, state: @order.state, total_price: @order.total_price } }
    assert_redirected_to order_url(@order)
  end

  test "should destroy order" do
    assert_difference('Order.count', -1) do
      delete order_url(@order)
    end

    assert_redirected_to orders_url
  end
end
