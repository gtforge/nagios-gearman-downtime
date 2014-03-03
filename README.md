# Nagios Gearman Downtime

Gearman Client & Worker for sending downtime and enable / disable notifications for service groups

## Installation

Add this line to your application's Gemfile:

    gem 'nagios-gearman-downtime', 

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nagios-gearman-downtime

## Usage:
  downtime_client set --duration=duration in minutes --gearman-server=Gearman server address

## Available options are:

  --object_type [host, 
                 hostgroup_host, 
                 hostgroup_svc, 
                 servicegroup_host, 
                 servicegroup_svc,
                 service,
                 enable_servicegroup,
                 disable_servicegroup], default => host

  --object_name  default => 'hostname -f', the name of the object type


  --encryption true/false - default => false
  --key Key to encrypt request - must be identical to the gearman_server key
  --queue gearman server queue default => downtime


  --start_time  default => now
  --end_time    default => now + duration
  --duration    time in minutes, default => 1 minute

  --author    Author of downtime (default hostname) 
  --comment   default => 'Downtime recieved by gearman server'

Send Downtime request to Gearman server - downtime queue

 
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
