Github.configure do |config|
  config.client_id        = GithubConfig[:id]
  config.client_secret    = GithubConfig[:secret]
  config.adapter          = :net_http
end