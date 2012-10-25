Gem::Specification.new do |spec|

  spec.name = 'hub-deployer'
  spec.version = '0.0.3'
  spec.platform = Gem::Platform::RUBY
  spec.description = <<-DESC
    hubops
  DESC
  spec.summary = <<-DESC.strip.gsub(/\n\s+/, " ")
    hubops
  DESC

  spec.bindir = "bin"
  spec.executables = ["hub-deploy", "cloud-deploy"]

  spec.files = Dir.glob("{lib,tasks}/**/*")
  spec.require_path = 'lib'
  spec.has_rdoc = false


  spec.add_dependency 'capistrano', ">= 2.11.0"
  spec.add_dependency 'hub-capifony', ">= 2.1.16"
  spec.add_dependency 'trollop', ">= 2.0"
  spec.add_dependency 'fog', ">= 1.6.0"

  spec.authors = [ "Amy Badore" ]
  spec.email = [ "amy.badore@cbsinteractive.com" ]

end
