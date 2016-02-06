---
-- このLuaスクリプト(dump_sample.lua) に関してなんら責任を負いません.
-- このLuaスクリプト(dump_sample.lua) は、改変・再配布も含めご自由に.
-- @author ss

---
-- データをダンプし、ダンプした文字列を返す.
-- (循環参照を持つテーブルには対応していない)
-- @parma data            ダンプするデータ
-- @parma deep            テーブルのテーブルもダンプするかどうか
-- @parma multiline_style 文字列のフォーマットを複数行スタイルにするかどうか
-- @return                ダンプした文字列

module( "dump_sample", package.seeall )

function dump_data(data, deep, multiline_style)
  local INDENT_STR = "    "

  if (type(data) ~= "table") then
    return tostring(data)
  end

  local dump_table

  if (not multiline_style) then
    dump_table = function(t, deep)
      local str = "{"

      if (deep) then
        for k, v in pairs(t) do
          if (type(v) == "table") then
            str = string.format("%s%s = %s, ",
                                str, tostring(k), dump_table(v, true))
          elseif (type(v) == "string") then
            str = string.format("%s%s = %q, ", str, tostring(k), v)
          else
            str = string.format("%s%s = %s, ", str, tostring(k), tostring(v))
          end
        end
      else
        for k, v in pairs(t) do
          if (type(v) == "string") then
            str = string.format("%s%s = %q, ", str, tostring(k), v)
          else
            str = string.format("%s%s = %s, ", str, tostring(k), tostring(v))
          end
        end
      end

      str = str .. "}"

      return str
    end
  else
    dump_table = function(t, deep, indent)
      local str = "{\n"

      if (deep) then
        for k, v in pairs(t) do
          if (type(v) == "table") then
            str = string.format("%s%s%s%s = %s,\n",
              str, indent, INDENT_STR, tostring(k),
              dump_table(v, true, indent .. INDENT_STR))
          elseif (type(v) == "string") then
            str = string.format("%s%s%s%s = %q,\n",
                                str, indent, INDENT_STR, tostring(k), v)
          else
            str = string.format("%s%s%s%s = %s,\n",
                                str, indent, INDENT_STR, tostring(k), tostring(v))
          end
        end
      else
        for k, v in pairs(t) do
          if (type(v) == "string") then
            str = string.format("%s%s%s%s = %q,\n",
                                str, indent, INDENT_STR, tostring(k), v)
          else
            str = string.format("%s%s%s%s = %s,\n",
                                str, indent, INDENT_STR, tostring(k), tostring(v))
          end
        end
      end

      str = str .. indent .. "}"

      return str
    end
  end

  return dump_table(data, deep, "")
end


------------------------------------------------------------

-- テストデータ
t    = { n1 = 10, n2 = 20, n3 = 30  }
t.a1 = { "a", "b", "c", {9, 8, 7} }
t.t1 = { str = "s", f = function() print "xx"; end }

-- テーブルのテーブルは、ダンプしない場合
print( dump_data(t) )

-- テーブルのテーブルも、ダンプする場合
print( dump_data(t, true, true) )

-- いちおう、どんなデータを渡しても平気なはず
print( dump_data(nil) )
print( dump_data(true) )
print( dump_data(t.n1) )
