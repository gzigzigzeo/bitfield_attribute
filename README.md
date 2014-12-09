# BitfieldAttribute

Bitfield value object for ActiveModel. No hidden definitions. No callbacks. Magicless.

## Installation

Add this line to your application's Gemfile:

    gem 'bitfield_attribute'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bitfield_attribute

## Usage

Add integer column to your model:

```ruby
class AddNotificationSettingsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :notification_settings, :integer, default: 0
  end
end
```

Define bitfield class:

```ruby
class User::NotificationSettings
  include BitfieldAttribute::Base

  define_bits :weekly_digest, :announces, :events
end
```

Define accessor in the model:

```ruby
class User < ActiveRecord::Base
  def notification_settings
    @notification_settings ||= User::NotificationSettings.new(self, :notification_settings)
  end

  def notification_settings=(value)
    notification_settings.attributes = value
  end
end
```

Use it:

```ruby
user = User.new(notification_settings: {weekly_digest: true})
user.notification_settings.announces = true

user.notification_settings.weekly_digest?   # => true
user.notification_settings.to_a             # => [:weekly_digest, :announces]
user.notification_settings.attributes       # => { weekly_digest: true, announces: true, events: false }
user[:notification_settings]                # => 3
```

## Forms

```slim
= form_for @user do |form|
  = form.fields_for :notification_settings, form.object.notification_settings do |f|
    = f.check_box :weekly_digest
    = f.label :weekly_digest

  ...

  = form.submit 'Save'
```

## I18n

```ruby
en:
  activemodel:
    user/notification_settings:
      weekly_digest: 'Weekly top sellers digest'
      announces: 'Announces'
      events: 'Invitations'
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/bitfield_attribute/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
