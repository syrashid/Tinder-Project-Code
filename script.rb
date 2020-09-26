require 'json'
require_relative 'models/conversation'
require_relative 'models/message'
require 'pry'
require 'time'
require 'sentimental'

# Prep the data for all the cool stuff we're going to do with it
filepath = 'data.json'
serialized_data = File.read(filepath)
message_data = JSON.parse(serialized_data)['Messages']

stop_word_file_path = 'stop_words.txt'

conversations = []

#sentiment analyzer
analyzer = Sentimental.new
analyzer.load_defaults

# Process message data and apply sentiment
message_data.each do |raw_data|
  conversation = Conversation.new(raw_data['match_id'])
  raw_messages = raw_data['messages']
  raw_messages.each do |raw_msg|
    if raw_msg['type'] == 'gif'
      conversation.messages << Message.new(raw_msg['message'], raw_msg['sent_date'])
    else
      conversation.messages << Message.new(raw_msg['message'], raw_msg['sent_date'], 'string')
      conversation.messages.last.update_with_sentiment(analyzer)
    end
  end
  conversations << conversation
end

puts "Your total messages were: #{message_data.count}"

# Collect all fruitful conversations
fruity_convos = conversations.select(&:fruitful?)

puts ""

# Print all fruitful Conversations
puts "Printing all of your fruitful conversations (#{fruity_convos.count}):"
fruity_convos.each do |convo|
  puts "Conversation Number #{convo.id}"
  puts "---------------------------"
  convo.messages.each do |message|
    puts message.text if message.type =='string'
  end
  puts ""
end
puts ""

# Create Raw Word Hash
raw_hash = {}
fruity_convos.each do |convo|
  convo.messages.each do |message|
    if message.type == 'string'
      message.text.split(/\s+/).each do |word|
        raw_hash.key?(word.downcase) ? raw_hash[word.downcase] += 1 : raw_hash[word.downcase] = 1
      end
    end
  end
end

# Clean Raw Word Hash
# Picks top 40 words
number_of_words = 40
File.open(stop_word_file_path, "r").each_line { |word| raw_hash.delete(word.strip.downcase) }
clean_hash = raw_hash.sort_by { |_k, v| v }.reverse.first(number_of_words).to_h

# Print word hash for word cloud
puts "Printing your word hash below:"
clean_hash.each do |key, value|
  puts "#{value} #{key} #DF4723"
end
puts ""

# Check to see record number of overlaps
overlapping_convos = []
record = 0
fruity_convos.each do |convo|
  overlapping_convos << convo
  overlapping_convos.select! do |ov_convo|
    convo.overlaps?(ov_convo)
  end
  record = overlapping_convos.count if overlapping_convos.count > record
end
puts "Max Conversations had simultaneously was #{record}"
puts ""
# Average overall sentiment of all fruitful conversation messages
sum = 0
count = 0
conversations.each do |convo|
  convo.messages.each do |message|
    sum += message.sentiment_score
  end
  count += convo.messages.size
end

puts "Overall message sentiment score was #{sum / count}"
