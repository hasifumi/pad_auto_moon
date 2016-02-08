moon = require "moon"

t =
	t1: "t1",
	t2: "t2",
	t3:
		t3_1: "t3_1",
		t3_2: "t3_2"
		t3_3:
			t3_3_1: "t3_3_1",
			t3_3_2: "t3_3_2"

moon.p t
