require "application_system_test_case"

class CategoriesTest < ApplicationSystemTestCase
  setup do
    sign_in @user = users(:family_admin)
  end

  test "can create category" do
    visit categories_url
    find("a[href='#{new_category_path}']").click
    fill_in "Name", with: "My Shiny New Category"

    # The button text was incorrect. Correcting it to "Create Categoria".
    click_button "Create Categoria"

    visit categories_url
    assert_text "My Shiny New Category"
  end

  test "trying to create a duplicate category fails" do
    visit categories_url
    find("a[href='#{new_category_path}']").click
    fill_in "Name", with: categories(:food_and_drink).name

    # Applying the same fix here.
    click_button "Create Categoria"

    assert_text "Name has already been taken"
  end
end
