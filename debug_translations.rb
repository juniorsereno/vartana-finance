#!/usr/bin/env ruby

# Debug script to check what display names are being returned
require_relative 'config/environment'

puts "Current locale: #{I18n.locale}"
puts "Default locale: #{I18n.default_locale}"
puts "Available locales: #{I18n.available_locales}"

puts "\n=== Display Names ==="
puts "Depository: #{Depository.display_name}"
puts "Investment: #{Investment.display_name}"
puts "CreditCard: #{CreditCard.display_name}"
puts "OtherAsset: #{OtherAsset.display_name}"
puts "OtherLiability: #{OtherLiability.display_name}"
puts "Loan: #{Loan.display_name}"
puts "Property: #{Property.display_name}"
puts "Vehicle: #{Vehicle.display_name}"
puts "Crypto: #{Crypto.display_name}"

puts "\n=== Translation Keys ==="
puts "depository: #{I18n.t('accountable.types.depository.display_name')}"
puts "investment: #{I18n.t('accountable.types.investment.display_name')}"
puts "credit_card: #{I18n.t('accountable.types.credit_card.display_name')}"
puts "other_asset: #{I18n.t('accountable.types.other_asset.display_name')}"
puts "other_liability: #{I18n.t('accountable.types.other_liability.display_name')}"
puts "loan: #{I18n.t('accountable.types.loan.display_name')}"
puts "property: #{I18n.t('accountable.types.property.display_name')}"
puts "vehicle: #{I18n.t('accountable.types.vehicle.display_name')}"
puts "crypto: #{I18n.t('accountable.types.crypto.display_name')}"
