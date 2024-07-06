Pod::Spec.new do |s|
  s.name             = 'locale_manager'
  s.version          = '0.0.1'
  s.summary          = 'Flutter Plugin to manage locale'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://github.com/josecleiton'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'José Cleiton Correia' => 'jcleitonbc@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
