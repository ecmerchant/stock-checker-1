require 'test_helper'

class StocksControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get stocks_show_url
    assert_response :success
  end

end
