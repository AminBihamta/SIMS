require "test_helper"

class FinancialRecordsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get financial_records_new_url
    assert_response :success
  end

  test "should get create" do
    get financial_records_create_url
    assert_response :success
  end
end
