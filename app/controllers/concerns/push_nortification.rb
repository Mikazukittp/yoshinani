module PushNortification
  extend ActiveSupport::Concern

  def send_nortification(user, message)
    return unless user.nortification_tokens.present?

    begin
      sns = Aws::SNS::Client.new(:access_key_id => ENV['AWS_ACCESS_KEY_ID'],
                         :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
                         :region => ENV['AWS_REGION'])

      user.nortification_tokens.each do |nortification_token|
        response = sns.create_platform_endpoint(
                              platform_application_arn: ENV['AWS_SNS_APPLICATION_ARN'],
                              token: nortification_token.device_token)

        endpoint_arn = response[:endpoint_arn]

        sns.publish(target_arn: endpoint_arn, message: message, message_structure: 'json')
        Rails.logger.info "publish success"
      end

    rescue => e
      Rails.logger.error "publish to User #{user.id} failed #{e.try!(:message)}"
    end
  end
end