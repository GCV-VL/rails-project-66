# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'webmock/minitest'

module ActiveSupport
  class TestCase
    # Make jobs run synchronously:
    setup do
      queue_adapter.perform_enqueued_jobs = true
      queue_adapter.perform_enqueued_at_jobs = true
    end

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    parallelize_setup do |worker|
      SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
    end
    parallelize_teardown do |_worker|
      SimpleCov.result
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

def t(*, **)
  I18n.t(*, **)
end

def assert_flash(i18n_path, type = :notice)
  assert_equal t(i18n_path), flash[type]
end

# Теперь OmniAuth в тестах не обращается к внешним источникам:
OmniAuth.config.test_mode = true

def mock_omni_auth(user, provider = :github)
  auth_hash = {
    provider: provider.to_s,
    uid: '12345',
    info: {
      email: user.email,
      nickname: user.nickname
    },
    credentials: {
      token: user.token
    }
  }
  OmniAuth.config.mock_auth[provider] = OmniAuth::AuthHash::InfoHash.new(auth_hash)
end

module ActionDispatch
  class IntegrationTest
    def sign_in(user, _options = {})
      mock_omni_auth(user)
      get callback_auth_url('github')
    end

    def signed_in?
      session[:user_id].present? && current_user.present?
    end

    def current_user
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end
end
