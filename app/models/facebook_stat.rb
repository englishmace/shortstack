class FacebookStat < ActiveRecord::Base
  belongs_to :link

  # Gets the graph from graph.facebook.com for a link
  #
  # @return {Hash} or nil if error
  # @example Get the Facebook Statistics for a Facebook Page link
  #   Link.facebook_stats.new.get_graph
  def get_graph(link_url=link.link_url)
    url = alter_url(link_url)
    if !url.nil?  
      body = JSON.parse(open(url).read) 
    end
    if body["error"].nil? 
      body 
    else
      link.update_attributes(:flag => link.flag + 1)
      nil
    end
  end
  
  
  # Save graph data from graph.facebook.com for a link
  #
  # @return FacebookStat
  # @example Get the Facebook Statistics for a Facebook Page link
  #   Link.facebook_stats.new.save_facebook_data
  def save_facebook_data
    data = get_graph
    if !data.nil?
      facebook_id = data["id"]
      name = data["name"]
      category = data["category"]
      likes = data["likes"]
      self.save
    end
  end  
  
  
  # Changes facebook url to the social graph url
  #
  # @return string
  # @example 
  #   alter_url('http://www.facebook.com/SF') returns 'http://graph.facebook.com/SF'
  
  def alter_url(url)
    facebook_link = Domainatrix.parse(url)
    if !facebook_link.nil? and facebook_link.path != "" and facebook_link.path.size != 1
      "http://graph.facebook.com#{facebook_link.path}"
    else 
      nil
    end   
  end
  
end