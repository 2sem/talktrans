# Uncomment this line to define a global platform for your project
 platform :ios, '10.0'

target 'talktrans' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  #inhibit_all_warnings!

  # Pods for talktrans
#  pod 'Firebase/Core'
#  pod 'Firebase/AdMob'
  
  # Add the pod for Firebase Crashlytics
  pod 'Firebase/Crashlytics'

  # Recommended: Add the Firebase pod for Google Analytics
  pod 'Firebase/Analytics'
  
  pod 'KakaoOpenSDK'
  pod 'LSExtensions'#, :path => '~/Projects/leesam/pods/LSExtensions/src/LSExtensions'
  pod 'GADManager'#, :path => '~/Projects/leesam/pods/GADManager/src/GADManager'
  pod 'NaverPapago'#, :path => '~/Projects/leesam/pods/NaverPapago/src/NaverPapago'
  pod 'Material', '~> 2.16.4'
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  pod 'Alamofire', '4.7.3'
  #, :xcconfig => { 'APPLICATION_EXTENSION_API_ONLY' => 'FALSE' }

#  target 'action' do
#    pod 'Material', '~> 2.16.4'
#    pod 'LSExtensions', :path => '~/Projects/leesam/pods/LSExtensions/src/LSExtensions'
#    pod 'NaverPapago', :path => '~/Projects/leesam/pods/NaverPapago/src/NaverPapago'
#  end
  target 'talktransTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'talktransUITests' do
    inherit! :search_paths
    # Pods for testing
  end

    #script to do after install pod projects
    post_install do |installer|
      installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
#          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
        end
      end
#        #find target name of "Material" from targets in Pods
#        Material = installer.pods_project.targets.find{ |t| t.name == "Material" }
#        #puts "capture #{Material}";
#        #find target name of "LSExtensions" from targets in Pods
#        LSExtensions = installer.pods_project.targets.find{ |t| t.name == "LSExtensions" }
#        #find target name of "GADManager" from targets in Pods
#        GADManager = installer.pods_project.targets.find{ |t| t.name == "GADManager" }
#        #puts "capture #{LSExtensions}";
#        NaverPapago = installer.pods_project.targets.find{ |t| t.name == "NaverPapago" }
#        Motion = installer.pods_project.targets.find{ |t| t.name == "Motion" }
#        #puts "capture #{LSExtensions}";
#
#        Material.build_configurations.each do |config|
#            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
#            puts "off APPLICATION_EXTENSION_API_ONLY of #{Material}";
#        end
#
#        LSExtensions.build_configurations.each do |config|
#            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
#            puts "off APPLICATION_EXTENSION_API_ONLY of #{LSExtensions}";
#        end
#
#        NaverPapago.build_configurations.each do |config|
#            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
#            puts "off APPLICATION_EXTENSION_API_ONLY of #{NaverPapago}";
#        end
#
#        Motion.build_configurations.each do |config|
#            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
#            puts "off APPLICATION_EXTENSION_API_ONLY of #{Motion}";
#        end
#
#        GADManager.build_configurations.each do |config|
#            config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
#            puts "off APPLICATION_EXTENSION_API_ONLY of #{GADManager}";
#        end
    end
end
