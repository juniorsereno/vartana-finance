require "test_helper"

class AccountTest < ActiveSupport::TestCase
  include SyncableInterfaceTest, EntriesTestHelper

  setup do
    @account = @syncable = accounts(:depository)
    @family = families(:dylan_family)
  end

  test "can destroy" do
    assert_difference "Account.count", -1 do
      @account.destroy
    end
  end

  test "gets short/long subtype label" do
    account = @family.accounts.create!(
      name: "Test Investment",
      balance: 1000,
      currency: "USD",
      subtype: "hsa",
      accountable: Investment.new
    )

    assert_equal "HSA", account.short_subtype_label
    assert_equal "Health Savings Account", account.long_subtype_label

    # Test with nil subtype - should use the display_name from the accountable class
    account.update!(subtype: nil)
    # Since we're using I18n.t() in the display_name method, it should return the translated name
    assert_equal I18n.t("accountable.types.investment.display_name"), account.short_subtype_label
    assert_equal I18n.t("accountable.types.investment.display_name"), account.long_subtype_label
  end
end
