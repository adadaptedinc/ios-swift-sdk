Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.name         = "AASwiftSDK"
  spec.version      = "1.3.8"
  spec.summary      = "Official AdAdapted iOS Swift Interop SDK"
  spec.description  = <<-DESC
  This SDK allows you to utilize AdAdapted's service platform for displaying ads, keyword intercepts, tracking events, and more.
                   DESC
  spec.homepage     = "https://github.com/adadaptedinc/ios-swift-sdk"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.author             = { "Brett Clifton" => "bclifton@adadapted.com", "Matthew Kruk" => "mkruk@adadapted.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.platform     = :ios
  spec.ios.deployment_target = "12.0"
  spec.swift_version = "5.2"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.source       = { :git => "https://github.com/adadaptedinc/ios-swift-sdk.git", :tag => "#{spec.version}" }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.source_files  = "Classes", "AASwiftSDK/**/*.{h,m,swift}"

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
end
