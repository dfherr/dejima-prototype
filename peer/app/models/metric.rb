class Metric < ApplicationRecord

  def self.get_current
    order(id: :desc).first_or_create!
  end

end
