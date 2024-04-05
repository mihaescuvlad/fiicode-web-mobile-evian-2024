class User::GridfsController < UserApplicationController
  before_action :authenticate_user!, only: [:serve]

  def serve
    filename = params[:path]
    file_extension = params[:format]
    gridfs_path = "#{filename}.#{file_extension}"

    begin
      gridfs_file = Mongoid::GridFS[gridfs_path]
      self.response_body = gridfs_file.data
      self.content_type = gridfs_file.content_type
    rescue
      self.status = :file_not_found
      self.content_type = 'text/plain'
      self.response_body = ''
    end
  end
end