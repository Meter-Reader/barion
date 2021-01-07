# frozen_string_literal: true

module Barion
  class ApplicationMailer < ActionMailer::Base
    default from: 'from@example.com'
    layout 'mailer'
  end
end
