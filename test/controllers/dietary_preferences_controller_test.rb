require "test_helper"

class DietaryPreferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dietary_preference = dietary_preferences(:one)
  end

  test "should get index" do
    get dietary_preferences_url
    assert_response :success
  end

  test "should get new" do
    get new_dietary_preference_url
    assert_response :success
  end

  test "should create dietary_preference" do
    assert_difference("DietaryPreference.count") do
      post dietary_preferences_url, params: { dietary_preference: {  } }
    end

    assert_redirected_to dietary_preference_url(DietaryPreference.last)
  end

  test "should show dietary_preference" do
    get dietary_preference_url(@dietary_preference)
    assert_response :success
  end

  test "should get edit" do
    get edit_dietary_preference_url(@dietary_preference)
    assert_response :success
  end

  test "should update dietary_preference" do
    patch dietary_preference_url(@dietary_preference), params: { dietary_preference: {  } }
    assert_redirected_to dietary_preference_url(@dietary_preference)
  end

  test "should destroy dietary_preference" do
    assert_difference("DietaryPreference.count", -1) do
      delete dietary_preference_url(@dietary_preference)
    end

    assert_redirected_to dietary_preferences_url
  end
end
