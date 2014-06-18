module Word extend ActiveSupport::Concern
  
  #基本形の読みを取得
  def self.get_kana(word)
    node = MeCab::Tagger.new.parseToNode(word)
  	node = node.next
  	elem = node.feature.split(",")
  	elem[7] = node.surface if !elem[7]
  	elem[7].tr("ァ-ン", "ぁ-ん")
  end
  
end