Sentry.init do |config|
  config.dsn = 'https://c6847ba7cf46a556186dda03b171d63b@o4504932332011520.ingest.sentry.io/4505950405525504'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 1.0
  # or
  config.traces_sampler = lambda do |context|
    true
  end
end