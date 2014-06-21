class Dictionary < ActiveRecord::Base
  require "CSV"
  require 'kconv'
  include Word
  
  def self.make(owner,csv_file)
    Dictionary.make_teacher_temp(owner, csv_file)
    Dictionary.make_teacher(owner)
    Dictionary.make_no_teacher(owner)
  end
  
  def self.make_teacher_temp(owner, csv_file)
    fw_temp = open("public/teacher_temp/"+owner+".txt", "w")
    CSV.parse(Kconv.toutf8(csv_file.read)) do |row|
      content = row[5]
      next if content.include?("@")
      next if content.include?("RT")
      next if content.include?("#")
      next if content.include?("http")
      fw_temp.write(str+"\n")
    end
    fw_temp.close
  end
  
  def self.make_teacher(owner)
    fw = open("public/no_teacher/"+owner+".txt", "w")
    fr = open("public/teacher_temp/"+owner+".txt", "r")
    j = 0
    fr.each_line do |line|
      next if line.size < 30
      fw.write(line)
      j+=1
      break if j >= 2000
    end
    fr.close
    fw.close
  end
  
  def make_no_teacher(owner)
    ts = open("public/teacher/"+owner+".txt", "w")
    nts = open("public/no_teacher/"+owner+".txt", "r")
    j = 0
    nts.each_line do |line|
      if rand(30) == 1
        ts.write(line)
        j+=1
        break if j == 50
      end
    end
    ts.close
    nts.close
  end
  
  def self.start_learning(owner,emotions)
    tweets = []
    tweets_text = ""
    File.open("public/teacher/"+owner+".txt", 'r') { |f| tweets_text=f.read }
    tweets_text.each_line do |line|
      tweets.push(line.chomp)
    end
    0.upto(49) do |i|
      answer = "answer"+i.to_s
      tweet = Tweet.new(content: tweets[i], name: owner, emotion: emotions[i])
      self_emo = true
      tweet.score = tweet.emotion
      tweet.save
      Dictionary.value_update(tweet, true)
    end
    Dictionary.no_teacher_learning(owner)
  end
  
  def self.no_teacher_learning(owner)
    f = open("./public/no_teacher/"+owner+".txt")
    f.each_line do |line|
      tweet = Tweet.new(content: line, name: owner)
      tweet.score = tweet.get_score
      tweet.emotion = tweet.get_emotion
      tweet.save
      Dictionary.value_update(tweet, false)
    end
    f.close
  end
  
  def self.value_update(tweet, self_emo)
    score = tweet.score
    nm = Natto::MeCab.new
    nm.parse(tweet.content) do |node|
      elem = (node.feature).split(",")
      parts = elem[0]
      if parts == "名詞" || parts == "動詞" || parts == "形容詞"
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
      if (value + score/10.0) > 1
        value = 1
      elsif (value + score/10.0) < -1
        value = -1
      else
        value += score/10.0
      end
    elsif score > 0.5 || score < -0.5
      if (value + score/1000.0) > 1 
        value = 1
      elsif (value + score/1000.0) < -1 
        value = -1
      else
        value += score/1000.0
      end
    end
    value
  end
  
  def self.add_word(owner, word, kana)
    dic = Dictionary.new
    dic.owner = owner
    dic.word = word
    dic.kana = kana
    dic.value = 0
    dic.save
  end
  
  ###==========================
  ### for debugging as follows
  ###==========================
  
  def self.self_no_teacher_learning(owner,num1,num2,num3,num4)
    f = open("./app/assets/data/tweets"+num1.to_s+".txt")
    f.each_line do |line|
      tweet = Tweet.new(content: line, name: owner)
      tweet.score = tweet.get_score
      tweet.emotion = tweet.get_emotion
      tweet.save
      Dictionary.value_update(tweet, false)
    end
    f.close
    if num2 != 0
      f = open("./app/assets/data/tweets"+num1.to_s+".txt")
      f.each_line do |line|
        tweet = Tweet.new(content: line, name: owner)
        tweet.score = tweet.get_score
        tweet.emotion = tweet.get_emotion
        tweet.save
        Dictionary.value_update(tweet, false)
      end
      f.close
    end
    if num3 != 0
      f = open("./app/assets/data/tweets"+num1.to_s+".txt")
      f.each_line do |line|
        tweet = Tweet.new(content: line, name: owner)
        tweet.score = tweet.get_score
        tweet.emotion = tweet.get_emotion
        tweet.save
        Dictionary.value_update(tweet, false)
      end
      f.close
    end
    if num4 != 0
      f = open("./app/assets/data/tweets"+num1.to_s+".txt")
      f.each_line do |line|
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
  
  def self.part_teacher_learning(owner,num1,num2,num3,num4)
    CSV.foreach("./app/assets/data/teacher"+num1.to_s+".csv") do |row|
      word = row[0]
      output = row[1].to_i
      tweet = Tweet.new(content: word, name: owner, emotion: output)
      self_emo = true
      tweet.score = tweet.emotion.to_i
      tweet.save
      Dictionary.value_update(tweet, true)
    end
    if num2 != 0
      CSV.foreach("./app/assets/data/teacher"+num2.to_s+".csv") do |row|
        word = row[0]
        output = row[1].to_i
        tweet = Tweet.new(content: word, name: owner, emotion: output)
        self_emo = true
        tweet.score = tweet.emotion.to_i
        tweet.save
        Dictionary.value_update(tweet, true)
      end
    end
    if num3 != 0
      CSV.foreach("./app/assets/data/teacher"+num3.to_s+".csv") do |row|
        word = row[0]
        output = row[1].to_i
        tweet = Tweet.new(content: word, name: owner, emotion: output)
        self_emo = true
        tweet.score = tweet.emotion.to_i
        tweet.save
        Dictionary.value_update(tweet, true)
      end
    end
    if num4 != 0
      CSV.foreach("./app/assets/data/teacher"+num4.to_s+".csv") do |row|
        word = row[0]
        output = row[1].to_i
        tweet = Tweet.new(content: word, name: owner, emotion: output)
        self_emo = true
        tweet.score = tweet.emotion.to_i
        tweet.save
        Dictionary.value_update(tweet, true)
      end
    end
  end
  
  def self.check(owner)
    pp = 0
    pn = 0
    np = 0
    nn = 0
    fault = 0
    i = 0
    CSV.foreach("./app/assets/data/teacher_all.csv") do |row|
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
  
  def self.part_check(owner,num1,num2,num3,num4)
    pp = 0
    pn = 0
    np = 0
    nn = 0
    normal = 0
    fault = 0
    CSV.foreach("./app/assets/data/new_teacher"+num1.to_s+".csv") do |row|
      word = row[0]
      output = row[1].to_f
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
      elsif tweet.emotion == 0 && (output == 0.5 || output == -0.5)
        normal += 1
      else
        fault += 1
      end
    end
    if num2 != 0
      CSV.foreach("./app/assets/data/new_teacher"+num2.to_s+".csv") do |row|
        word = row[0]
        output = row[1].to_f
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
        elsif tweet.emotion == 0 && (output == 0.5 || output == -0.5)
          normal += 1
        else
          fault += 1
        end
      end
    end
    if num3 != 0
      CSV.foreach("./app/assets/data/new_teacher"+num3.to_s+".csv") do |row|
        word = row[0]
        output = row[1].to_f
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
        elsif tweet.emotion == 0 && (output == 0.5 || output == -0.5)
          normal += 1
        else
          fault += 1
        end
      end
    end
    if num4 != 0
      CSV.foreach("./app/assets/data/new_teacher"+num4.to_s+".csv") do |row|
        word = row[0]
        output = row[1].to_f
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
        elsif tweet.emotion == 0 && (output == 0.5 || output == -0.5)
          normal += 1
        else
          fault += 1
        end
      end
    end
    p "PP:"+pp.to_s
    p "PN:"+pn.to_s
    p "NP:"+np.to_s
    p "NN:"+nn.to_s
    p "Normal:"+normal.to_s
    p "fault:"+fault.to_s
  end
end
