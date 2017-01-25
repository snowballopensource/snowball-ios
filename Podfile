platform :ios, '8.0'
use_frameworks!

target 'Snowball' do
  pod 'Alamofire', '3.5.1'
  pod 'Amplitude-iOS'
  pod 'Cartography', '0.7'
  pod 'HanekeSwift', git: 'https://github.com/Haneke/HanekeSwift', commit: '2f304e8'
  pod 'RealmSwift', '1.1.0'
  pod 'SwiftFetchedResultsController', '4.0.4'
  pod 'RBQFetchedResultsController', '4.0.4'
  pod 'SwiftSpinner', '0.9.5'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '2.3'
    end
  end
end
