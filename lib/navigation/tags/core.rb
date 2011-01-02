module Navigation
  module Tags
    module Core
      include Radiant::Taggable
      include ActionView::Helpers::TagHelper

      class NavTagError < StandardError; end
          
      desc %{
        Render a navigation menu. Walks down the directory tree, expanding the tree up to the current page.

        *Usage:*
        <pre><code><r:nav [id="subnav"] [root="/products"] [include_root="true"] [depth="2"] [expand_all="true"]
        [only="^/(articles|notices)"] [except="\.(css|js|xml)/*$"] /></code></pre> 
        *Attributes:*

        * @root@ defaults to "root page", where to start building the navigation from, you can i.e. use "sexy-dresses" to build a nav under sexy dresses
        * @include_root@ defaults to false, set to true to include the root page (i.e. Home)
        * @ids_for_lis@ defaults to false, enable this to give each li an id (it's slug prefixed with nav_)
        * @ids_for_links@ defaults to false, enable this to give each link an id (it's slug prefixed with nav_)

        * @depth@ defaults to 1, which means no sub-ul's, set to 2 or more for a nested list
        * @expand_all@ defaults to false, enable this to have all li's create sub-ul's of their children, i.o. only the currently active li
        * @order@ - How to order the first row, either asc or desc.

        * @only@ a string or regular expresssion. only pages whose urls match this are included
        * @except@ a string or regular expresssion. pages whose urls match this are not shown. except will override only. use to eliminate non-content file-types

        * @id@, @class@,..: go as html attributes of the outer ul
      }

      tag "nav" do |tag|
        root_url  = (tag.attr.delete('root') || "/").to_s
        root      = Page.find_by_url(root_url)
        depth     = (tag.attr.delete('depth') || 1).to_i
        ascending = (tag.attr.delete('order') || 'asc') == 'asc'
        tree      = ""
        
        raise NavTagError, "No page found at \"#{root_url}\" to build navigation from." if root.class_name.eql?('FileNotFoundPage')
        
        options = {
          :include_root  => (tag.attr.delete('include_root') == 'true'),
          :expand_all    => (tag.attr.delete('expand_all') == 'true'),
          :only          => tag.attr.delete('only'),
          :except        => tag.attr.delete('except'),
          :ids_for_lis   => (tag.attr.delete('ids_for_lis') == 'true'),
          :ids_for_links => (tag.attr.delete('ids_for_links') == 'true'),
        }

        first_set = false

        if options[:include_root]
          css_class = [("current" if tag.locals.page == root), "first"].compact
          first_set = true
          
          tree << %{<li#{" class='#{css_class.join(' ')}'" unless css_class.empty?}#{" id='#{(root.slug == '/' ? 'home' : root.slug)}'" if options[:ids_for_lis]}>}
          tree << %{<a href="#{root.url}"#{" id='link_#{(child_page.slug == '/' ? 'home' : root.slug)}'" if optionbs[:ids_for_links]}>}
          tree << %{#{root.breadcrumb}}
          tree << %{</a></li>}
        end
        
        children = root.children
        children = children.reverse unless ascending
        children.each do |child|
          next if Helpers.not_allowed? tag, child, options
          tree  << Helpers.sub_nav(tag, child, depth - 1, options, first_set)
          first_set = true
        end
        
        if tag.attr.present?
          html_options = tag.attr.stringify_keys
          tag_options = tag_options(html_options)
        else
          tag_options = nil
        end
        
        %{<ul#{tag_options}>
        #{tree}
        </ul>}
        
      end
      
      # Inspired by this thread: 
      # http://www.mail-archive.com/radiant@lists.radiantcms.org/msg03234.html
      # Author: Marty Haught
      desc %{
        Renders the contained element if the current item is an ancestor of the current page or if it is the page itself. 
      }
      tag "if_ancestor_or_self" do |tag|
        if tag.globals.actual_page.url.starts_with?(tag.locals.page.url)
          tag.expand
        end
      end

      desc %{
        Renders the contained element if the current item is also the current page. 
      }
      tag "if_self" do |tag|
        if tag.locals.page == tag.globals.page
          tag.expand
        end
      end

      desc %{    
        Renders the contained elements only if the current contextual page has children.

        *Usage:*
        <pre><code><r:if_children>...</r:if_children></code></pre>
      }
      tag "if_children" do |tag|
        if tag.locals.page.children.present?
          tag.expand 
        end
      end
      
      desc %{    
        Renders the contained elements unless the current contextual page has children.

        *Usage:*
        <pre><code><r:if_children>...</r:if_children></code></pre>
      }
      tag "unless_children" do |tag|
        unless tag.locals.page.children.blank?
          tag.expand
        end
      end
      
    end
  end
end