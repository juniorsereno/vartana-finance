class OtherAsset < ApplicationRecord
  include Accountable

  class << self
    def color
      "#12B76A"
    end

    def icon
      "plus"
    end

    def classification
      "asset"
    end

    def display_name
      I18n.t("accountable.types.other_asset.display_name")
    end
  end
end
