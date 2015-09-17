Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "Prephirences"
  s.version      = "2.0.0"
  s.summary      = "A Swift library to manage preferences"
  s.description  = <<-DESC
                   Prephirences is a Swift library that provides useful protocols and methods to manage preferences.
                   Preferences could be user preferences (NSUserDefaults) or your own private application preferences
                   DESC
  s.homepage     = "https://github.com/phimage/Prephirences"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = "MIT"

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "phimage" => "eric.marchand.n7@gmail.com" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/phimage/Prephirences.git", :tag => s.version }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.default_subspec = 'Core'

  s.subspec "Core" do  |sp|
    sp.source_files = "Prephirences/*.swift"
  end

  s.subspec "CoreData" do  |sp|
    sp.source_files = ['Prephirences/CoreData/*.swift']
    sp.dependency 'Prephirences/Core'
  end

  s.subspec "UserDefaults" do  |sp|
    sp.source_files = ['Prephirences/UserDefaults/*.swift']
    sp.dependency 'Prephirences/Core'
  end

  s.subspec "All" do  |sp|
    sp.dependency 'Prephirences/CoreData'
    sp.dependency 'Prephirences/UserDefaults'
  end

  s.subspec "Cocoa" do  |sp|
    sp.platform = :osx, '10.10'
    sp.osx.source_files = ['PrephirencesMacOSX/*.swift']
  end

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.resource  = "logo-128x128.png"

end
