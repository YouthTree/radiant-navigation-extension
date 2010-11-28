# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class NavigationExtension < Radiant::Extension
  version YAML::load_file(File.join(File.dirname(__FILE__), 'VERSION'))
  description "Makes building navigations much easier."
  url "http://github.com/dirkkelly/radiant-navigation-extension"
  
  def activate
    Page.send :include, Navigation::Tags::Core
  end
  
end