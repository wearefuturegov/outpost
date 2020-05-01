task :ofsted => :environment do
    response = HTTParty.get("https://bucks-ofsted-feed.herokuapp.com?api_key=#{ENV["OFSTED_API_KEY"]}")
    data = JSON.parse(response.body)

    byebug
end