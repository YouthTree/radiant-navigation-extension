module Navigation
  module Tags
    class Helpers
      class << self

        def not_allowed?(tag, child_page, options)
          (options[:only] and !child_page.url.match(options[:only])) or
          (options[:except] and child_page.url.match(options[:except])) or
          child_page.part("no-map") or child_page.virtual? or !child_page.published? or child_page.class_name.eql? "FileNotFoundPage"    
        end
        
        def allowed?(tag, child_page, options)
          !not_allowed?(tag, child_page, options)
        end

        def sub_nav(tag, child_page, depth, options, first_set = false)
          current_page = tag.locals.page
          
          css_class = []
          css_class << 'first' unless first_set
          css_class << "current" if current_page == child_page
          css_class << "has_children" if child_page.children.present?
          css_class << "parent_of_current" if current_page.url.starts_with?(child_page.url) and current_page != child_page
          css_class << "depth-#{depth}"
          css_class.compact!
          
          r =  %{<li#{" class='#{css_class.join(' ')}'" unless css_class.empty?}#{" id='nav_#{child_page.slug}'" if options[:ids_for_lis]}>}
          r << %{<a href="#{child_page.url}"#{" id='link_#{(child_page.slug == '/' ? 'home' : child_page.slug)}'" if options[:ids_for_links]}>}
          r << %{#{child_page.breadcrumb}}
          r << %{</a>}
          
          if options[:expand_all] || current_page.url.starts_with?(child_page.url)
            allowed_children = child_page.children.select { |c| allowed? tag, c, options }
            if allowed_children.present? && depth.to_i > 0 && child_page.class_name != 'ArchivePage'
              r << %{<ul>}
              allowed_children.each_with_index do |child, index|
                r << sub_nav(tag, child, depth - 1, options, index > 0)
              end
              r << %{</ul>}
            end
          end
          
          r << %{</li>}
        end
        
      end
    end
  end
end