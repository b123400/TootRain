
def import_pods
  pod 'MatomoTracker', :git => 'https://github.com/b123400/matomo-sdk-ios.git', :branch => 'new-session-objc'
end

target :TootRain do
  platform :osx, "10.15"
  import_pods
end

target "TweetRain-ios" do
  platform :ios, "8.0"
  # import_pods
  pod "SDWebImage"
  pod "SVProgressHUD"
  pod "Color-Picker-for-iOS", "~> 2.0"
  pod 'UIImage+BlurredFrame'
end
