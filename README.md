# rails-diff-time

A Rails helper gem to display time differences in a human-readable format with automatic updates.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-diff-time'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install rails-diff-time

## Setup

No setup required! Just install the gem and start using it. The auto-update JavaScript will be automatically included when you use `auto_update: true` for the first time on a page.

## Usage

In your Rails views, you can use the `diff_time` helper to display time differences:

```erb
<%= diff_time(Time.now + 3.days) %>
# Output: <span>3 days later</span>

<%= diff_time(Time.now - 2.hours) %>
# Output: <span>2 hours ago</span>

<%= diff_time(Time.now + 1.year + 2.months, "div", { class: "time-diff" }) %>
# Output: <div class="time-diff">1 year 2 months later</div>
```

### Auto-update Feature

Enable automatic updates (every 1 minute) by passing the `auto_update: true` option:

```erb
<%= diff_time(user.created_at, auto_update: true) %>
# The display will automatically update every minute

<%= diff_time(post.published_at, "span", { class: "timestamp" }, auto_update: true) %>
# With custom element and attributes
```

**Note:** The necessary JavaScript code will be automatically included on the page the first time you call `diff_time` with `auto_update: true`. No manual setup required!

### Parameters

```ruby
diff_time(certain_time, element_name = "span", attributes = {}, auto_update: false)
```

- `certain_time` (required): The time to compare with the current time
- `element_name` (optional, default: "span"): The HTML element to wrap the output
- `attributes` (optional, default: {}): HTML attributes to add to the element
- `auto_update` (optional, default: false): Enable automatic updates every minute (JavaScript automatically included on first use)

## Examples

```erb
# Simple usage
<%= diff_time(user.created_at) %>

# Custom element
<%= diff_time(event.starts_at, "p") %>

# With CSS classes
<%= diff_time(post.published_at, "span", { class: "text-muted", id: "post-time" }) %>

# With auto-update enabled (JavaScript automatically included)
<%= diff_time(meeting.scheduled_at, "span", { class: "meeting-time" }, auto_update: true) %>

# Live timestamps for comments
<% @comments.each do |comment| %>
  <div class="comment">
    <p><%= comment.body %></p>
    <small>Posted <%= diff_time(comment.created_at, auto_update: true) %></small>
  </div>
<% end %>
```

### Complete Example

**app/views/posts/show.html.erb:**
```erb
<article>
  <h1><%= @post.title %></h1>
  <p class="meta">
    Published <%= diff_time(@post.published_at, auto_update: true) %>
  </p>
  <div><%= @post.content %></div>
</article>
```

That's it! No need to modify layout files or configure JavaScript imports.

## How It Works

The auto-update feature works by:

1. Storing the original timestamp in a `data-certain-time` attribute (ISO 8601 format)
2. Automatically including JavaScript code on first use of `auto_update: true`
3. Running a JavaScript timer that recalculates the time difference every 60 seconds
4. Updating the text content of elements client-side

This means:
- No additional server requests are made
- The display stays accurate without page reloads
- Works with Turbolinks/Turbo for SPA-like experiences
- **No JavaScript imports, asset pipeline configuration, or layout modifications needed** - everything is automatic!

## Browser Support

The JavaScript functionality requires:
- Modern browsers with ES6+ support
- Native `Date` object support
- `setInterval` support

Compatible with:
- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)
- Mobile browsers (iOS Safari, Chrome Mobile)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dhq_boiler/rails-diff-time.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).