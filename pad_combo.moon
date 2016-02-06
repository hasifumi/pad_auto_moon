-- vim: foldmethod=marker :
module "pad_combo", package.seeall
export *

class PadCombo
	new: (@cols, @rows, @board) =>-- {{{
		@combo = {}
		@combo_count = 0
		@combo_seq = {}
		@combo_color_count = {}  # not cure drop color
		@combo_cure_count = {}
		@score = 0
		@adjacent = @make_adjacent!
		@renketsu_h = @make_renketsu("h")
		@renketsu_v = @make_renketsu("v")
		-- }}}

	-- Caution! Not Zero origin
    xy2idx: (x, y) =>-- {{{
		return (y - 1) * @cols + x
	-- }}}

	idx2x: (idx) =>-- {{{
		x = idx % @cols
		if x == 0
			x = @cols
		return x
	-- }}}

	idx2y: (idx) =>-- {{{
		y = idx / @cols
		if (idx % @cols) != 0
			y = (idx - (idx % @cols)) / @cols + 1
		return y
	-- }}}

	idx2xy: (idx) =>-- {{{
		return @idx2x(idx), @idx2y(idx)
	-- }}}

	str2lst:(str) =>-- {{{
		ret = [ [0 for col = 1, @cols] for row = 1, @rows]
		if #str == @cols * @rows
			i = 0
			for row = 1, @rows
				for col = 1, @cols
					ret[row][col] = str[i]
					i += 1
			return ret
		-- }}}

	lst2str: (lst) =>-- {{{
		ret =""
		for row = 1, @rows
			for col = 1, @cols
				ret = ret..lst[row][col]
		return ret
	-- }}}

	make_adjacent: =>-- {{{
		ary = {}
		for row = 1, @rows
			for col = 1, @cols
				ary_b = {}
				if 1 <= col - 1
					table.insert(ary_b, xy2idx(col - 1, row))
				if col + 1 < @cols
					table.insert(ary_b, xy2idx(col + 1, row))
				if 1 <= row - 1
					table.insert(ary_b, xy2idx(col, row - 1))
				if row + 1 < @rows
					table.insert(ary_b, xy2idx(col, row + 1))
			table.insert(ary, ary_b)
		return ary
	    -- }}}

	make_renketsu: (vector) =>-- {{{
		ary = {}
		for row = 1, @rows
			for col = 1, @cols
				ary_b = {}
				if vector == "h"  -- horizon-- {{{
					if col + 2 =< @cols
						table.insert(ary_b, @xy2idx(col, row))
						table.insert(ary_b, @xy2idx(col+1, row))
						table.insert(ary_b, @xy2idx(col+2, row))
						table.insert(ary, ary_b)
					else
						table.insert(ary, ary_b)-- }}}
				elseif vector == "v"  -- vertical-- {{{
					if row + 2 =< @rows
						table.insert(ary_b, @xy2idx(col, row))
						table.insert(ary_b, @xy2idx(col, row+1))
						table.insert(ary_b, @xy2idx(col, row+2))
						table.insert(ary, ary_b)
					else
						table.insert(ary, ary_b)-- }}}
		return ary
	    -- }}}

	isRenketsu: (col, row, vector="h") =>-- {{{
		if vector == "h"  -- horizon-- {{{
			idx   = @xy2idx(col, row)
			idx_1 = @xy2idx(col+1, row)
			idx_2 = @xy2idx(col+2, row)
			substr   = strring.sub(@board, idx, 1)
			substr_1 = strring.sub(@board, idx_1, 1)
			substr_2 = strring.sub(@board, idx_2, 1)
			if (substr == substr_1) and (substr_1 == substr_2)
				return True
			else
				return False-- }}}
		elseif vector == "v"  -- vertical-- {{{
			idx   = @xy2idx(col, row)
			idx_1 = @xy2idx(col, row+1)
			idx_2 = @xy2idx(col, row+2)
			substr   = strring.sub(@board, idx, 1)
			substr_1 = strring.sub(@board, idx_1, 1)
			substr_2 = strring.sub(@board, idx_2, 1)
			if (substr == substr_1) and (substr_1 == substr_2)
				return True
			else
				return False-- }}}
		-- }}}

	check_erasable: =>-- {{{
		ers = 0
		for row = 1, @rows
			for col = 1, @cols
				if @isRenketsu(col, row, "h") == True-- {{{
					ary_b =
						start_x_pos: col,
						start_y_pos: row,
						vector: "h",
						color: @board[@xy2idx(col, row)],
						combo_seq: ers
					table.insert(@combo, ary_b)
					ers += 1-- }}}
				if @isRenketsu(col, row, "v") == True-- {{{
					ary_b =
						start_x_pos: col,
						start_y_pos: row,
						vector: "h",
						color: @board[@xy2idx(col, row)],
						combo_seq: ers
					table.insert(@combo, ary_b)
					ers += 1-- }}}
		-- }}}

    isKinsetsu: (x1, y1, v1, x2, y2, v2) =>-- {{{
		idx1 = @xy2idx(x1, y1)
		idx2 = @xy2idx(x2, y2)
		if v1 == "h"-- {{{
			for i, value in ipairs(@renketsu_h[idx1])
				for j, value2 in ipairs(@adjacent[i])
					if v2 == "h"
						for i2, value3 in ipairs(@renketsu_h[idx2])
							if value2 == value3
								return True
					elseif v2 == "v"
						for i2, value3 in ipairs(@renketsu_v[idx2])
							if value2 == value3
								return True-- }}}
		elseif v2 == "v"-- {{{
			for i, value in ipairs(@renketsu_v[idx1])
				for j, value2 in ipairs(@adjacent[i])
					if v2 == "h"
						for i2, value3 in ipairs(@renketsu_h[idx2])
							if value2 == value3
								return True
					elseif v2 == "v"
						for i2, value3 in ipairs(@renketsu_v[idx2])
							if value2 == value3
								return True-- }}}
		return False
		-- }}}



print "loaded pad_combo module"
p_cmb_1 = PadCombo 3, 2, "rrrggg"
print #p_cmb_1.board
local lst = p_cmb_1\str2lst(p_cmb_1.board)
print p_cmb_1\lst2str lst
-- print p_cmb.rows

