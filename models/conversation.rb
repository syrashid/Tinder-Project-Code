require 'time'
require 'sentimental'

class Conversation
  attr_accessor :id, :messages
  def initialize(id)
    @id = id.delete('Match ').to_i
    @messages = []
  end

  def fruitful?
    @messages.count > 2
  end

  def start_date
    @messages.first.time_stamp
  end

  def end_date
    @messages.last.time_stamp
  end

  def time_range
    start_date..end_date
  end

  def time_diff_in_days
    (@messages.last.time_stamp - @messages.first.time_stamp)/60/60/24
  end

  def to_s
    temp_string = "Conversation #{@id} has #{@messages.count} message(s) and took place over #{time_diff_in_days} day(s):\n"
    @messages.each_with_index do |message, index|
      temp_string << "Message #{index + 1} (Sentiment: #{message.sentiment}): #{message.to_s}\n"
    end
    temp_string
  end

  def overlaps?(other)
    start_date <= other.end_date && other.start_date <= end_date
  end
end
