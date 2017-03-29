class Product < ApplicationRecord
  enum status: [:active, :inactive]
  has_many :product_quantities

  mount_uploader :photo, PhotoUploader
  mount_uploader :photo_addic, PhotoUploader
end
