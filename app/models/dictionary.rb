class Dictionary < ActiveRecord::Base
  
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
end
