require "application_system_test_case"

class Settings::ApiKeysTest < ApplicationSystemTestCase
  setup do
    @user = users(:family_admin)
    @user.api_keys.destroy_all # Ensure clean state
    login_as @user
  end

  test "should show no API key state when user has no active keys" do
    visit settings_api_key_path

    assert_text "Crie Sua Chave de API"
    assert_text "Obtenha acesso programático aos seus dados do Maybe"
    assert_text "Acessar os dados da sua conta programaticamente"
    assert_link "Criar Chave de API", href: new_settings_api_key_path
  end

  test "should navigate to create new API key form" do
    visit settings_api_key_path
    click_link "Criar Chave de API"

    assert_current_path new_settings_api_key_path
    assert_text "Criar Nova Chave de API"
    assert_field "Nome da Chave de API"
    assert_text "Apenas Leitura"
    assert_text "Leitura/Escrita"
  end

  test "should create a new API key with selected scopes" do
    visit new_settings_api_key_path

    fill_in "Nome da Chave de API", with: "Test Integration Key"
    choose "Leitura/Escrita"

    click_button "Criar Chave de API"

    # Should redirect to show page with the API key details
    assert_current_path settings_api_key_path
    assert_text "Test Integration Key"
    assert_text "Sua Chave de API"

    # Should show the actual API key value
    api_key_display = find("#api-key-display")
    assert api_key_display.text.length > 30 # Should be a long hex string

    # Should show copy buttons
    assert_button "Copiar Chave de API"
    assert_link "Criar Nova Chave"
  end

  test "should show current API key details after creation" do
    # Create an API key first
    api_key = ApiKey.create!(
      user: @user,
      name: "Production API Key",
      display_key: "test_plain_key_123",
      scopes: [ "read_write" ]
    )

    visit settings_api_key_path

    assert_text "Sua Chave de API"
    assert_text "Production API Key"
    assert_text "Ativa"
    assert_text "Leitura/Escrita"
    assert_text "Nunca usada"
    assert_link "Criar Nova Chave"
    assert_button "Revogar Chave"
  end

  test "should show usage instructions and example curl command" do
    api_key = ApiKey.create!(
      user: @user,
      name: "Test API Key",
      display_key: "test_key_123",
      scopes: [ "read" ]
    )

    visit settings_api_key_path

    assert_text "Como usar sua chave de API"
    assert_text "curl -H \"X-Api-Key: test_key_123\""
    assert_text "/api/v1/accounts"
  end

  test "should allow regenerating API key" do
    api_key = ApiKey.create!(
      user: @user,
      name: "Old API Key",
      display_key: "old_key_123",
      scopes: [ "read" ]
    )

    visit settings_api_key_path
    click_link "Criar Nova Chave"

    # Should be on the new API key form
    assert_text "Criar Nova Chave de API"

    fill_in "Nome da Chave de API", with: "New API Key"
    choose "Apenas Leitura"
    click_button "Criar Chave de API"

    # Should redirect to show page with new key
    assert_text "New API Key"
    assert_text "Sua Chave de API"

    # Old key should be revoked
    api_key.reload
    assert api_key.revoked?
  end

  test "should allow revoking API key with confirmation" do
    api_key = ApiKey.create!(
      user: @user,
      name: "Test API Key",
      display_key: "test_key_123",
      scopes: [ "read" ]
    )

    visit settings_api_key_path

    # Click the revoke button to open the modal
    click_button "Revogar Chave"

    # Wait for the dialog and then confirm
    assert_selector "#confirm-dialog", visible: true
    within "#confirm-dialog" do
      click_button "Confirm"
    end

    # Wait for redirect after revoke
    assert_no_selector "#confirm-dialog"

    assert_text "Crie Sua Chave de API"
    assert_text "Obtenha acesso programático aos seus dados do Maybe"

    # Key should be revoked in the database
    api_key.reload
    assert api_key.revoked?
  end

  test "should redirect to show when user already has active key and tries to visit new" do
    api_key = ApiKey.create!(
      user: @user,
      name: "Existing API Key",
      display_key: "existing_key_123",
      scopes: [ "read" ]
    )

    visit new_settings_api_key_path

    assert_current_path settings_api_key_path
  end

  test "should show API key in navigation" do
    visit settings_api_key_path

    within("nav") do
      assert_text "API Key"
    end
  end

  test "should validate API key name is required" do
    visit new_settings_api_key_path

    # Try to submit without name
    choose "Apenas Leitura"
    click_button "Criar Chave de API"

    # Should stay on form with validation error
    assert_current_path new_settings_api_key_path
    assert_field "Nome da Chave de API" # Form should still be visible
    # The form might not show the validation error inline, but should remain on the form
  end

  test "should show last used timestamp when API key has been used" do
    api_key = ApiKey.create!(
      user: @user,
      name: "Used API Key",
      display_key: "used_key_123",
      scopes: [ "read" ],
      last_used_at: 2.hours.ago
    )

    visit settings_api_key_path

    assert_text "about 2 hours"
    assert_no_text "Nunca usada"
  end

  test "should show expiration date when API key has expiration" do
    api_key = ApiKey.create!(
      user: @user,
      name: "Expiring API Key",
      display_key: "expiring_key_123",
      scopes: [ "read" ],
      expires_at: 30.days.from_now
    )

    visit settings_api_key_path

    # Should show some indication of expiration (exact format may vary)
    assert_no_text "Never expires"
  end
end
