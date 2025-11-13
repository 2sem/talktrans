# Uncomment this line to define a global platform for your project
 platform :ios, '18.0'

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
  
  pod 'KakaoSDKShare'
  #pod 'LSExtensions'#, :path => '~/Projects/leesam/pods/LSExtensions/src/LSExtensions'
  pod 'GADManager'#, :path => '~/Projects/leesam/pods/GADManager/src/GADManager'
  pod 'Material', '~> 2.16.4'
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
#  pod 'Alamofire', '~> 5.1'
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
          config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''
          config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
          config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
          
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
        
        if target.name == 'FirebaseCrashlytics'
          target.build_configurations.each do |config|
            puts "Found FirebaseCrashlytics Target"
            if config.name == 'Debug'
              puts "Add -Wl,-ld_classic into Other Linker Flags of Debug Configuration for FirebaseCrashlytics"
              config.build_settings['OTHER_LDFLAGS'] = "$(inherited) -Wl,-ld_classic"
              #"#{config.build_settings['OTHER_LDFLAGS']} -Wl,-ld_classic"
            end
          end
          
#          xcconfig_path = config.base_configuration_reference.real_path
#          xcconfig = File.read(xcconfig_path)
#          new_xcconfig = xcconfig.sub('OTHER_LDFLAGS = $(inherited) -Wl,-ld_classic', 'OTHER_LDFLAGS = $(inherited)')
#          File.open(xcconfig_path, "w") { |file| file << new_xcconfig }
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
