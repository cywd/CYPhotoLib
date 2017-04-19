
Pod::Spec.new do |s|

  s.name         = "CYPhotoLib"
  s.version      = "0.0.4"
  s.summary      = "A photo selection framework used Photos."
  s.homepage     = "https://github.com/CoderCYLee/CYPhotoLib"
  s.license      = "MIT"
  s.author       = { "Cyrill" => "lichunyang@outlook.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/CoderCYLee/CYPhotoLib.git", :tag => "#{s.version}" }

  s.source_files  = "CYPhotoLib/Classes/**/*"
  s.resources = "CYPhotoLib/Resource/*.png"

  # s.frameworks = "SomeFramework", "AnotherFramework"
  s.requires_arc = true

end
