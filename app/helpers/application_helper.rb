module ApplicationHelper

  def glyphicon_submit_helper(glyph)
    button_tag(type: 'submit', class: 'btn btn-primary') do
      content_tag(:span, "",  class: "glyphicon glyphicon-#{glyph}")
    end
  end

  def glyphicon_link(link)
    link_to link, class: 'btn btn-link link-to' do
      content_tag(:span, "",  class: "glyphicon glyphicon-play-circle")
    end
  end

  def ensure_http_scheme(url)
    uri = URI.parse(url)
    if (!uri.scheme)
      url = 'http://' + url
    end
    return url
  end

end
