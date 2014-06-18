class Dictionary < ActiveRecord::Base
  require "CSV"
  include Word
  
  def self.no_teacher_learning(owner)
    1.upto(10) do |number|
      f = open("./app/assets/data/tweets"+number.to_s+".txt")
      i = 0
      f.each_line do |line|
        i += 1
        p i
        tweet = Tweet.new(content: line, name: owner)
        tweet.score = tweet.get_score
        tweet.emotion = tweet.get_emotion
        tweet.save
        Dictionary.value_update(tweet, false)
      end
      f.close
    end
  end
  
  def self.teacher_learning(owner)
    i = 0
    CSV.foreach("./app/assets/data/teacher.csv") do |row|
      i += 1
      p i
      word = row[0]
      output = row[1].to_i
      tweet = Tweet.new(content: word, name: owner, emotion: output)
      self_emo = true
      tweet.score = tweet.emotion.to_i
      tweet.save
      Dictionary.value_update(tweet, true)
    end
  end
  
  def self.check(owner)
    pp = 0
    pn = 0
    np = 0
    nn = 0
    fault = 0
    i = 0
    CSV.foreach("./app/assets/data/teacher.csv") do |row|
      i += 1
      p i
      word = row[0]
      output = row[1].to_i
      tweet = Tweet.new(content: word, name: owner)
      tweet.score = tweet.get_score
      tweet.emotion = tweet.get_emotion
      p tweet.emotion
      p output
      if tweet.emotion == 1 && output == 1
        pp += 1
      elsif tweet.emotion == 1 && output == -1
        pn += 1
      elsif tweet.emotion == -1 && output == 1
        np += 1
      elsif tweet.emotion == -1 && output == -1
        nn += 1
      else
        fault += 1
      end
    end
    p "PP:"+pp.to_s
    p "PN:"+pn.to_s
    p "NP:"+np.to_s
    p "NN:"+nn.to_s
  end
  
  def self.make(owner)
    f = open("./app/assets/data/dictionary.txt")
    f.each_line do |line|
      array = line.split(":")
      dic = Dictionary.new
      dic.owner = owner
      dic.word = array[0]
      dic.kana = array[1]
      dic.value = array[3].to_f
      dic.save
    end
    f.close
  end
  
  #極性の修正
  def self.value_update(tweet, self_emo)
    score = tweet.score
    node = MeCab::Tagger.new.parseToNode(tweet.content)
    node = node.next
    while node.next
      elem = (node.feature).split(",")
      parts = elem[0]
      if parts == "名詞" || parts == "動詞" || parts == "形容詞" || parts == "副詞" || parts == "助動詞"
        elem[6] = node.surface if elem[6]=="*"
        word = elem[6]
        kana = Word.get_kana(word)
        result = Dictionary.where(word: word, kana: kana, owner: tweet.name).first
        if result
          result.value = self.get_new_value(result.value, score, self_emo)
          result.save
        else
          self.add_word(tweet.name, word, kana)
        end
      end
      node = node.next
    end
  end
  
  def self.get_new_value(value, score, self_emo)
    if self_emo
      (value + score/10.0) > 1 ? 1 : value + score/10.0  
    else
      (value + score/1000.0) > 1 ? 1 : value + score/1000.0
    end
  end
  
  def self.add_word(owner, word, kana)
    dic = Dictionary.new
    dic.owner = owner
    dic.word = word
    dic.kana = kana
    dic.value = 0
    dic.save
  end
end
