
Pod::Spec.new do |s|

  s.name         = "JWQRCode"
  s.version      = "0.0.1"
  s.summary      = "二维码、条形码扫描"

  #主页
  s.homepage     = "https://github.com/junwangInChina/JWQRCode"
  #证书申明
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  #作者
  s.author       = { "wangjun" => "github_work@163.com" }
  #支持版本
  s.platform     = :ios, "9.0"
  #项目地址，版本
  s.source       = { :git => "https://github.com/junwangInChina/JWQRCode.git", :tag => s.version }

  #库文件路径
  s.source_files  = "JWQRCode/JWQRCode/JWQRCode/**/*.{h,m}"
  #资源文件
  s.resource      = "JWQRCode/JWQRCode/JWQRCode/JWQRCode.bundle"
  #是否ARC
  s.requires_arc = true

end