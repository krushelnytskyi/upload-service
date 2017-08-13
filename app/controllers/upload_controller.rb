module Zip
  class IOOutputStream < ZipOutputStream
    def initialize io
      super '-'
      @outputStream = io
    end

    def stream
      @outputStream
    end
  end
end

require "carrierwave"

class UploadController < ApplicationController

  attr_accessor :company_id

  def new
    @company = Company.find(params[:company_id])
    @year = params[:year]
    @upload = @company.uploads.new(year: @year)
  end

  def create
    @upload = Upload.create(upload_params)

    @upload.user = current_user

    if @upload.save
      redirect_to root_path
    else
      flash[:error] = 'Cannot upload'
      redirect_back fallback_location: root_path
    end 

  end

  def edit
  end

  def update
  end

  def destroy
    upload = Upload.find(params[:id])
      
    if upload.user == current_user || current_user.role == 'super_admin'
      upload.destroy!
    else
      flash[:error] = 'You don\'t have permissions to delete this upload'
    end

    redirect_back fallback_location: root_path
  end

  def show
    @upload = Upload.find(params[:id])
    file = @upload.path.file
    send_file file.class.method_defined?(:url) ? file.url : file.file
  end

  def download_all
    if current_user.role == 'super_admin'
       if !Upload.all.blank?

        file_name = "#{Date.current}_uploads.zip"
        t = Tempfile.new('mio-file-temp-2016-02-19 10:41:53 +0100')
        Zip::ZipOutputStream.open(t.path) do |z|
          Upload.all.each do |f|
          file = f.path.file
          z.put_next_entry(file.filename)
          z.print IO.read(file.class.method_defined?(:url) ? file.url : file.file)
          end
        end

        send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => file_name
        t.close

        end
    else
      flash[:error] = 'You don\'t have permissions to delete this upload'
      redirect_back fallback_location: root_path
    end
  end

  private

  def upload_params
    params.require(:upload).permit(:path, :year, :company_id)
  end

end