# Rails::Diff::Time

A Rails helper gem to display time differences in a human-readable format.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-diff-time'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rails-diff-time

## Usage

In your Rails views, you can use the `diff_time` helper to display time differences:

```erb
<%= diff_time(Time.now + 3.days) %>
# Output: <span>3 days later</span>

<%= diff_time(Time.now - 2.hours) %>
# Output: <span>2 hours ago</span>

<%= diff_time(Time.now + 1.year + 2.months, "div", class: "time-diff") %>
# Output: <div class="time-diff">1 year 2 months later</div>
```

### Parameters

- `certain_time` (required): The time to compare with the current time
- `element_name` (optional, default: "span"): The HTML element to wrap the output
- `attributes` (optional, default: {}): HTML attributes to add to the element

## Examples

```erb
# Simple usage
<%= diff_time(user.created_at) %>

# Custom element
<%= diff_time(event.starts_at, "p") %>

# With CSS classes
<%= diff_time(post.published_at, "span", class: "text-muted", id: "post-time") %>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dhq_boiler/rails-diff-time.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

