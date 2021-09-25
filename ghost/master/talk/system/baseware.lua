local SS  = require("sakura_script")
local StringBuffer  = require("string_buffer")


-- 1ファイル全体でよく使う関数はこの辺りで定義しておく
local function getMouseID(ref)
  local p = ref[3]
  local collision = ref[4]
  local button  = tonumber(ref[5]) or -1
  local n2str = {
    [0] = "Left",
    [1] = "Right",
    [2] = "Middle",
  }
  local id  = StringBuffer()
  if p then
    id:append(p)
  end
  if collision then
    id:append(collision)
  end
  if n2str[button] then
    id:append(n2str[button])
  end
  if id:strlen() > 0 then
    return id:tostring()
  end
  return nil
end

return {
  {
    id      = "OnCommunicate",
    content = function(shiori, ref)
      if ref[0] == "user" and ref[1] ~= nil then
        return shiori:talk(ref[1] .. "_communicate")
      end
    end,
  },
  {
    id      = "OnUserInput",
    content = function(shiori, ref)
      return shiori:talk(ref[0] .. "の入力", ref[1])
    end,
  },
  {
    id      = "OnSystemDialogCancel",
    content = function(shiori, ref)
      return SS():raise(ref[1], "cancel", nil, nil, ref[0])
    end,
  },
  {
    id      = "OnChoiceSelect",
    content = function(shiori, ref)
      return shiori:talk(ref[0], ref)
    end,
  },
  {
    id      = "OnAnchorSelect",
    content = function(shiori, ref)
      return shiori:talk(ref[0], ref)
    end,
  },
  {
    id      = "OnMouseClick",
    content = function(shiori, ref)
      local id  = getMouseID(ref)
      if id then
        return shiori:talk(id, ref)
      end
    end,
  },
  {
    id      = "OnMouseDoubleClick",
    content = function(shiori, ref)
      ref[5]  = nil -- 左クリック以外でダブルクリックする機会はなさそうなので。
      local id  = getMouseID(ref)
      if id then
        -- つつき反応
        return shiori:talk(id .. "Poke", ref)
      end
    end,
  },
  {
    id      = "OnMouseMove",
    content = function(shiori, ref)
      local __  = shiori.var
      local p = ref[3] or ""
      local c = ref[4] or ""
      local prev  = __("_PrevNadeCollision")
      local count = __("_NadeCount") or 0
      local current = p .. c
      __("_PrevNadeCollision", current)
      if prev == current then
        count = count + 1
        __("_NadeCount", count)
      else
        __("_NadeCount", 0)
      end
      -- 適当に30フレームとしているが
      -- 必要に応じて変えるべし
      if #current > 0 and (count + 1) % 30 == 0 then
        return shiori:talk("OnMouseNade", p, c, count)
      end
    end,
  },
  {
    id  = "OnMouseNade",
    content = function(shiori, ref)
      local p = ref[0] or ""
      local c = ref[1] or ""
      local n = tonumber(ref[2]) or 0
      print(p .. c .. "Nade" .. n)
      return shiori:talk(p .. c .. "なで")
    end,
  },
}

