module ApplicationHelper
  def primary_link_to text, link_path, link_options = {}, alternate_paths = []
    active = link_path == request.fullpath
    if !active
      alternate_paths.each do |path|
        active = path == request.fullpath unless active
      end
    end

    content = link_to(text, link_path, link_options)
    content = capture(content, &block) if block_given?
    content_tag(:h5, content, :class => "primary-link #{active ? 'active': ''}" )
  end

  def spinner
    content_tag( :img, '', :src => "/assets/spinner.gif", :class => 'spinner')
  end
end
