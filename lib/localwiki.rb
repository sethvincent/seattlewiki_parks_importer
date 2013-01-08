require 'faraday'
require 'json'

class LocalWiki

  def initialize(site, user, apikey)
    @site = Faraday.new(:url => site)
    @user = user
    @apikey = apikey
  end
  
  
  def get_tag(name)
    tag_slug = name.strip.gsub(' ', "")
    
    get_resource("tag", tag_slug)
  end
  
  def post_tag(name)
    slug = slugify(name)
    body = { name: name }
    post_resource("tag", body)
  end

  def post_page_tags(page, tags)
    slug = slugify(page)
    
    body = { page: "/api/page/#{slug}", tags: [] }

    tags.each do |tag|
      tag_slug = tag.strip.gsub(' ', "")
      body[:tags].concat ["/api/tag/#{tag_slug}"]
      post_tag(tag) unless get_tag(tag).status == 200
    end

    post_resource("page_tags", body)
  end

  def post_map(page, lat, lon)
    slug = slugify(page)
    map = {
      geom: {
        geometries: [
          { coordinates: [ lat, lon ], type: "Point"}
        ],
        type: "GeometryCollection"
      },
      page: "/api/page/#{slug}"
    }
    
    post_resource("map", map)
  end
  
  
  
  def get_all_resources(filters={})
  end
  
  def get_resource(content_type, name)
    slug = slugify(name)

    @site.get do |req|
      req.url "api/#{content_type}/#{slug}"
      req.headers['Content-Type'] = 'application/json'
    end
  end

  def post_resource(content_type, attributes={})
    @site.post do |req|
      req.url "api/#{content_type}/"
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "ApiKey #{@user}:#{@apikey}"
      req.body = attributes.to_json
    end
  end
  
  def put_resource(content_type, name, attributes={})
    slug = slugify(name)

    @site.put do |req|
      req.url "api/#{content_type}/#{slug}"
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "ApiKey #{@user}:#{@apikey}"
      req.body = attributes.to_json
    end
  end
  
  def patch_resource(content_type, name, attributes={})
    @site.patch do |req|
      req.url "api/#{content_type}/#{name}"
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = "ApiKey #{@user}:#{@apikey}"
      req.body = attributes.to_json
    end
  end
  
  def delete_resource(content_type, name)
    slug = slugify(name)
    
    @site.delete do |req|
      req.url "api/#{content_type}/#{slug}"
      req.headers['Authorization'] = "ApiKey #{@user}:#{@apikey}"
    end
  end

  def slugify(string)
    string.strip.gsub(' ', "_")
  end

end