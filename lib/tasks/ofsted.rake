task :ofsted => :environment do
    response = HTTParty.get("https://bucks-ofsted-feed.herokuapp.com?api_key=#{ENV["OFSTED_API_KEY"]}")
    items = JSON.parse(response.body)

    items.each do |item|
        # ...
    end
end