
# TBD
require "net_http_ssl_fix"
require 'net/http'
require "json"

def get_random_aircraft_image()
    img_url = nil
    article_title = nil
    
    10.times do 
        article_title = get_random_aircraft_article()
        #puts "Title chosen as: #{article_title}"
        
        img_url = find_article_image(article_title) if article_title
    
        break if !img_url.nil?
    end

    #puts "Img url chosen as: #{URI.encode(img_url)}"
    return URI.encode(img_url), URI.encode(article_title)
end

def find_article_image(article_title)
    url = URI.encode("https://en.wikipedia.org/w/api.php?action=query&titles=#{article_title}&prop=pageimages&format=json")
    
    page_image = nil
    begin
    resp = Net::HTTP.get(URI(url))
    j_resp = JSON.parse(resp)
    
    page = j_resp["query"]["pages"].first
    page_collection = page[1]
    page_image = page_collection["pageimage"]
    
    # Could probably do this with a generator?
    url2 = URI.encode("https://en.wikipedia.org/w/api.php?action=query&titles=File:#{page_image}&prop=imageinfo&iiprop=url&format=json")
    
    #puts "url2: #{url2}"
    resp = Net::HTTP.get(URI(url2))
    j_resp = JSON.parse(resp)
    
    page = j_resp["query"]["pages"].first
    page_collection = page[1]
    image_info = page_collection["imageinfo"]

    if !image_info.nil?
        image_url = image_info.first["url"]
        
        # Brutal heuristic, but gets rid of wiki placeholder svg's
        if !image_url.end_with?(".jpg")
            return nil
        end
    else
        return nil
    end
    
    rescue Exception => e  
        puts e.message 
    return nil
    end
    
    return image_url
    
end

def get_random_aircraft_article()  

    # Extracted from lists like https://en.wikipedia.org/wiki/List_of_aircraft_(B-Be)
    choices = [ '0-Ah', 'Ai-Am', 'An-Az', 'B-Be', 'Bf-Bo', 'Br-Bz', 'C-Cc', 'Cd-Cn', 'Co-Cz', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'La-Lh', 'Li-Lz', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']
    
    choice = choices.sample
    #puts "Top choice as: #{choice}"
    
    # Biggest problem is that only first 500, and we don't page next..
    url = URI.encode("https://en.wikipedia.org/w/api.php?action=query&titles=List_of_aircraft_(#{choice})&prop=links&pllimit=max&format=json")
    
    random_link = nil
    begin
        resp = Net::HTTP.get(URI(url))
        j_resp = JSON.parse(resp)
    
        page = j_resp["query"]["pages"].first
        page_collection = page[1]
        links = page_collection["links"]
    
        link_candidates = []
    
        if !links.nil?
        links.each do |link|
            if link["title"].start_with?(choice[0])
            link_candidates << link["title"]
            #puts "link title: #{link["title"].to_s}"
            end
        end
    
        random_link = link_candidates.sample
        else
        return nil
        end
        
    rescue Exception => e  
        puts e.backtrace 
        return nil
    end

    return random_link

end

puts "Results: #{get_random_aircraft_image()}"