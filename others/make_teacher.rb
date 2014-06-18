require 'CSV'

f = open("tweets.txt", "r")
CSV.open("teacher1.csv", "wb") do |csv|
  f.each do |line|
    csv << [line] if rand(40)==17
  end
end
f.close