require "test_helper"

class Page::ScanControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get page_scan_index_url
    assert_response :success
  end
end
