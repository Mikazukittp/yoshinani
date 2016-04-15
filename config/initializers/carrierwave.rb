unless Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :fog
    config.fog_credentials = {
        :provider              => 'AWS',
        :aws_access_key_id     => ENV['AWS_S3_ACCESS_KEY_ID'],
        :aws_secret_access_key => ENV['AWS_S3_SECRET_ACCESS_KEY'],
        :region                => ENV['AWS_REGION'],
    }

    case Rails.env
    when 'production'
        config.fog_directory  = 'yoshinani'
    when 'dev'
        config.fog_directory  = 'yoshinani-dev'
    when 'development'
        config.fog_directory  = 'yoshinani-development'
    end

    config.fog_public = true
  end
else
  CarrierWave.configure do |config|
    config.storage = :file
  end
end
