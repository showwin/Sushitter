class Tweet < ActiveRecord::Base
  
  include Word

  #文章のポジネガScore取得
  def get_score
    score = 0.0
    node = MeCab::Tagger.new.parseToNode(content)
    node = node.next
    while node.next
      elem = (node.feature).split(",")
      parts = elem[0]
      if parts == "名詞" || parts == "動詞" || parts == "形容詞" || parts == "副詞" || parts == "助動詞"
        elem[6] = node.surface if elem[6]=="*"
        word = elem[6]
        kana = Word.get_kana(word)
        result = Dictionary.where(word: word, kana: kana, owner: name).first
        score += result.value if result
      end
      node = node.next
    end
    score
  end
  
  def get_emotion
    score>=0 ? 1 : -1
  end
end
