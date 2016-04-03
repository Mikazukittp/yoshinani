module PushNortification
  extend ActiveSupport::Concern

  def send_nortification(user, message, type, custom_data)
    return unless user.nortification_tokens.present?

    begin
      sns = Aws::SNS::Client.new(:access_key_id => ENV['AWS_ACCESS_KEY_ID'],
                         :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
                         :region => ENV['AWS_REGION'])

      user.nortification_tokens.each do |nortification_token|
        begin
          application_arn = nil
          json_message = nil

          case nortification_token.device_type
          when 'android'
            application_arn = ENV['GCM_SNS_APPLICATION_ARN']

            orig_message = {data: {message: message, type: type}.merge(custom_data)}
            json_message = JSON.generate({GCM: JSON.generate(orig_message)})
          when 'ios'
            application_arn = ENV['APNS_SNS_APPLICATION_ARN']
            p application_arn
            target_apns = Settings.aws.sns.target_apns.to_s

            orig_message = {aps: {alert: message, type: type}.merge(custom_data)}
            json_message = JSON.generate({target_apns => JSON.generate(orig_message)})
          end

          response = sns.create_platform_endpoint(
                                platform_application_arn: application_arn,
                                token: nortification_token.device_token)

          endpoint_arn = response[:endpoint_arn]

          sns.publish(target_arn: endpoint_arn, message: json_message, message_structure: 'json')
          Rails.logger.info "publish to User #{user.id} success"
        rescue => e
          Rails.logger.error "publish to User #{user.id} failed #{e.try!(:message)}"
        end
      end

    rescue => e
      Rails.logger.error "publish to User #{user.id} failed #{e.try!(:message)}"
    end
  end
end
