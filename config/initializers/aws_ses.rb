
ActionMailer::Base.add_delivery_method :aws_ses, AWS::SES::Base,
  access_key_id: ENV['AWS_ACCESS_KEY'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  server: 'email.us-east-1.amazonaws.com'
