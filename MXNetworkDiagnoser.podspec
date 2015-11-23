Pod::Spec.new do |s|
  s.name         = "MXNetworkDiagnoser"
  s.version      = "0.0.1"
  s.license      = 'MIT'
  s.summary      = "Dianose network"
  s.homepage     = "https://github.com/muyexi/MXNetworkDiagnoser.git"

  s.author       = { "muyexi" => "muyexi@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/muyexi/MXNetworkDiagnoser.git", :tag => "0.0.1" }
  s.source_files = "Classes", "Classes/**/*.{h,m}"
  s.requires_arc = true
  s.ios.library = 'resolv'

  s.dependency 'IVYTraceroute', '~> 1.0'
  s.dependency "GBPing", "~> 1.3"
  s.dependency 'SDVersion', '~> 2.5'
  s.dependency 'Reachability', '~> 3.2'
end
