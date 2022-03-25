class Land < ApplicationRecord

  before_create :calculate_price_per_acre

  validates :site, :price, :acreage,
            presence: true
  validates :site_path, :landwatch_id,
            uniqueness: true,
            presence: true

  private

  def calculate_price_per_acre
    self.price_per_acre = price / acreage
  end

end
