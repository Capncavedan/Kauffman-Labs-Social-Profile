require "rubygems"
require "twitter"
require 'date'

handle = 'Capncavedan'
handle = ARGV[0] if ARGV[0] && ARGV[0] != ''

most_common_words = %w(- = the of and a to in is you that it he was for on are as with his they i at be this have from or one had by word but not what all were we when your can said there use an each which she do how their if will up other about out many then them these so some her would make like him into time has look two more write go see number no way could people my than first water been call who oil its now find long down day did get come made may part)

def geo_js(tweet)
  <<EOS;
var myLatlng#{tweet.id} = new google.maps.LatLng(#{tweet.geo.coordinates[0]},#{tweet.geo.coordinates[1]});
var marker = new google.maps.Marker({ position: myLatlng#{tweet.id}, map: map, title:"Hi" });
EOS
end

htmlout = File.open("./info.html", "wb")
htmlout.puts "<html><head></head><body><h1>@#{handle}</h1>";

Twitter.configure do |config|
  config.consumer_key = 'SLk0eHw3vMLgV7hfNsfhA'
  config.consumer_secret = 'SECRET'
  config.oauth_token = '17175067-nlgf1YEhrEpkEA8ZlrNcVI2IYwyRZrvzWA34n149Y'
  config.oauth_token_secret = 'SECRET'
end

require('./config')

client = Twitter::Client.new
f = File.read('./map.html')

tweets = []
i = 1
10.times do
  print '.'
  begin
    tweets << client.user_timeline(handle, :count => 200, :page => i)
    i += 1
  rescue Exception => e
  end
end

tweets.flatten!

hours = Hash.new(0)
text = ''
clients = Hash.new(0)
geo_info = ''

tweets.each do |t|
  geo_info << geo_js(t) unless t.geo.nil?
  hour = DateTime.parse(t.created_at).hour
  hours[hour] += 1
  text << ' ' << t.text.downcase
end
html = f.sub(/^(.*BEGINHERE)(.*)(\/\/ENDHERE.*)$/m, "\\1\n#{geo_info}\\3")

htmlout.puts "<h2>Hours They <strike>Procrastinate</strike> Tweet</h2><table><tr><td><strong>Hour</td><td><strong>Count</td></tr>"
(0..23).each do |h|
  htmlout.puts "<tr><td>#{h}</td><td>#{hours[h]}</td></tr>"
end
htmlout.puts "</table>"

File.open('./map.html', 'wb') do |f|
  f.puts html
end

twitter_handles = Hash.new(0)
tokens = Hash.new(0)
(text.split(/\s+/) - most_common_words).each do |token|
  token.sub!(/^[\(]/, '')
  token.sub!(/[\.\!,:\)\?]$/, '')
  token.gsub!(/"'/, '')
  next if token.length == 1
  twitter_handles[token] += 1 if token =~ /^@/
  next if token =~ /^@/
  next if most_common_words.include?(token)
  tokens[token] += 1
end

htmlout.puts "<h2>Most Favoritist Words</h2><table><tr><td><strong>Words</td><td><strong>Count</td></tr>"
i = 0
tokens.sort_by{ |k,v| v }.reverse.each do |token|
  i += 1
  next if i > 50
  htmlout.puts "<tr><td>#{token[0]}</td><td>#{token[1]}</td></tr>"
end
htmlout.puts "</table>"

htmlout.puts "<h2>Users They Mention Most</h2><table><tr><td><strong>Handle</td><td><strong>Count</td></tr>"
twitter_handles.sort_by{ |k,v| v }.reverse.each do |handle|
  htmlout.puts "<tr><td><a href='http://twitter.com/#{handle[0]}' target='_blank'>#{handle[0]}</a></td><td>#{handle[1]}</td></tr>"
end
htmlout.puts "</table>"

htmlout.puts "<h2>Where They've Tweeted</h2><br/><iframe src='map.html' width='100%' height='100%' /></body></html>"

htmlout.close
`open ./info.html`
exit 0