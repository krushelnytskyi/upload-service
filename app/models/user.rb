class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :companies, dependent: :delete_all
  has_many :uploads, dependent: :delete_all

  def paginated_uploads(per_page, page)
    uploads.order(created_at: :desc).paginate(page: page, per_page: per_page)
  end

  def update_with_password(params, *options)
    current_password = params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = if params[:password].blank? || valid_password?(current_password)
      update_attributes(params, *options)
    else
      self.assign_attributes(params, *options)
      self.valid?
      self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      false
    end

    clean_up_passwords
    result
  end

  def self.search(search)
    if search
      self.where('lower(name) LIKE ? OR lower(email) LIKE ?', "%#{search}%", "%#{search}%")
    else
      self.all
    end
  end

  def self.roles
    ['user', 'admin', 'super_admin']
  end
end
