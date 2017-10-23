# ApiGem

A wrapper for a particular API.

The idea here is to try and transparently return response objects to the caller as much as possible, in order to allow full access to the resulting data.

Methods that require an unique identifier will also accept a "src" url, which will be parsed to extract the id(s) needed.

See the Usage Examples section below for details.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'api_gem'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install api_gem

## Usage Examples

```ruby
require 'api_gem'

ENV['api_gem_username'] = 'your.username@example.com'
ENV['api_gem_password'] = 'your.password'

client = ApiGem::Client.new
list_name = "Urgent #{rand(99999)}"
response = client.create_list({list: {name: list_name}})
puts [CREATE_LIST: response]

lists = JSON.parse(client.get_all_lists.body)
src = lists.fetch('lists').first.fetch('src')
response = client.update_list(src, {list: {name: "foo #{rand(99999)}"}})
puts [UPDATE_LIST: response]

response = client.create_item(src, {item: {name: "this be an item"}})
puts [CREATE_ITEM: response]

list = JSON.parse(client.get_list(src).body)
puts [GET_LIST: list]
item_src = list.fetch('items').first.fetch('src')
response = client.finish_item(nil, nil, item_src)
puts [FINISH_ITEM: response]

puts [GET_LIST: JSON.parse(client.get_list(src).body)]
response = client.delete_item(nil, nil, item_src)
puts [DELETE_ITEM: response]

lists = JSON.parse(client.get_all_lists.body).fetch('lists')
lists.each do |l|
  src = l.fetch('src')
  res = client.delete_list(src)
  puts [DELETE_LIST: res, src: src]
end

lists = JSON.parse(client.get_all_lists.body).fetch('lists')
puts [GET_ALL_LISTS: lists]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/allred/api_gem. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ApiGem project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/api_gem/blob/master/CODE_OF_CONDUCT.md).
