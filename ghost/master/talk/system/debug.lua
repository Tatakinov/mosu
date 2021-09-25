local StringBuffer  = require("string_buffer")

return {
  {
    id      = "OnKeyPress",
    content = function(shiori, ref)
      return shiori:talk(ref[0] .. "_Key", ref)
    end,
  },
  {
    -- Rキーが押されたときの処理
    id  = "r_Key",
    content = [[
\![reload,shiori]
]],
  },
  {
    -- Dキーが押されたときの処理
    id  = "d_Key",
    content = function(shiori, ref)
      local __  = shiori.var
      local str = StringBuffer()
      -- "_DictError" は辞書のエラー情報が格納されている特殊な変数
      local dict_error  = __("_DictError")
      for _, v in ipairs(dict_error) do
        str:append([[\_?]]):append(v):append([[\_?\n]])
      end
      if str:strlen() > 0 then
        str:prepend([[\0]])
        return str
      end
      return [[\0辞書エラーなし。]]
    end,
  },
}
