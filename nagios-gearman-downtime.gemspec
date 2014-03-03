Gem::Specification.new do |s|
  s.name        = "nagios-gearman-downtime"
  s.version     = '0.1.0'
  s.authors     = ["Ami Mahloof"]
  s.email       = "ami.mahloof@gmail.com"
  s.homepage    = "TODO HOMEPAGE"
  s.summary     = "Send external commands to mod-gearman"
  s.description = "TODO DESCRIPTION"
  s.required_rubygems_version = ">= 1.3.6"
  s.files = ["lib/nagios-gearman-external-cmd.rb"]
  s.add_dependency 'ruby-gearman'
  s.add_dependency 'thor'
  
  # s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.license = 'MIT'
end
