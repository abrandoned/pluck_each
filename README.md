# PluckEach

ActiveRecord comes with find_each and find_in_batches to batch process records from a database.
ActiveRecord also has the method `pluck` which allows the selection of a single field without pulling the entire record into memory.

This gem combines these ideas and provides `pluck_each` and `pluck_in_batches` to allow batch processing of plucked fields from the db.

```ruby
  #
  # User.create(:first_name => "name1")
  # User.create(:first_name => "name2")
  # User.create(:first_name => "name3")
  # User.create(:first_name => "name4")
  # User.create(:first_name => "name5")
  #

User.all.pluck(:first_name) # => ["name1", "name2", "name3", "name4", "name5"]

# If the table is large you would want to "page" over these values
User.all.pluck_each(:first_name, :batch_size => 2) do |first_name| # default batch_size is 1000
  # do something with first_name
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pluck_each'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pluck_each

## Contributing

1. Fork it ( https://github.com/[my-github-username]/pluck_each/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
