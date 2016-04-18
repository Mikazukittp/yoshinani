class IconImgUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  process :convert => 'jpg'

  process :resize_to_fill => [256, 256, gravity = ::Magick::CenterGravity]

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def filename
    'user_icon.jpg' if original_filename.present?
  end
end
