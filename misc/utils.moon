-- vim: foldmethod=marker :
module "...", package.seeall
export *

moon = require "moon"

class Table
	new: ->

	is_empty: (tbl) =>-- {{{
		if tbl == nil
			return true
		return not next tbl
	-- }}}

	has_key: (tbl, key) =>-- {{{
		for k, v in pairs tbl
			if k == key
				return true
		return false
	    -- }}}

	keys: (tbl) =>-- {{{
		ary = {}
		for i, v in pairs tbl
			table.insert ary, i
		return ary
	-- }}}

	values: (tbl) =>-- {{{
		ary = {}
		for i,v in pairs tbl
			table.insert ary, v
		return ary
	    -- }}}

	unique: (tbl) =>-- {{{
		check = {}
		res = {}
		for i, v in pairs tbl
			if not check[v]
				check[v] = true
				res[1+#res] = v

		-- for k, v in pairs tbl
		-- 	if not (type(k) == "number" and k%1==0)
		-- 		res[k] = v

		return res
	    -- }}}

	map: (tbl, func) =>-- {{{
		ret_tbl = {}
		for k, v in pairs tbl
			ret_tbl[k] = func(k, v)
		return ret_tbl
	    -- }}}

	filter: (tbl, func) =>-- {{{
		res = {}
		for i, v in ipairs tbl
			if func(i, v)
				res[1+#res] = v

		for k, v in pairs tbl
			if func(k, v)
				if not(type(k) == "number" and k%1==0)
					res[k] = v

		return res
	    -- }}}

tbl = Table

t_empty = {}
t =
	t1: "11"
	t2: "12"
	t3: "11"

t_num = {1,2,3, 4, 2, 1}
old_tbl = {1, 10, 30, a:20, b:30}

moon.p tbl\is_empty t_empty
moon.p tbl\is_empty t
moon.p tbl\has_key t, "t1"
moon.p tbl\has_key t, "t4"
moon.p tbl\keys t
moon.p tbl\values t
moon.p tbl\unique t_num
moon.p tbl\unique t

func = (k, v) ->
	return v*v

t_2 = tbl\map( old_tbl, func)
moon.p t_2

func2 = (k, v) ->
	return v < 21

t_3 = tbl\filter old_tbl, func2
moon.p t_3
