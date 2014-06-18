class Dictionary < ActiveRecord::Base
  
  include Word
  
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
      (value + score/100.0) > 1 ? 1 : value + score/100.0  
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
