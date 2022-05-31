-- 必要なモジュールをロード
local Misc  = require("ukagaka_misc")
local Util  = require("talk._util")
local Math  = require("lib_sample")
local Lanes = require("lanes").configure()
local HTTP  = require("socket.http")
local LTN12 = require("ltn12")
local Json  = require("json")


local function dump(obj, indent)
  indent  = indent or ""
  local obj_type  = type(obj)
  if obj_type == "boolean" or obj_type == "number" then
    return tostring(obj)
  elseif obj_type == "string" then
    -- Note:
    -- luaのqでは制御文字をエスケープする処理が行われるが
    -- 制御文字の範囲が0x00-0x1f,0x7fに加えて
    -- 0x80-0x9fも含まれており、これがUTF-8のマルチバイト文字の
    -- 2byte目以降(0x80-0xbf)に重なっているため、
    -- 不必要なエスケープ処理が行われてしまう。
    -- これを元に戻す処理を行っているが、( \128 -> [0x80] )
    -- エスケープの後にこれらの文字が来た場合を想定していないため、
    -- ( \\128 -> \[0x80] )
    -- のようになってしまうことに注意。
    local str = string.format("%q", obj)
    str = str:gsub("\\(%d%d%d)", function(num)
      local n = tonumber(num)
      if n >= 0x80 then
        return string.format("%s", string.char(n))
      else
        return string.format("\\%s", num)
      end
    end)
    return str
  elseif obj_type == "table" then
    local str = "{\n"
    for k, v in pairs(obj) do
      str = str .. indent .. "  " .. "[" .. dump(k, indent .. "  ") .. "]=" .. dump(v, indent .. "  ") .. ",\n"
    end
    str = str .. indent .. "}"
    return str
  end
  return tostring(nil)
end

