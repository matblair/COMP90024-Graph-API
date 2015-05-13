require 'test_helper'

class InfoControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get users" do
    get :users
    assert_response :success
  end

  test "should get tweets" do
    get :tweets
    assert_response :success
  end

  test "should get topics" do
    get :topics
    assert_response :success
  end

end
