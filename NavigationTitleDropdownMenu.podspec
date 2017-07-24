#
#  Be sure to run `pod spec lint EmotionKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

s.platform = :ios
s.ios.deployment_target = '8.0'
s.name = "NavigationTitleDropdownMenu"
s.summary = "NavigationTitleDropdownMenu just menu"
s.requires_arc = true

s.version = '0.0.6'
s.license = { :type => "MIT", :file => "LICENSE" }
s.author = { "Alex Moiseenko" => "alexmoiseenko@me.com" }
s.homepage = "https://github.com/alexmay23/NavigationTitleDropdownMenu"

s.source = { :git => "https://github.com/alexmay23/NavigationTitleDropdownMenu.git", :tag => "#{s.version}"}
s.framework = "UIKit"

s.source_files = "Sources/**/*.{swift}"

s.resource_bundles = {
'UI' => [
'Sources/**/*.xcassets',
]
}

end
