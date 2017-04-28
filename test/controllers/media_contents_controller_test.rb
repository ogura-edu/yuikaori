require 'test_helper'

class MediaContentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get media_contents_index_url
    assert_response :success
  end

end
