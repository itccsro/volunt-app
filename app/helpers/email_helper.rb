module EmailHelper
  def attached_image_url(image)
    attachments[image] = File.read(
      Rails.root.join('app', 'assets', 'images', image))
    attachments[image].url
  end

  def attached_image_tag(image, **options)
    image_tag  attached_image_url(image), **options
  end

  def attached_chart_tag(name, chart, **options)
    attachment = attach_chart(name, chart)
    image_tag attachment.url, **options
  end

  def sanitize_email_body(html)
    # TODO customize sanitizer ('sanitize' is too aggresive)
    html
  end

  def merge_template(template, profile)
    body = sanitize_email_body(template.body)
    tokens = /\%[\w\.]+\%/
    replacements = {
      "%NICKNAME%"  => profile.nick_name,
      "%FULLNAME%"  => profile.full_name,
      "%EMAIL%"     => profile.email,
      }
    body.gsub(tokens, replacements)
  end
end
