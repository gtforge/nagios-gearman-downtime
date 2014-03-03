# Nagios Gearman Downtime

Gearman Client & Worker for sending downtime and enable / disable notifications for service groups

## Installation

Add this line to your application's Gemfile:

    gem 'bluepill-gearman', 

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bluepill-gearman

## Usage

Require the bluepill-gearman gem and add a check named :send_gearman in your pill configuration file.

Available options are:
  * gearman_server: the Gearman Server. mandatory
  * gearman_port: the gearman server port or default to 4730
  * host: the host defined in nagios to be hosting the service (default: hostname -f)
  * service: the service declared in nagios (default: the bluepill process name)
  * queue: default queue is 'check_results'
  * key: provide a key for encryption (minimum 8 bytes)
  * encryption: default to false, set to true to enable - must provide a key
  * every: how often the send_gearman will send the passive check (default to 1.minute)

add :notify_on => :unmonitored to make bluepill send notification when unmonitored

Example:

```
require 'bluepill-gearman'
Bluepill.application("test") do |app|
  app.process("test") do |process|
    process.start_command = "bundle exec ./test.rb"
    process.pid_file = "/var/run/test.pid"
    process.daemonize = true
    process.checks :send_gearman, :gearman_server => 'my.gearman.server', :host => 'host_in_nagios', :service => 'passive check service name', :notify_on => :unmonitored, :every => 1.minute
  end
end
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
