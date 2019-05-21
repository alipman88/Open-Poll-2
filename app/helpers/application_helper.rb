module ApplicationHelper
  def embed_videos text
    text.to_s
      .gsub(/https?\:\/\/(www\.)?youtube\.com\/watch\?v=([a-zA-Z0-9\-\_]+)/, '<span class="clear"></span><span class="videoWrapper"><iframe width="560" height="315" style="max-width: 100%;" src="https://www.youtube.com/embed/\2" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe></span>')
      .gsub(/https?\:\/\/(www\.)?youtu\.be\/([a-zA-Z0-9\-\_]+)/, '<span class="clear"></span><span class="videoWrapper"><iframe width="560" height="315" style="max-width: 100%;" src="https://www.youtube.com/embed/\2" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe></span>')
      .html_safe
  end
end
