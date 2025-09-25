class OtherLiability < ApplicationRecord
  include Accountable

  class << self
    def color
      "#737373"
    end

    def icon
      "minus"
    end

    def classification
      "liability"
    end

    def display_name
      I18n.t("accountable.types.other_liability.display_name")
    end
  end
end
