# Toycol

Toycol is a small framework for defining toy application protocols.

You can define your own application protocol only by writing a parser in Toycol DSL for request messages.

Since the server and client programs to run the protocol are built-in from the beginning, you only need to prepare the following two items to run your custom protocol.
- A configuration file named like `Protocolfile`, `Protocolfile.protocol_name` and so on
- A Rack compartible application(e.g. `config.ru`)

In the real world, there is (yet) no full-fledged web server or browser in the world that runs on the custom protocol you devised.
Therefore, the protocol defined by this framework is in fact a "toy".
However, by using this framework, you will be able to experience and learn how the connection between the application layer and the transport layer is, and how the application protocol works on the transport layer.

## Example(on original "Duck" protocol)

In this protocol:
  - Client would send message like: `"quack, quack /posts<3user_id=1"`
  - Server would interpret client message: `"GET /posts?user_id=1"`

You write your definition in Protocolfile

```ruby
# Protocolfile.duck (protocol file)

Protocol.define(:duck) do
  # [OPTIONAL] You can add your original request methods
  add_request_methods "OTHER"

  # [OPTIONAL] You can define your custom status codes
  custom_status_codes(
    600 => "I'm afraid you are not a duck..."
  )

  # [REQUIRED] Define how you parse request path from request message
  request.path do |message|
    %r{(?<path>\/\w*)}.match(message)[:path]
  end

  # [REQUIRED] Define how you parse query from request message
  request.query do |message|
    %r{\<3(?<query>.+)}.match(message) { |m| m[:query] }
  end

  # [REQUIRED] Define how you parse query from request message
  request.http_method do |message|
    case message.scan(/quack/).size
    when 2 then "GET"
    else "OTHER"
    end
  end
end
```

Don't forget, you need to prepare your application as well.

```ruby
# config_duck.ru (Rack compartible application)

require "rack"
require "toycol"

# Specify which protocol to use
Toycol::Protocol.use(:duck)

class App
  def call(env)
    case env["REQUEST_METHOD"]
    when "GET"
      [
        200,
        { "Content-Type" => "text/html" },
        ["Quack, Quack! This app is running by Duck protocol."]
      ]
    when "OTHER"
      [
        600,
        { "Content-Type" => "text/html" },
        ["Sorry, this application is only for ducks...\n"]
      ]
    end
  end
end

run App.new
```

Then you run server & client

```
# In terminal for server

$ toycol server config_duck.ru
Toycol starts build-in server, listening on unix:///tmp/toycol.socket
Toycol is running on localhost:9292
=> Use Ctrl-C to stop
```

```
# In other terminal for client

$ toycol client "quack, quack /posts<3user_id=1"
[Toycol] Sent request message: quack, quack /posts<3user_id=1
---
[Toycol] Received response message:

HTTP/1.1 200 OK
Content-Type: text/html
Content-Length: 32

Quack, Quack! This app is running by Duck protocol.
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "toycol"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install toycol

## Usage

Toycol provides useful commands to define & run your protocol.

#### `toycol generate` - To define your new protocol

You can use `toycol generate` command to generate skeletons of Protocolfile and application.

```
$ toycol generate PROTOCOL_NAME
```

When you run this command, skeletons of `Protocolfile.PROTOCOL_NAME` and `config_PROTOCOL_NAME.ru` will be generated.
If you only need one of them, you can specify the type by `-t` option.

```
$ toycol generate PROTOCOL_NAME -t protocol
# or
$ toycol generate PROTOCOL_NAME -t app
```

If `PROTOCOL_NAME` is not specified, Protocolfile and config.ru will simply be generated.

```
$ toycol generate
```

#### `toycol server` - To run server by your protocol

After you prepare Protocolfile & application, you need to start server to run the application by `toycol server` command.

```
# Please specify application file name
$ toycol server config_`PROTOCOL_NAME`.ru
```

Then the server will start.

Normally, `toycol server` command will start the server built into toycol.
However, if Puma is already installed in your environment, it will start Puma by default.

If you want to explicitly specify which server to use, you can use the -u option.

```
$ toycol server config_`PROTOCOL_NAME`.ru -u puma
# or
$ toycol server config_`PROTOCOL_NAME`.ru -u buid_in
```

If you would like to check other options, run the command `toycol server -h`.

#### `toycol client` - To send request message by your protocol

When you would like to send the request message to the server, use `toycol client`.

```
$ toycol client "YOUR REQUEST MESSAGE"
```

If you would like to check other options, run the command `toycol client -h`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shioimm/toycol. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/shioimm/toycol/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Toycol project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/shioimm/toycol/blob/main/CODE_OF_CONDUCT.md).
