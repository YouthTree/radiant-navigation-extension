module Navigation
  module Tags
    class Helpers
      class << self

        def not_allowed?(tag,child_page)
          (tag.attr['only'] and !child_page.url.match(tag.attr['only'])) or
          (tag.attr['except'] and child_page.url.match(tag.attr['except'])) or
          child_page.part("no-map") or child_page.virtual? or !child_page.published? or child_page.class_name.eql? "FileNotFoundPage"    
        end
        
        def sub_nav(tag, child_page, depth, first_set = false)
          current_page = tag.locals.page
          
          css_class = []
          css_class << 'first' unless first_set
          css_class << "current" if current_page == child_page
          css_class << "has_children" if child_page.children.present?
          css_class << "parent_of_current" if current_page.url.starts_with?(child_page.url) and current_page != child_page
          css_class.compact!
          
          r =  %{<li#{" class='#{css_class.join(' ')}'" unless css_class.empty?}#{" id='nav_#{child_page.slug}'" if tag.attr['ids_for_lis']}>}
          r << %{<a href="#{child_page.url}"#{" id='link_#{(child_page.slug == '/' ? 'home' : child_page.slug)}'" if tag.attr['ids_for_links']}>}
          r << %{#{child_page.breadcrumb}}
          r << %{</a>}
          
          allowed_children = child_page.children.delete_if{ |c| not_allowed?(tag,c) }
          
          if tag.attr['expand_all'] or current_page.url.starts_with?(child_page.url)
            if allowed_children.present? and depth.present? and child_page.class_name != 'ArchivePage'
              r << %{<ul>}
              child_page.children.each do |child|
                depth -= 1
                r << sub_nav(tag,child,depth,first_set)
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