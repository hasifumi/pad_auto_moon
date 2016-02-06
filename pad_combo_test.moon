pad_combo = require "pad_combo"

p_cmb = pad_combo.PadCombo 5, 4, "rrrrrbbbbbgggggccccc"
print "cols:", p_cmb.cols
print "idx2xy:", p_cmb\idx2xy 10
print "str2lst:", p_cmb\str2lst(p_cmb.board)
