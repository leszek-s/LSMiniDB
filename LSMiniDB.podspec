Pod::Spec.new do |s|
  s.name          = "LSMiniDB"
  s.version       = "1.0"
  s.summary       = "Simple and minimalistic database"
  s.homepage      = "https://github.com/leszek-s/LSMiniDB"
  s.license       = "MIT"
  s.author        = "Leszek S"
  s.source        = { :git => "https://github.com/leszek-s/LSMiniDB.git", :tag =>  "1.0" }
  s.ios.deployment_target = "7.0"
  s.tvos.deployment_target = "9.0"
  s.source_files  = "LSMiniDB"
  s.requires_arc  = true
end