require "test_helper"

class Page::SearchControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get page_search_index_url
    assert_response :success
  end
end
