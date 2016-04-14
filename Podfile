
def import_pods
  pod 'STTwitter'
  pod 'Fabric'
  pod 'Crashlytics'
end

target :TweetRain do
  platform :osx, "10.10"
  import_pods
end

target "TweetRain-ios" do
  platform :ios, "8.0"
  import_pods
  pod "SDWebImage"
  pod "SVProgressHUD"
  pod "Color-Picker-for-iOS", "~> 2.0"
  pod 'UIImage+BlurredFrame'
  pod 'Mixpanel'
end
