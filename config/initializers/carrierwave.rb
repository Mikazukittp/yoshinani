require 'dotenv'
Dotenv.load

unless Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :fog
    config.fog_credentials = {
        :provider              => 'AWS',
        :aws_access_key_id     => 'AKIAIXRZP6RFK4QVAEWA',
        :aws_secret_access_key => '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',
        :region                => 'ap-northeast-1',
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
