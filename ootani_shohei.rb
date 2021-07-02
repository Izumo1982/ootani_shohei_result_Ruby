require 'open-uri'

class SourceGet
  def initialize(url)
    @source = URI.open(url).read
  end

  def get_slice(st_no, st_plus, st_wd, en_wd)
	  st = @source.index(/#{st_wd}/, st_no)
    return nil, 0 if st == nil
	  st += st_plus
    en = @source.index(/#{en_wd}/, st + 1)
    return @source.slice(st..en - 1), en
  end
end

class StringGet <  SourceGet
  def initialize(str)
    @source = str
  end
end

def output(t_result, b_result, p_result)
	t_result.store("規定投球回数", t_result["勝利"] + t_result["敗北"])
	t_result.store("規定打席数", (t_result["規定投球回数"] * 3.1).to_i)
	b_result.store("打席", (b_result["打数"] + b_result["四球"] + b_result["死球"] + b_result["犠打"] + b_result["犠飛"]))

	puts "頑張れ大谷選手！！\n投手成績"
	puts "今日の時点での規定投球回数：#{t_result["規定投球回数"]}回"
	puts "今日の時点での投球回数　　：#{p_result["投球回"]}回" 
	if t_result["規定投球回数"] <= p_result["投球回"]
	  puts "規定投球回数到達！！"
	else
	  puts "規定投球回数まであと#{t_result["規定投球回数"] - p_result["投球回"]}イニング！"
	end

	puts "\n打撃成績"
	puts "今日の時点での規定打席数：#{t_result["規定打席数"]}打席"
	puts "今日の時点での打席数　　：#{b_result["打席"]}打席"
	if t_result["規定打席数"] <= b_result["打席"]
	  puts "規定打席数到達！！"
	else
	  puts "規定打席数まであと#{t_result["規定打席数"] - p_result["打席"]}打席！"
	end

end

#エンゼルスの成績（勝敗）
team = SourceGet.new(%!https://baseball.yahoo.co.jp/mlb/standing/!)
#大谷翔平の野手成績
fielder = SourceGet.new(%!https://baseball.yahoo.co.jp/mlb/teams/player/fielder/stats/727378!)
#大谷翔平の投手成績
pitcher = SourceGet.new(%!https://baseball.yahoo.co.jp/mlb/teams/player/pitcher/stats/727378!)

p_result = {}
data, st = pitcher.get_slice(0, 0,"<!--年間成績-->","<!--main end-->")
p_source =  StringGet.new(data)

st1, st2 = 1, 1
while st1 != 0 do
  data1, st1 = p_source.get_slice(st1, 4, "<th>", "</th>")
  data2, st2 = p_source.get_slice(st2, 4, "<td>", "</td>")
  if data2 != nil ; p_result.store("#{data1}", data2.to_i); end
end

b_result = {}
data, st = fielder.get_slice(0, 0,"<!--年間成績-->","<!--main end-->")
b_source =  StringGet.new(data)

st1, st2 = 1, 1
while st1 != 0 do
  data1, st1 = b_source.get_slice(st1, 4, "<th>", "</th>")
  data2, st2 = b_source.get_slice(st2, 4, "<td>", "</td>")
  if data2 != nil ; b_result.store("#{data1}", data2.to_i); end
end


t_result = {}
data, st = team.get_slice(0, 0,"エンゼルス","</td>")
data, st = team.get_slice(st, 15, %!<td class="ga">!, "</td>")
t_result.store("勝利", data.to_i)
data, st = team.get_slice(st, 4, %!<td>!, "</td>")
t_result.store("敗北", data.to_i)

output(t_result, b_result, p_result)