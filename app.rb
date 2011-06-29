# encoding: UTF-8

get '/' do
  haml :index
end

get '/style.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :style
end

def charcode_array(src1, src2)
  ar = [src1, src2]
  t = []
  ar.each do |ch|
    # p ch #文字
    # p ch.unpack("U*")[0] #10進数の文字コード
    # p format("%x", ch.unpack("U*")[0]) #16進数の文字コード
    if ch.match(/[^ .,]+/)
      t << [ ch.unpack("U*")[0] ][0] #一つずらして戻す
    else
      t << ch
    end
  end
  t.sort{|a,b|b <=> a}
end

def calc_sign(array, calc)
  case calc
  when "+" then array[0] + array[1]
  when "-" then array[0] - array[1] # 20以下は制御コード
    # unicodeのレンジ？エラーをつかめてない
  when "*" then (array[0] * array[1]) < 196607 ? (array[0] * array[1]) : 196608 # 196607(2FFFF)以上はエラー？
  when "/" then (array[0] / array[1]) < 21 ? 21 : (array[0] / array[1]) 
  end
end

get '/calc' do
  query1 = params[:query1]
  query2 = params[:query2]
  calc = params[:calc]
  char_code_10 = calc_sign(charcode_array(query1, query2), calc)
  @result = [ query1, calc, query2, "=", [char_code_10].pack("U")[0],"(",char_code_10.to_s(16),")" ].join(' ')
  # @result = [query1, calc, query2, "=", char_code_10].join(' ')
  haml :result
end