class           -- なんかClassっぽいものを作りたいときに。

local Class = require("class")
local M = Class()
M.__index = M
function M:foo()
end

return M


conv            -- 文字コード変換を司る。今のところShift_JISとUTF-8のみ。

local Conv  = require("conv")
local utf8_str  = Conv.conv(sjis_str, "UTF-8", "Shift_JIS")


fh              -- 内部的に使用。file descriptorをblockingしないようにする。
lua-utf8.dll    -- lua5.3以降に実装されたutf8より高機能なので入れてある。
luachild.dll    -- プロセス起動とかいろいろやってる凄いやつ。


lanes           -- マルチスレッドが使えるようになる。(ただし制限付き)
                -- 詳細はhttps://lualanes.github.io/lanes/を参照のこと。

path            -- パス操作を司る。

local Path  = require("path")
Path.dirWalk("C:\\", function(path)
  local fh  = io.open(path, "r")
  ...
  fh:close()
end)


process         -- プロセスとの相互通信が出来るやつ。
                -- os.executeやio.popenなども参照のこと。

local Process = require("process")
local process = Process({
  command = "cmd.exe"
})
process:spawn("arg1", "arg2", "arg3")
process:writeline("Test")
local str = process:readline(true)
process:despawn()
end

sakura_script   -- さくらスクリプトをメソッドチェーンで書けるやつ。
                -- 作者が使ったものだけ対応している。
                -- スクリプトのsyntax errorが発生するので
                -- デバッグが多少楽になるかも…？

--この2つは同等
local SS      = require("sakura_script")
local script  = SS():p(0):s(9)("おはよう"):n():s(5)("今日も良い天気だね！"):tostring()
local script  = "\\p[0]\\s[9]おはよう\\n\\s[5]今日も良い天気だね！"

saori_basic     -- 
saori_caller    -- この辺は直接呼ことはないと思うので省略。
saori_universal -- 

socket          -- tcp/udpの通信を行える。
                -- 詳しくはhttps://w3.impa.br/~diego/software/luasocket/home.html
                -- を参照のこと。


sstp            -- ukagaka_miscへ機能を移動した。


string_buffer   -- 文字列連結演算子を大量に行うと処理が滞るので対処したやつ。
                -- よっぽど文字列連結を行うんでもなければ必要ない。

local StringBuffer  = require("string_buffer")

local str = StringBuffer()
str:append("いろは")
str:append("にほへと"):append("ちり")
str:append("ぬるを")
print(str:tostring()) -- "いろはにほへとちりぬるを"


trie            -- 自動アンカーの処理で使う。trie木みたいな何か。


ukagaka_misc    -- SSTPのやりとりやFMOの取得などを扱う。
                -- UNIQUE IDにはbasewareから送られてきたものを代入すること。
                -- 参考URL http://ssp.shillest.net/ukadoc/manual/list_shiori_event.html#uniqueid

local Misc  = require("sstp")
Misc.speak("UNIQUE ID", "\\0\\s[0]テスト")
Misc.speak(shiori.var("_uniqueid"), "\\0\\s[0]テスト")
Misc.sendSSTP("UNIQUE ID", "NOTIFY SSTP/1.0\r\nCharset: Shift_JIS\r\nEvent: OnBoot\r\n\r\n")
Misc.sendSSTP(shiori.var("_uniqueid"), "NOTIFY SSTP/1.0\r\nCharset: Shift_JIS\r\nEvent: OnBoot\r\n\r\n")
local fmo = Misc.getFMO("SakuraUnicode")

ukagaka_module  -- SSTPな文字列生成などに使う。
