Pod::Spec.new do |s|
  s.name                    = "SKServer"
  s.version                 = "4.1.0"
  s.summary                 = "A Swift server library for creating Slack apps"
  s.homepage                = "https://github.com/pvzig/SKServer"
  s.license                 = 'MIT'
  s.author                  = { "Peter Zignego" => "peter@launchsoft.co" }
  s.source                  = { :git => "https://github.com/pvzig/SKServer.git", :tag => s.version.to_s }
  s.social_media_url        = 'https://twitter.com/pvzig'
  s.swift_version           = '4.0'
  s.ios.deployment_target   = '9.0'
  s.osx.deployment_target   = '10.11'
  s.tvos.deployment_target  = '9.0'
  s.requires_arc            = true
  s.source_files            = 'Sources/**/*.swift'
  s.frameworks              = 'Foundation'
  s.dependency                'SKCore'
  s.dependency                'SKWebAPI'
  s.dependency                'Swifter'
end
