require "test_helper"

class Page::HubControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get page_hub_index_url
    assert_response :success
  end
end
