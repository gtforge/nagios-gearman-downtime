# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require 'nagios-gearman-downtime/version'

Gem::Specification.new do |s|
  s.name        = "nagios-gearman-downtime"
  s.authors     = ["Ami Mahloof"]
  s.email       = "ami.mahloof@gmail.com"
  s.homepage    = "https://github.com/gtforge/nagios-gearman-downtime"
  s.summary     = "Send external commands to mod-gearman"
  s.description = "Gearman Client & Worker for sending downtime and enable / disable notifications for service groups"
  s.add_dependency 'gearman-ruby'
  s.add_dependency 'thor'
  s.add_dependency 'bluepill'
  s.files            = `git ls-files`.split("\n")
  s.require_paths    = ["lib"]
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.license = 'MIT'
  s.version     = ::Nagios::Gearman::Downtime::VERSION
end
