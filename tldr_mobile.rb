# frozen_string_literal: true

# Run the template, e.g.
# rails new myapp -a propshaft --css tailwind -m ../path/to/this/file
gsub_file 'Gemfile', /^gem 'jbuilder'/, '# gem \'jbuilder\''

append_to_file 'Gemfile', <<~RUBY
  gem 'bcrypt'
RUBY

after_bundle do
  # Add User model
  run 'rails g model User name email:string:uniq password_digest:string'

  # Create the Current class
  create_file 'app/models/current.rb', <<-RUBY
  class Current < ActiveSupport::CurrentAttributes
    attribute :user
  end
  RUBY

  # Install Strada using importmap
  run './bin/importmap pin @hotwired/stimulus @hotwired/strada'
end
