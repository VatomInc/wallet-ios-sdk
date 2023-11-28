
Pod::Spec.new do |spec|


  spec.name         = "vatom-wallet-sdk"
  spec.version      = "0.0.4"
  spec.summary      = "Vatom Wallet SDK for ios."
  spec.description  = <<-DESC
                      Vatom Wallet SDK for ios.
                   DESC

  spec.homepage     = "https://vatom.com"
  spec.license      = "MIT"
  spec.author             = { "Luis Palacios" => "luis.palacios@vatom.com" }
  spec.platform     = :ios, "13.0"
  spec.source       = { :git => "https://github.com/VatomInc/wallet-ios-sdk.git", :tag => "#{spec.version}" }
  spec.readme       = "https://raw.githubusercontent.com/VatomInc/wallet-ios-sdk/#{spec.version}/README.md"

  spec.source_files  = "Classes", "Sources/VatomWallet/**/*.{swift}"
  spec.exclude_files = "Classes/Exclude"
end
