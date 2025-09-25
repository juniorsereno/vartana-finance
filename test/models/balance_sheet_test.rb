require "test_helper"

class BalanceSheetTest < ActiveSupport::TestCase
  setup do
    @family = families(:empty)
  end

  test "calculates total assets" do
    assert_equal 0, BalanceSheet.new(@family).assets.total

    create_account(balance: 1000, accountable: Depository.new)
    create_account(balance: 5000, accountable: OtherAsset.new)
    create_account(balance: 10000, accountable: CreditCard.new) # ignored

    assert_equal 1000 + 5000, BalanceSheet.new(@family).assets.total
  end

  test "calculates total liabilities" do
    assert_equal 0, BalanceSheet.new(@family).liabilities.total

    create_account(balance: 1000, accountable: CreditCard.new)
    create_account(balance: 5000, accountable: OtherLiability.new)
    create_account(balance: 10000, accountable: Depository.new) # ignored

    assert_equal 1000 + 5000, BalanceSheet.new(@family).liabilities.total
  end

  test "calculates net worth" do
    assert_equal 0, BalanceSheet.new(@family).net_worth

    create_account(balance: 1000, accountable: CreditCard.new)
    create_account(balance: 50000, accountable: Depository.new)

    assert_equal 50000 - 1000, BalanceSheet.new(@family).net_worth
  end

  test "disabled accounts do not affect totals" do
    create_account(balance: 1000, accountable: CreditCard.new)
    create_account(balance: 10000, accountable: Depository.new)

    other_liability = create_account(balance: 5000, accountable: OtherLiability.new)
    other_liability.disable!

    assert_equal 10000 - 1000, BalanceSheet.new(@family).net_worth
    assert_equal 10000, BalanceSheet.new(@family).assets.total
    assert_equal 1000, BalanceSheet.new(@family).liabilities.total
  end

  test "calculates asset group totals" do
    create_account(balance: 1000, accountable: Depository.new)
    create_account(balance: 2000, accountable: Depository.new)
    create_account(balance: 3000, accountable: Investment.new)
    create_account(balance: 5000, accountable: OtherAsset.new)
    create_account(balance: 10000, accountable: CreditCard.new) # ignored

    asset_groups = BalanceSheet.new(@family).assets.account_groups

    assert_equal 3, asset_groups.size

    # Find groups by their display names (which should be translated)
    depository_group = asset_groups.find { |ag| ag.name == Depository.display_name }
    investment_group = asset_groups.find { |ag| ag.name == Investment.display_name }
    other_asset_group = asset_groups.find { |ag| ag.name == OtherAsset.display_name }

    assert_not_nil depository_group, "Could not find depository group. Available groups: #{asset_groups.map(&:name)}"
    assert_not_nil investment_group, "Could not find investment group. Available groups: #{asset_groups.map(&:name)}"
    assert_not_nil other_asset_group, "Could not find other asset group. Available groups: #{asset_groups.map(&:name)}"

    assert_equal 1000 + 2000, depository_group.total
    assert_equal 3000, investment_group.total
    assert_equal 5000, other_asset_group.total
  end

  test "calculates liability group totals" do
    create_account(balance: 1000, accountable: CreditCard.new)
    create_account(balance: 2000, accountable: CreditCard.new)
    create_account(balance: 3000, accountable: OtherLiability.new)
    create_account(balance: 5000, accountable: OtherLiability.new)
    create_account(balance: 10000, accountable: Depository.new) # ignored

    liability_groups = BalanceSheet.new(@family).liabilities.account_groups

    assert_equal 2, liability_groups.size

    # Find groups by their display names (which should be translated)
    credit_card_group = liability_groups.find { |ag| ag.name == CreditCard.display_name }
    other_liability_group = liability_groups.find { |ag| ag.name == OtherLiability.display_name }

    assert_not_nil credit_card_group, "Could not find credit card group. Available groups: #{liability_groups.map(&:name)}"
    assert_not_nil other_liability_group, "Could not find other liability group. Available groups: #{liability_groups.map(&:name)}"

    assert_equal 1000 + 2000, credit_card_group.total
    assert_equal 3000 + 5000, other_liability_group.total
  end

  private
    def create_account(attributes = {})
      account = @family.accounts.create! name: "Test", currency: "USD", **attributes
      account
    end
end
