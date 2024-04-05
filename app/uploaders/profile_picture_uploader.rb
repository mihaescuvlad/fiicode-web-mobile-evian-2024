class ProfilePictureUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :grid_fs

  def store_dir
    "#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  process resize_to_fill: [150, 150]

  def extension_allowlist
    %w(jpg jpeg gif png)
  end
end
