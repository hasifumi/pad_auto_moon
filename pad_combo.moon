-- vim: foldmethod=marker :
module "pad_combo", package.seeall
export *

moon = require "moon"

class PadCombo
	new: (@cols, @rows, @board) =>-- {{{
		@combo = {}
		@combo_count = 0
		@combo_seq = {}
		@combo_color_count = {}  -- not cure drop color
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
					table.insert(ary_b, @xy2idx(col - 1, row))
				if col + 1 < @cols
					table.insert(ary_b, @xy2idx(col + 1, row))
				if 1 <= row - 1
					table.insert(ary_b, @xy2idx(col, row - 1))
				if row + 1 < @rows
					table.insert(ary_b, @xy2idx(col, row + 1))
			    table.insert(ary, ary_b)
		return ary
	    -- }}}

	make_renketsu: (vector) =>-- {{{
		ary = {}
		for row = 1, @rows
			for col = 1, @cols
				ary_b = {}
				if vector == "h"  -- horizon-- {{{
					if (col + 2) <= @cols
						table.insert(ary_b, @xy2idx(col, row))
						table.insert(ary_b, @xy2idx(col+1, row))
						table.insert(ary_b, @xy2idx(col+2, row))
						table.insert(ary, ary_b)
					else
						table.insert(ary, ary_b)-- }}}
				elseif vector == "v"  -- vertical-- {{{
					if (row + 2) <= @rows
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

	calc_combo: =>
		cmb = -1
		cmb_keys = {}
		cmb_seq = {}
		cmb_color = {}
		cmb_color_count = 0
		cmb_cure_count = 0
		for k, v in pairs(@combo)
			if




print "loaded pad_combo module"

    -- def calc_combo(self):# {{{
    --     cmb = -1
    --     cmb_keys = {}
    --     cmb_seq = {}
    --     cmb_color = {}
    --     cmb_color_count = 0  # cure以外の属性（色）カウンタ　（例：3色）
    --     cmb_cure_count = 0
    --     for k, v in self.combo.iteritems():
    --         if k in cmb_keys:
    --             cmb_keys[k] += 1
    --         else:
    --             cmb_keys[k] = 1
    --         if cmb < v['combo_seq']:
    --             cmb += 1
    --             cmb_seq[cmb] = {
    --                     'first_find_seq': k,
    --                     'color': v['color'],
    --                     'vector': v['vector'],
    --                     'count': 1,
    --                     }
    --             if v['color'] in cmb_color:
    --                 cmb_color[v['color']] += 1
    --             else:
    --                 cmb_color[v['color']] = 1
    --                 if v['color'] == 'c':
    --                     cmb_cure_count += 1
    --                 else:
    --                     cmb_color_count += 1
    --         for k2, v2 in self.combo.iteritems():
    --             if k2 in cmb_keys:
    --                 pass
    --             else:
    --                 if v['color'] == v2['color']:   # 同色か？
    --                     # vの各ドロップの近接リストにcmb2の各ドロップがいるか？
    --                     if self.isKinsetsu(v['start_x_pos'], v['start_y_pos'], v['vector'], v2['start_x_pos'], v2['start_y_pos'], v2['vector']):
    --                         v['combo_seq'] = cmb
    --                         v2['combo_seq'] = cmb
    --                         cmb_seq[cmb]['count'] += 1
    --     self.combo_count = cmb + 1
    --     self.combo_seq = cmb_seq
    --     self.combo_color = cmb_color
    --     self.combo_color_count = cmb_color_count
    --     self.combo_cure_count = cmb_cure_count
    --     return
    --     # }}}
    --
    -- def calc_score(self, pad_score_parms):# {{{
    --     score = 0
    --     PARMS = pad_score_parms.score_parms
    --
    --     # コンボ優先
    --     score += self.combo_count * 100
    --
    --     # 属性優先（色優先）
    --     for k, v in self.combo_color.iteritems():# {{{
    --         if   k == "r":
    --             if PARMS.has_key('red'):
    --                 score += PARMS['red'] * 100
    --         elif k == "b":
    --             if PARMS.has_key('blue'):
    --                 score += PARMS['blue'] * 100
    --         elif k == "g":
    --             if PARMS.has_key('green'):
    --                 score += PARMS['green'] * 100
    --         elif k == "l":
    --             if PARMS.has_key('light'):
    --                 score += PARMS['light'] * 100
    --         elif k == "d":
    --             if PARMS.has_key('dark'):
    --                 score += PARMS['dark'] * 100
    --         elif k == "c":
    --             if PARMS.has_key('cure'):
    --                 score += PARMS['cure'] * 100# }}}
    --
    --     # 多色
    --     if self.combo_color_count >= 3 and PARMS.has_key('3colors'): # {{{
    --         score += PARMS['3colors'] * 1000
    --     if self.combo_color_count >= 3 and self.combo_cure_count >= 1 and PARMS.has_key('3colors+cure'):
    --         score += PARMS['3colors+cure'] * 1000
    --     if self.combo_color_count >= 4 and PARMS.has_key('4colors'):
    --         score += PARMS['4colors'] * 1000
    --     if self.combo_color_count >= 4 and self.combo_cure_count >= 1 and PARMS.has_key('4colors+cure'):
    --         score += PARMS['4colors+cure'] * 1000
    --     if self.combo_color_count >= 5 and PARMS.has_key('5colors'):
    --         score += PARMS['5colors'] * 1000
    --     if self.combo_color_count >= 5 and self.combo_cure_count >= 1 and PARMS.has_key('5colors+cure'):
    --         score += PARMS['5colors+cure'] * 1000# }}}
    --
    --     # 列優先
    --     color = self.chk_1LineColor()# {{{
    --     for k, v in color.iteritems():
    --         if   v == 'r' and PARMS.has_key('1line-red'):
    --             score += PARMS['1line-red']  * 10000
    --         elif v == 'b' and PARMS.has_key('1line-blue'):
    --             score += PARMS['1line-blue'] * 10000
    --         elif v == 'g' and PARMS.has_key('1line-green'):
    --             score += PARMS['1line-green'] * 10000
    --         elif v == 'l' and PARMS.has_key('1line-light'):
    --             score += PARMS['1line-light'] * 10000
    --         elif v == 'd' and PARMS.has_key('1line-dark'):
    --             score += PARMS['1line-dark'] * 10000
    --         elif v == 'c' and PARMS.has_key('1line-cure'):
    --             score += PARMS['1line-cure'] * 10000# }}}
    --
    --     # 4つ消し、5つ消し
    --     drops4 = self.chk_drops4()
    --     drops5 = self.chk_drops5()
    --
    --     for k, v in drops4.iteritems(): # {{{
    --         if   k == 'r' and PARMS.has_key('4drops-red'):
    --             score += PARMS['4drops-red'] * 5000
    --             if drops5.has_key(k):
    --                 score += PARMS['4drops-red'] * 5000 * -1     # 罰
    --         elif k == 'b' and PARMS.has_key('4drops-blue'):
    --             score += PARMS['4drops-blue'] * 5000
    --             if drops5.has_key(k):
    --                 score += PARMS['4drops-blue'] * 5000 * -1    # 罰
    --         elif k == 'g' and PARMS.has_key('4drops-green'):
    --             score += PARMS['4drops-green'] * 5000
    --             if drops5.has_key(k):
    --                 score += PARMS['4drops-green'] * 5000 * -1    # 罰
    --         elif k == 'l' and PARMS.has_key('4drops-light'):
    --             score += PARMS['4drops-light'] * 5000
    --             if drops5.has_key(k):
    --                 score += PARMS['4drops-light'] * 5000 * -1    # 罰
    --         elif k == 'd' and PARMS.has_key('4drops-dark'):
    --             score += PARMS['4drops-dark'] * 5000
    --             if drops5.has_key(k):
    --                 score += PARMS['4drops-dark'] * 5000 * -1    # 罰
    --         elif k == 'c' and PARMS.has_key('4drops-cure'):
    --             score += PARMS['4drops-cure'] * 5000
    --             if drops5.has_key(k):
    --                 score += PARMS['4drops-cure'] * 5000 * -1    # 罰
    --     return (score, self.combo_count)# }}}
    --
    --     for k, v in drops5.iteritems():# {{{
    --         if   k == 'r' and PARMS.has_key('5drops-red'):
    --             score += PARMS['5drops-red'] * 5000
    --             if drops4.has_key(k):
    --                 score += PARMS['5drops-red'] * 5000 * -1     # 罰
    --         elif k == 'b' and PARMS.has_key('5drops-blue'):
    --             score += PARMS['5drops-blue'] * 5000
    --             if drops4.has_key(k):
    --                 score += PARMS['5drops-blue'] * 5000 * -1    # 罰
    --         elif k == 'g' and PARMS.has_key('5drops-green'):
    --             score += PARMS['5drops-green'] * 5000
    --             if drops4.has_key(k):
    --                 score += PARMS['5drops-green'] * 5000 * -1    # 罰
    --         elif k == 'l' and PARMS.has_key('5drops-light'):
    --             score += PARMS['5drops-light'] * 5000
    --             if drops4.has_key(k):
    --                 score += PARMS['5drops-light'] * 5000 * -1    # 罰
    --         elif k == 'd' and PARMS.has_key('5drops-dark'):
    --             score += PARMS['5drops-dark'] * 5000
    --             if drops4.has_key(k):
    --                 score += PARMS['5drops-dark'] * 5000 * -1    # 罰
    --         elif k == 'c' and PARMS.has_key('5drops-cure'):
    --             score += PARMS['5drops-cure'] * 5000
    --             if drops4.has_key(k):
    --                 score += PARMS['5drops-cure'] * 5000 * -1    # 罰# }}}
    --
    --     self.score = score
    --
    --     return (self.score, self.combo_count)# }}}
    --
    -- def chk_1LineColor(self):# {{{
    --     color = {}
    --     for y in range(self.rows):
    --         for x in range(self.cols):
    --             if color.has_key(y):
    --                 if color[y] != self.board[self.xy2idx(x, y)]:
    --                     color[y] = ""
    --                     break
    --             else:
    --                 color[y] = self.board[self.xy2idx(x, y)]
    --     return  color# }}}
    --
    -- def chk_drops4(self):# {{{
    --     drops4 = {}
    --     for k, v in self.combo_seq.iteritems():
    --         if v['count'] == 2:
    --             if v['color'] in drops4:
    --                 drops4[v['color']] += 1
    --             else:
    --                 drops4[v['color']] = 1
    --     return drops4# }}}
    --
    -- def chk_drops5(self):# {{{
    --     drops5 = {}
    --     for k, v in self.combo_seq.iteritems():
    --         if v['count'] == 4:   # why "count:4" is drop5?
    --             if v['color'] in drops5:
    --                 drops5[v['color']] += 1
    --             else:
    --                 drops5[v['color']] = 1
    --     return drops5# }}}
    --
    -- def chk_drops_color(self):# {{{
    --     drops_color = {}
    --     for d in self.board:
    --         if d in drops_color:
    --             drops_color[d] += 1
    --         else:
    --             drops_color[d] = 1
    --     return drops_color# }}}