return {
  {
    id  = "OnSample", -- ←の「,」は必須
    content = "サンプル", -- ←の「,」は必須じゃないけど付けた方が間違いがない
  },  -- ←の「,」は必須
  {
    -- 変数の初期化等を行うイベント
    id  = "OnInitialize",
    content = function(shiori,ref)
      -- 通常の初期化
      -- 起動する度に初期化されるものに使う
      -- OnBoot内で行っても良い
      shiori.var("_Count", 0)
      -- 値が入ってないときの初期化
      -- ゴーストの初回起動で設定したいものに使う
      -- OnFirstBoot内で行えば↑の書き方が出来る
      if shiori.var("Interval") == nil then
        shiori.var("Interval", 30)
      end
      return nil
    end,
  },
  {
    -- 日付イベントはOnBootの呼び出し時に行う
    id      = "OnBoot",
    content = function(shiori, ref)
      local talk  = shiori:talk("日付イベント")
      -- 日付イベントが存在したらそのトークを喋る
      if talk then
        return talk
      end
      return shiori:talk("通常起動")
    end,
  },
  {
    id  = "通常起動",
    -- 基本的には「content = 文字列」
    -- の形式でOK
    content = "\\0\\s[0]こんにちは！",
  },
  {
    id  = "OnClose",
    -- もちろん複数行文字列もOK
    -- 「\-」は自分で入れないとダメ
    content = function(shiori, ref)
      local _T  = shiori.i18n
      return _T("goodbye")
    end,
  },
  {
    id  = "OnSecondChange",
    -- 何か処理が必要なものは
    -- content = function(shiori, ref)
    --    ...
    -- end
    -- の形式で記述する
    content = function(shiori, ref)
      local __  = shiori.var
      local count = __("_Count")
      count = count + 1
      if count == __("Interval") then
        __("_Count", 0)
        return shiori:talkRandom() -- ランダムトーク呼び出し
      end
      __("_Count", count)
      return nil
    end,
  },
  -- system/debug.luaに書いた処理によって
  -- OnKeyPressから呼ばれるようになっている
  {
    -- Tキーが押されたときの処理
    id  = "t_Key",
    content = function(shiori,ref)
      -- ランダムトーク
      return shiori:talkRandom()
    end,
  },
  {
    -- Sキーが押されたときの処理
    -- 右クリックメニューから言語を変更するとメッセージも変わる
    id  = "s_Key",
    content = [[
\0
Japanese/Englishでないときはこのトークが呼ばれる。
]],
    content_Japanese = [[
\0現在の言語: ${_Language}
]],
    content_English = [[
\0Current language: ${_Language}
]],
  },
  {
    -- Lキーが押されたときの処理
    id  = "l_Key",
    content = function(shiori,ref)
      print("logger.batのウィンドウに表示される文章だよ。")
      print("実行時のデバッグ情報とかをここに書くとデバッグが楽になるかも。")
      return [[\0logger.batを起動してからこのゴーストを起動してLキーを押してみてね。]]
    end,
  },
  {
    -- Aキーが押されたときの処理
    --
    -- マルチスレッドのサンプルコード
    -- 下記以外の処理(スレッド間のデータのやりとり等)は
    -- https://lualanes.github.io/lanes/
    -- を参照してください。
    -- *安易にマルチスレッドにする前に*
    -- その処理はtimerraiseで代替出来ないか検討してください。
    -- *Note*
    -- 現状、子スレッド内でshioriを使う方法が見つかっていません。
    id  = "a_Key",
    content = function(shiori, ref)
      local __  = shiori.var
      -- マルチスレッドで1秒後に"SSTPのテスト"と表示させる
      local f = Lanes.gen("*", {required = {}}, function(unique_id)
        local Misc  = require("ukagaka_misc")
        -- luaにはsleepする方法がないのでpingで代替
        os.execute("ping -n 2 localhost")
        Misc.speak(unique_id, "SSTPのテスト\\e")
      end)
      -- 子スレッド側にunique_idを渡す。
      f(__("_uniqueid"))
      return nil
    end,
  },
  {
    -- Mキーが押されたときの処理
    id  = "m_Key",
    content = function(shiori,ref)
      -- メニューを表示する
      return shiori:talk("OnMenu")
    end,
  },
  {
    -- Fキーが押されたときの処理
    id  = "f_Key",
    content = function(shiori,ref)
      -- FMOを取得する
      -- SHIORIがUTF-8出力なのでSakuraUnicodeを利用する方が良さそう
      local fmo = Misc.getFMO("SakuraUnicode")
      fmo = string.gsub(fmo, string.char(0x01), ",")
      fmo = string.gsub(fmo, [[\]], [[\\]])
      fmo = string.gsub(fmo, string.char(0x0d, 0x0a), [[\n]])
      return [[
\0
FMOを取得したよ。\n
\n
\_q
]] .. fmo .. [[\_q]]
    end,
  },
  {
    -- Hキーが押されたときの処理
    id  = "h_Key",
    content = function(shiori,ref)
      -- JSONのサンプル
      local t = {}
      HTTP.request({
        method  = "GET",
        url = "https://httpbin.org/headers",
        sink  = LTN12.sink.table(t)
      })
      --[[ POSTの場合
      -- HTTP.request({
      --   method = "POST",
      --   url = "http://example.com/",
      --   headers = {
      --     ["Content-Type"] = "application/x-www-form-urlencoded",
      --   },
      --   source = LTN12.source.string("key1=value1"),
      --   sink = LTN12.sink.table(t),
      -- })
      -- のようにする。
      -- 詳しくは
      -- https://lunarmodules.github.io/luasocket/
      -- のreferenceを読むこと。
      --]]
      -- 受信したデータをtable->stringへ変換
      local json  = table.concat(t)
      t = Json.decode(json)
      local str = dump(t, "")
      -- 改行を\nに置換
      str = string.gsub(str, "\r\n", "\\n")
      str = string.gsub(str, "\r", "\\n")
      str = string.gsub(str, "\n", "\\n")
      return [[
\0
jsonのテストだよ。\n
受信したJSONは\n
\_q]] .. str .. [[\_q\n
で、headers["User-Agent"]の値は\n
\_q]] .. t["headers"]["User-Agent"] .. [[\_q\nだよ。]]
    end,
  },
  {
    id  = "OnMenu",
    content = function(shiori, ref)
      local interval_list = {
        30, 60, 120, 180,
      }
      local interval_str  = {
        [30]  = "30秒",
        [60]  = "1分",
        [120] = "2分",
        [180] = "3分",
      }
      local interval  = shiori.var("Interval")
      if ref[0] then
        local index
        for i, v in ipairs(interval_list) do
          if interval == v then
            index = i
          end
        end
        index = index % #interval_list + 1
        interval  = interval_list[index]
        shiori.var("Interval", interval)
      end
      return "\\0\\_q喋る間隔\\_l[120,]" .. interval_str[interval] ..
              "\\_l[200,]\\q[変更,OnMenu,1]" ..
              "\\n\\n\\n\\n\\n\\n\\n\\n\\q[閉じる,OnMenuClose]\\_q"
    end,
  },
  {
    id  = "OnMenuClose",
    -- 特に返す値がない場合はcontent = ...を省略 or nilとする
    content = nil,
  },
  {
    id  = "OnSurfaceRestore",
    content = [=[\0\s[0]]=]
  },
  {
    id  = "日付イベント",
    content = function(shiori, ref)
      local __  = shiori.var
      local t = os.date("*t")
      local fmt = "%d年%d月%d日"
      local now = fmt:format(t.year, t.month, t.day)
      if __("LastCalled") ~= now then
        __("LastCalled", now)
        return shiori:talk(string.format("%d月%d日", t.month, t.day))
      end
      return nil
    end,
  },
  {
    id  = "1月1日",
    content = [[
\0\s[0]今日はお正月だね。
]],
  },
  {
    -- ランダムトークはidを付けない
    content = "\\0ランダムトークだよ。",
  },
  {
    -- requireで呼び出したモジュールを使うサンプル
    content = function(shiori,ref)
      return [[\0\s[0]1+2=]] .. Util.add(1, 2) .. [[\n]] ..
             [[3-1=]] .. Math.sub(3, 1) .. [[だよ。]]
    end,
  },
  {
    -- SAORIを使うサンプル
    content = function(shiori, ref)
      -- saori.confで設定した名前でSAORIを呼び出す
      local module  = shiori:saori("choice")
      -- 関数呼び出しと同じように書ける
      local ret = module("文字列1", "文字列2", "文字列3")
      -- Resultを取得する場合はret()
      -- ValueNを取得する場合はret[N]
      return "\\0" .. ret() .. "が選ばれたよ。"
      -- なお、それぞれつなげて書けるので
      -- return "\\0" .. shiori:saori("choice")("文字列1", "文字列2", "文字列3")() .. "が選ばれたよ。"
      -- と一行で書くことも可能。
    end,
  },
  {
    content = function(shiori, ref)
      -- あんまりよばれたくないトークは確率でshiori:talkRandomを
      -- 呼び出すようにする
      if math.random(4) > 2 then
        return shiori:talkRandom()
      end
      -- shiori:reserveTalkで次に話すランダムトークの予約が出来る
      shiori:reserveTalk("チェイントーク始め")
      return "\\0チェイントークに入るよ。"
    end,
  },
  {
    id  = "チェイントーク始め",
    content = function(shiori, ref)
      shiori:reserveTalk("チェイントーク続き")
      return "\\0チェイントークに入ったよ。"
    end,
  },
  {
    id  = "チェイントーク続き",
    content = function(shiori, ref)
      shiori:reserveTalk("チェイントーク終わり")
      return "\\0チェイントーク続きだよ。"
    end,
  },
  {
    id  = "チェイントーク終わり",
    content = [[\0チェイントークを終わるよ。]],
  },
  -- baseware.luaで
  -- OnAnchorSelectから呼ばれるようになっている
  {
    -- anchor = true が指定されたトークのidは自動リンクされるようになる
    anchor  = true,
    id  = "トーク",
    content = [[\0トークのアンカーだよ。]],
  },
  {
    content = [[
\0
選択肢だよ。\n
\q[選択肢1,選択肢1]\n
\q[選択肢2,選択肢2]\n
]],
  },
  {
    id  = "選択肢1",
    content = [[
\0
選択肢1が選ばれたよ！\n
]],
  },
  {
    id  = "選択肢2",
    content = [[
\0
選択肢2が選ばれたよ…\n
]],
  },
  {
    -- つつき反応
    id  = "0Poke",
    content = [[
\0
Ouch!\w9\w9\w9\n
\n
\n
\_q
＿人人人人人人人＿\n
＞　突然の英語  ＜\n
￣Y^Y^Y^Y^Y^Y^Y^￣\n
\_q
]],
  },
  {
    -- passthrough = true で自動リンクや置換、末尾\eの追加がされなくなる
    -- SHIORI Resource(sakura.recommendsitesとか)に使うことが多い
    -- 他のトークでは使うのが困難なので注意
    passthrough = true,
    id  = "sakura.recommendsites",
    -- recommendsitesやportalsitesの生成には
    -- createURLList関数を用いると楽。
    content = function(shiori, ref)
      return shiori:createURLList(
        {
          {"独立伺か研究施設 ばぐとら研究所", "http://ssp.shillest.net/"},
          -- セパレーター
          {"-", "-", "-"},
          {"The Programming Language Lua", "https://www.lua.org/"},
        })
    end,
  },
  -- ここからSHIORIの情報なので弄らない
  {
    passthrough = true,
    id  = "version",
    content = "1.1.0",
  },
  {
    passthrough = true,
    id  = "craftman",
    content = "Tatakinov",
  },
  {
    passthrough = true,
    id  = "craftmanw",
    content = "タタキノフ",
  },
  {
    passthrough = true,
    id  = "name",
    content = "Kagari_Kotori",
  },
  -- ここまで
}
