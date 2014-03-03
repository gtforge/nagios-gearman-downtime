Gem::Specification.new do |s|
  s.name        = "nagios-gearman-downtime"
  s.version     = '0.1.0'
  s.authors     = ["Ami Mahloof"]
  s.email       = "ami.mahloof@gmail.com"
  s.homepage    = "https://github.com/gtforge/nagios-gearman-downtime"
  s.summary     = "Send external commands to mod-gearman"
  s.description = "Gearman Client & Worker for sending downtime and enable / disable notifications for service groups"
  s.add_dependency 'gearman-ruby'
  s.add_dependency 'thor'
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  # s.extra_rdoc_files = ['README.md', 'LICENSE']
  s.license = 'MIT'
end
