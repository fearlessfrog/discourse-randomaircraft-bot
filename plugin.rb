# name: discourse-randomaircraft-bot
# about: returns a random aircraft from wikipedia to guess what it is
# version: 1
# authors: fearlessfrog
# url: https://github.com/fearlessfrog/discourse-randomaircraft-bot

after_initialize do

    require 'net/http'
    require "json"

    def get_random_aircraft_image()
        img_url = nil
        article_title = nil
        
        50.times do 
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

    on(:post_created) do |post, params|
    
        if SiteSetting.randomaircraft_bot_enabled
            if post.raw =~ /\[ *randomaircraft *\]/i

                if post.user.username.downcase == "Bogusheadbox".downcase
                        post.raw = "@#{post.user.username} has asked for a **Random Aircraft** quiz.\n\n"
                        post.raw += "----\n\n"
                        post.raw += "<img src='#{ URI.encode('https://upload.wikimedia.org/wikipedia/commons/thumb/a/a3/F-111F_dropping_high-drag_bombs.jpg/1280px-F-111F_dropping_high-drag_bombs.jpg')}'/>\n\n"
                        post.raw += "----\n\n"
                        post.raw += "<details><summary>Answer below (no peeking!)</summary>What did you expect Mr B?</details>\n\n"

                        # Will cook, hopefully
                        post.save
                else                
                    img, article = get_random_aircraft_image()
                    if !img.nil? && !article.nil?
                        post.raw = "@#{post.user.username} has asked for a **Random Aircraft** quiz.\n\n"
                        post.raw += "----\n\n"
                        post.raw += "<img src='#{img}'/>\n\n"
                        post.raw += "----\n\n"
                        post.raw += "<details><summary>Answer below (no peeking!)</summary>[#{URI.decode(article)}](https://en.wikipedia.org/wiki/#{article})</details>\n\n"

                        # Will cook, hopefully
                        post.save
                    end
                end
            end
        end
    end
end
