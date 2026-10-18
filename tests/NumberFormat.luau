local N = require('../src/modules/NumberFormat')
local cases = {
 {0,'0'}, {999,'999'}, {1000,'1k'}, {1500,'1.5k'}, {500000,'500k'},
 {1000000,'1m'}, {1250000,'1.25m'}, {1e9,'1b'}, {1e12,'1t'},
 {1e15,'1qa'}, {1e18,'1qi'}, {1e21,'1sx'}, {1e24,'1sp'}, {1e27,'1oc'}, {1e30,'1no'}, {1e33,'1dc'},
 {-500000,'-500k'}, {999999,'1m'}, {999994,'999.99k'}, {1e36,'1.00e+36'},
}
for _, c in ipairs(cases) do assert(N.Format(c[1]) == c[2], tostring(c[1])..': '..N.Format(c[1])) end
assert(N.Format(500000,{Compact=false}) == '500000')
assert(N.Format(1250000,{Decimals=1}) == '1.3m')
assert(N.Format(999999,{Decimals=0}) == '1m')
assert(N.Format(0/0) == '—')
for _, s in ipairs({'500000','500k',' 500K ','0.5m','5e5'}) do assert(N.Parse(s) == 500000,s) end
for _, s in ipairs({'inf','nan','bad','1kk','1e999'}) do assert(N.Parse(s) == nil,s) end
assert(N.Snap(1,0,1,0.3)==1)
assert(math.abs(N.Snap(.12345,0,1,.00001)-.12345)<1e-12)
assert(N.Ratio(5,5,5)==1)
assert(N.Snap(0/0,0,1,1)==nil)
assert(N.Snap(10,0,10,3)==10)
assert(N.Snap(2.4,1,10,2)==3)
print('PASS NumberFormat: '..#cases..' display cases + parsing, bounds, fractional precision')
