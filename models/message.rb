class Message
  attr_accessor :text, :time_stamp, :type, :sentiment, :sentiment_score
  def initialize(message, time_stamp, type = 'gif')
    @text = clean_message(message)
    @time_stamp = Time.parse(time_stamp)
    @type = type
    @sentiment = 'nuetral'
    @sentiment_score = 0
  end

  def to_s
    @text
  end

  def update_with_sentiment(analyzer)
    @sentiment = analyzer.sentiment @text
    @sentiment_score = analyzer.score @text
  end

  private

  def clean_message(raw_message)
    message = raw_message.gsub(/(&rsquo;)/, "'")
    message = message.gsub(/(&sol;)/, '/')
    message = message.gsub(/(&apos;)/, "'")
    message = message.gsub(/(&colon;)/, ':')
    message = message.gsub(/(&quot;)/, "\"")
    message = message.gsub(/(&rpar;)/, ')')
    message = message.gsub(/(&lpar;)/, '(')
    message = message.gsub(/(&rdquo;)/, "\"")
    message.gsub(/(&gt;)/, '>')
  end
end
