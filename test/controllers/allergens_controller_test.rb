require "test_helper"

class AllergensControllerTest < ActionDispatch::IntegrationTest
  setup do
    @allergen = allergens(:one)
  end

  test "should get index" do
    get allergens_url
    assert_response :success
  end

  test "should get new" do
    get new_allergen_url
    assert_response :success
  end

  test "should create allergen" do
    assert_difference("Allergen.count") do
      post allergens_url, params: { allergen: {  } }
    end

    assert_redirected_to allergen_url(Allergen.last)
  end

  test "should show allergen" do
    get allergen_url(@allergen)
    assert_response :success
  end

  test "should get edit" do
    get edit_allergen_url(@allergen)
    assert_response :success
  end

  test "should update allergen" do
    patch allergen_url(@allergen), params: { allergen: {  } }
    assert_redirected_to allergen_url(@allergen)
  end

  test "should destroy allergen" do
    assert_difference("Allergen.count", -1) do
      delete allergen_url(@allergen)
    end

    assert_redirected_to allergens_url
  end
end
