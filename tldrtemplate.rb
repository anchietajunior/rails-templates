# Run the template, e.g.
# rails new -T -d postgresql -m ../path/to/this/file
gsub_file 'Gemfile', /^gem 'jsbuilder'/, '# gem \'jsbuilder\''

append_to_file 'Gemfile', <<-RUBY
gem 'devise'

group :development, :test do
  gem 'rspec-rails'
end

group :test do
  gem 'factory_bot'
  gem 'shoulda-matchers'
  gem 'database_cleaner-active_record'
  gem 'faker'
  gem 'vcr'
  gem 'webmock'
end
RUBY

after_bundle do
  # Install Devise
  run 'rails generate devise:install'
  run 'rails generate devise User'

  # Install Rspec
  run 'rails generate rspec:install'

  # Enable the spec/support folder
  gsub_file 'spec/rails_helper.rb', /# Dir\[Rails.root.join\('spec', 'support', '\*\*', '\*\.rb'\)\].sort.each { \|f\| require f \}/, "Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }"


  # Create spec/support folder
  run 'mkdir -p spec/support'

  # Add shoulda matchers support file
  create_file 'spec/support/shoulda_matchers.rb', <<-RUBY
  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
  RUBY

  # Add database_cleaner support file
  create_file 'spec/support/database_cleaner.rb', <<-RUBY
  RSpec.configure do |config|
    config.before(:suite) do
      DatabaseCleaner.clean_with(:truncation)
    end

    config.before(:each) do |example|
      DatabaseCleaner.strategy = if %i[feature request].include?(example.metadata[:type])
        :truncation
      else
        :transaction
      end

      DatabaseCleaner.start
    end

    config.after(:each) do
      DatabaseCleaner.clean
    end
  end
  RUBY

  # Add FactoryBot support file
  create_file 'spec/support/factory_bot.rb', <<-RUBY
  RSpec.configure do |config|
    config.include FactoryBot::Syntax::Methods
  end
  RUBY

  # Devise localhost configs
  inject_into_file 'config/environments/development.rb', before: "end\n" do <<~RUBY
      config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  RUBY
  end
end

