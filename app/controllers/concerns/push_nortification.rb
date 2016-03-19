module PushNortification
  extend ActiveSupport::Concern

  def send_nortification(device_token, message)
    sns = AWS::SNS.new(:access_key_id => ENV['AWS_ACCESS_KEY_ID'],
                       :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
                       :region => ENV['AWS_REGION'])

    client = sns.client
    response = client.create_platform_endpoint(
                          platform_application_arn: ENV['AWS_SNS_APPLICATION_ARN'],
                          token: device_token,
                          attributes: { userId: user_id})

    endpoint_arn = response[:endpoint_arn]

    if client.publish(target_arn: endpoint_arn, message: message, message_structure: 'json')
      Rails.logger.info "publish success"
    else
      Rails.logger.error "publish failed"
    end
  end
end