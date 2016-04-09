# if 5 == 5
# if Rails.env.production?
  CarrierWave.configure do |config|
    config.storage = :fog
    config.fog_credentials = {
        :provider              => 'AWS',
        # :aws_access_key_id     => ENV['AWS_ACCESS_KEY_ID'],
        :aws_access_key_id     => 'AKIAIXRZP6RFK4QVAEWA',
        # :aws_secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
        :aws_secret_access_key => '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',
        :region                => ENV['AWS_REGION'],
    }

    case Rails.env
    when 'production'
        config.fog_directory  = 'yoshinani'
    when 'staging'
        config.fog_directory  = 'yoshinani-dev'
    when 'development'
        config.fog_directory  = 'yoshinani-development'
    when 'test'
        config.fog_directory  = 'yoshinani_test'
    end

    config.fog_public = true
  end
# else
#   CarrierWave.configure do |config|
#     config.storage = :file
#   end
# end
