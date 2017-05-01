
Pod::Spec.new do |s|

  s.name         = "CYPhotoLib"
  s.version      = "0.1.0"
  s.summary      = "A photo selection framework used Photos."
  s.homepage     = "https://github.com/CoderCYLee/CYPhotoLib"
  s.license      = "MIT"
  s.author       = { "Cyrill" => "lichunyang@outlook.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/CoderCYLee/CYPhotoLib.git", :tag => "#{s.version}" }

  s.source_files  = "CYPhotoLib/Classes/**/*.{h,m}"
  s.resources = "CYPhotoLib/Resource/*.png", "CYPhotoLib/Classes/CYPhotoPicker/View/*.xib"

  # s.frameworks = "SomeFramework", "AnotherFramework"
  s.requires_arc = true

end
