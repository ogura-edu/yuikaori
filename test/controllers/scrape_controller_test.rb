require 'test_helper'

class ScrapeControllerTest < ActionDispatch::IntegrationTest
  test "should get ameblo" do
    get scrape_ameblo_url
    assert_response :success
  end

  test "should get instagram" do
    get scrape_instagram_url
    assert_response :success
  end

  test "should get twitter" do
    get scrape_twitter_url
    assert_response :success
  end

end
