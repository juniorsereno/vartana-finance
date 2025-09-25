#!/usr/bin/env ruby

# Quick test to verify translations are working
require_relative 'config/environment'

# Set locale to pt-BR
I18n.locale = :'pt-BR'

puts "Testing display names with pt-BR locale:"
puts "Depository: #{Depository.display_name}"
puts "Investment: #{Investment.display_name}"
puts "CreditCard: #{CreditCard.display_name}"
puts "OtherAsset: #{OtherAsset.display_name}"
puts "OtherLiability: #{OtherLiability.display_name}"

# Test what the balance sheet would see
family = Family.first
if family
  puts "\nTesting with actual family:"
  
  # Create test accounts
  dep_account = family.accounts.create!(name: "Test Dep", balance: 1000, currency: "USD", accountable: Depository.new)
  inv_account = family.accounts.create!(name: "Test Inv", balance: 2000, currency: "USD", accountable: Investment.new)
  oa_account = family.accounts.create!(name: "Test OA", balance: 3000, currency: "USD", accountable: OtherAsset.new)
  
  balance_sheet = BalanceSheet.new(family)
  asset_groups = balance_sheet.assets.account_groups
  
  puts "Asset groups found:"
  asset_groups.each do |group|
    puts "- #{group.name}: #{group.total}"
  end
  
  # Clean up
  dep_account.destroy
  inv_account.destroy
  oa_account.destroy
else
  puts "No family found for testing"
end
