include atcoder/header
import atcoder/extra/other/compress
import atcoder/extra/algorithm/coordinate_compression

var c = initCompress[int](@[9, 2, 9], @[4, 2])
let cc = initCoordinateCompression([9, 2, 9, 4, 2])
doAssert c == @[2, 4, 9]
doAssert c == cc.values
doAssert c{4} == cc.encode(4)
c.add -1
c.build()
doAssert c == @[-1, 2, 4, 9]
echo "COMPRESS_HEADER_COMPATIBILITY_OK"
