Gem::Specification.new do |spec|

  spec.name = 'hub-deployer'
  spec.version = '0.0.1.dev'
  spec.platform = Gem::Platform::RUBY
  spec.description = <<-DESC
    hubops
  DESC
  spec.summary = <<-DESC.strip.gsub(/\n\s+/, " ")
    hubops
  DESC

  spec.files = Dir.glob("{lib}/**/*")
  spec.require_path = 'lib'
  spec.has_rdoc = false


  spec.add_dependency 'capistrano', ">= 2.11.0"
  spec.add_dependency 'capifony', ">= 2.1.13"

  spec.authors = [ "Amy Badore" ]
  spec.email = [ "amy.badore@cbsinteractive.com" ]
#  spec.homepage = "http://capifony.org"
#  spec.rubyforge_project = "capifony"

end
