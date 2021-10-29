# frozen_string_literal: true

require 'twitter'

def reply(tweet)
  resp = client.update("@#{tweet.user.screen_name} #{elucidation}", in_reply_to_status_id: tweet.id)
  puts resp.url

  exit(true)
end

def tweets
  @tweets ||= client.search('spiderman', options).collect
end

def elucidation
  <<~WORDS.strip.gsub(/\s+/, ' ')
    I’m really sorry to interrupt but, see, you’re saying it without the hyphen. It's
    just like the tiniest pause in between the words. Spider-Man.
  WORDS
end

def options
  {
    result_type: 'recent',
    lang: 'en',
    include_entities: false
  }
end

def client
  @client ||= Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV.fetch('CONSUMER_KEY')
    config.consumer_secret     = ENV.fetch('CONSUMER_SECRET')
    config.access_token        = ENV.fetch('ACCESS_TOKEN')
    config.access_token_secret = ENV.fetch('ACCESS_TOKEN_SECRET')
  end
end

tweets.each do |tweet|
  puts "#{tweet.user.screen_name}: #{tweet.text}"
  next if tweet.retweet?
  next if tweet.quote?

  tweet.text.split(' ').each do |word|
    next unless word.downcase =~ /^spiderman$/

    reply(tweet)
  end
end
