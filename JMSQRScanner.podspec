Pod::Spec.new do |s|
	s.name     = 'JMSQRScanner'
	s.version  = '0.0.1'
	s.license  = 'MIT'
	s.summary  = 'QR Scanner for iOS'
	s.homepage = 'https://github.com/buscarini/JMSQRScanner'
	s.authors  = { 'José Manuel Sánchez' => 'buscarini@gmail.com' }
	s.source   = { :git => 'https://github.com/buscarini/JMSQRScanner.git', :tag => "0.0.1", :submodules => true }

	s.ios.deployment_target = '6.0'
	s.osx.deployment_target = '10.8'
	s.requires_arc = true	

  s.dependency 'ZBarSDK', '~> 1.3.1'
  s.library = 'iconv'
  
  s.source_files = 'JMSQRScanner/**/*.{h,m}'  
  
end