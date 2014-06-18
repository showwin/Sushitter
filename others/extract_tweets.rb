require "csv"

fw_temp = open("tweets_temp.txt", "w")
CSV.foreach("tweets.csv") do |row|
  str = row[5]
  next if str.size < 30
  next if str.include?("@")
  next if str.include?("RT")
  next if str.include?("#")
  next if str.include?("http")
  fw_temp.write(str+"\n")
end
fw_temp.close

fw = open("tweets.txt", "w")
fr = open("tweets_temp.txt", "r")
fr.each_line do |line|
  next if line.size < 30
  fw.write(line)
end
fr.close
fw.close