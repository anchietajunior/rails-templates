# Run the template, e.g.
# rails new -T -d postgresql -m ../path/to/this/file
gsub_file 'Gemfile', /^gem 'jbuilder'/, '# gem \'jbuilder\''

append_to_file 'Gemfile', <<-RUBY

gem 'bcrypt'

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
  # Install Rspec
  run 'rails generate rspec:install'

  # Add User model
  run 'rails g model User name email:string:uniq password_digest:string'

  # Add AppSession model
  run 'rails g model AppSession user:references token_digest:string'

  # Create the Current class
  create_file 'app/models/current.rb', <<-RUBY
  class Current < ActiveSupport::CurrentAttributes
    attribute :user, :app_session
  end
  RUBY

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
end

