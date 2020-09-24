# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'NumRecoDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for NumRecoDemo

pod 'SwiftOCR'

end

# Swift 版本声明
post_install do |installer|
    installer.pods_project.targets.each do |target|
        if ['对应三方1', '对应三方2'].include? target.name
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.3'
                config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
            end
            else
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.1'
                config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
            end
        end
    end
end

