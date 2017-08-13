class Upload < ApplicationRecord

  mount_uploader :path, UploadUploader
  belongs_to :company
  belongs_to :user

end
