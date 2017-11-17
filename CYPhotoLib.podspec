
Pod::Spec.new do |s|

  s.name         = "CYPhotoLib"
  s.version      = "1.3.1"
  s.summary      = "A photo selection framework used Photos."
  s.homepage     = "https://github.com/cywd/CYPhotoLib"
  s.license      = "MIT"
  s.author       = { "Cyrill" => "lichunyang@outlook.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/cywd/CYPhotoLib.git", :tag => "#{s.version}" }

  s.source_files  = "CYPhotoLib/Classes/**/*.{h,m}"
  s.resources = "CYPhotoLib/Resource/*.png", "CYPhotoLib/Classes/CYPhotoPicker/View/*.xib"

  # s.frameworks = "SomeFramework", "AnotherFramework"
  s.requires_arc = true

end
