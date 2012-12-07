ApplicationConfig = YAML.load_file(File.join(Rails.root, 'config', 'application.yml'))[Rails.env].symbolize_keys
GithubConfig = ApplicationConfig[:github].symbolize_keys