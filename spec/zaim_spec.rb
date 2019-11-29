require './lib/user'
require './lib/zaim'

describe 'zaimスクレイピングテスト' do

  context 'ログインのテスト' do
    before(:all) do
      @user = User.new("hoge_fuga_ho-1@yahoo.co.jp", "hogefuga")
      @ng_user = User.new("hoge_fuga_ho-999@yahoo.co.jp", "hogefuga")
      @zaim = Zaim.new()
    end

    it 'User情報に誤りがある場合、ログインできない' do
      expect(@zaim.login(@ng_user)).to eq(false)
    end

    it 'User情報が正しい場合、ログインできる' do
      expect(@zaim.login(@user)).to eq(true)
    end
  end

  context '入力履歴表示のテスト' do

    before(:all) do
      @user = User.new("hoge_fuga_ho-1@yahoo.co.jp", "hogefuga")
      @zaim = Zaim.new()
      @zaim.login(@user)
    end

    it '入力履歴がない年月を指定した場合、何も表示されない' do 
      @zaim.get_money_info("201909")
      expect(@zaim.print_money_info()).to eq(false)
    end

    it '入力履歴がある年月を指定した場合、表示される' do
      @zaim.get_money_info("201910")
      expect(@zaim.print_money_info()).to eq(true)
      @zaim.get_money_info("201911")
      expect(@zaim.print_money_info()).to eq(true)
    end
  end

  context '入力履歴表示内容のテスト' do

    before(:all) do
      @user = User.new("hoge_fuga_ho-1@yahoo.co.jp", "hogefuga")
      @zaim = Zaim.new()
      @zaim.login(@user)
      @doc =  @zaim.get_money_info("201911")
    end

    it '日付が取得できている' do 
      expect(@doc.css('table.list > tbody.money-list').css('td.date > a.edit-money').map{|data| data.text() }).to include "11月29日（金）\n"
    end

    it 'カテゴリーが取得できている' do 
      expect(@doc.css('table.list > tbody.money-list').css('td.category > a.edit-money').map{|data| data.text() }).to include "給与所得\n"
    end

    it '価格が取得できている' do 
      expect(@doc.css('table.list > tbody.money-list').css('td.price > a.edit-money').map{|data| data.text() }).to include "¥220,000\n"
    end

    # 入金・出金はテストデータ作成不可のため、未実施
    # it '出金が取得できている' do 
    #   expect(@doc.css('table.list > tbody.money-list').css('td.from_account > a.edit-money > img').map{|data| data.get_attribute('data-title') }).to include ""
    # end

    # it '入金が取得できている' do 
    #   expect(@doc.css('table.list > tbody.money-list').css('td.to_account > a.edit-money > img').map{|data| data.get_attribute('data-title') }).to include ""
    # end

    it 'お店が取得できている' do 
      expect(@doc.css('table.list > tbody.money-list').css('td.place > a.edit-money > span').map{|data| data.get_attribute('title') }).to include "コンビニ"
    end

    it '品目が取得できている' do 
      expect(@doc.css('table.list > tbody.money-list').css('td.name > div.name > a.edit-money > span').map{|data| data.get_attribute('title') }).to include "接待費"
    end

    it 'メモが取得できている' do 
      expect(@doc.css('table.list > tbody.money-list').css('td.comment > div.comment > a.edit-money > span').map{|data| data.get_attribute('title') }).to include "コーヒーのみ"
    end

    it '支出の合計が取得できている' do 
      expect(@doc.css('table.amount_summary').css('td.money_payment_amount').text()).to include "¥25,360\n"
    end

    it '収入の合計が取得できている' do 
      expect(@doc.css('table.amount_summary').css('td.money_income_amount').text()).to include "¥220,000\n"
    end
    it '総額が取得できている' do 
      expect(@doc.css('table.amount_summary').css('td.money_total_amount').text()).to include "¥194,640\n"
    end

  end

  context '指定年月チェックのテスト' do
    before(:all) do
      @user = User.new("hoge_fuga_ho-1@yahoo.co.jp", "hogefuga")
      @zaim = Zaim.new()
      @zaim.login(@user)
    end

    it '年月にyyyyMM形式以外を指定した場合、エラーとなる(6桁以外）' do
      expect(@zaim.get_money_info("20191")).to eq(false)
    end

    it '年月にyyyyMM形式以外を指定した場合、エラーとなる(数値以外）' do
      expect(@zaim.get_money_info("あいうえおか")).to eq(false)
    end

    it '年月にyyyyMM形式以外を指定した場合、エラーとなる(存在しない年月）' do 
      expect(@zaim.get_money_info("201913")).to eq(false)
    end 
  end

  context 'ログイン状態のテスト' do

    before(:all) do
      @user = User.new("hoge_fuga_ho-1@yahoo.co.jp", "hogefuga")
      @zaim = Zaim.new()
    end

    it 'ログインせずに入力履歴表示処理を行うとエラー' do 
      expect(@zaim.get_money_info("201911")).to eq(false)
    end
  end
end