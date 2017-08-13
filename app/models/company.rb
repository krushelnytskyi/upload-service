class Company < ApplicationRecord

  belongs_to :user
  has_many :uploads, dependent: :delete_all

  def self.search(search)
    if search
      self.where('lower(name) LIKE ?', "%#{search}%")
    else
      self.all
    end
  end

  def self.year_range(year_count)
    current_year = Date.current.year
    return (current_year - year_count .. current_year).to_a
  end

end