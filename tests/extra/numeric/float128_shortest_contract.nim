import atcoder/extra/numeric/float128

type
  F128ShortestContractVector = object
    high: uint64
    low: uint64
    expectedText: string
    nanCanonicalization: bool
    expectedCrossDecade: bool

const
  f128ShortestContractVectors: array[262, F128ShortestContractVector] = [
    F128ShortestContractVector(high: 0x0000000000000000'u64, low: 0x0000000000000000'u64, expectedText: "0", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8000000000000000'u64, low: 0x0000000000000000'u64, expectedText: "-0", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x7fff000000000000'u64, low: 0x0000000000000000'u64, expectedText: "inf", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xffff000000000000'u64, low: 0x0000000000000000'u64, expectedText: "-inf", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x7fff800000000000'u64, low: 0x0000000000000000'u64, expectedText: "nan", nanCanonicalization: true, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xffff800000000000'u64, low: 0x0000000000000000'u64, expectedText: "-nan", nanCanonicalization: true, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x7fff000000000000'u64, low: 0x0000000000000001'u64, expectedText: "nan", nanCanonicalization: true, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xffff000000000000'u64, low: 0x0000000000000001'u64, expectedText: "-nan", nanCanonicalization: true, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0000000000000000'u64, low: 0x0000000000000001'u64, expectedText: "6e-4966", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8000000000000000'u64, low: 0x0000000000000001'u64, expectedText: "-6e-4966", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0000000000000000'u64, low: 0x0000000000000002'u64, expectedText: "1e-4965", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8000000000000000'u64, low: 0x0000000000000002'u64, expectedText: "-1e-4965", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0000000000000000'u64, low: 0x0000000000000003'u64, expectedText: "2e-4965", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8000000000000000'u64, low: 0x0000000000000003'u64, expectedText: "-2e-4965", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0000ffffffffffff'u64, low: 0xfffffffffffffffe'u64, expectedText: "3.362103143112093506262677817321751e-4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8000ffffffffffff'u64, low: 0xfffffffffffffffe'u64, expectedText: "-3.362103143112093506262677817321751e-4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0000ffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "3.362103143112093506262677817321752e-4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8000ffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "-3.362103143112093506262677817321752e-4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0001000000000000'u64, low: 0x0000000000000000'u64, expectedText: "3.3621031431120935062626778173217526e-4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8001000000000000'u64, low: 0x0000000000000000'u64, expectedText: "-3.3621031431120935062626778173217526e-4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0001000000000000'u64, low: 0x0000000000000001'u64, expectedText: "3.362103143112093506262677817321753e-4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8001000000000000'u64, low: 0x0000000000000001'u64, expectedText: "-3.362103143112093506262677817321753e-4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3ffeffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "0.9999999999999999999999999999999999", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xbffeffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "-0.9999999999999999999999999999999999", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3fff000000000000'u64, low: 0x0000000000000000'u64, expectedText: "1", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xbfff000000000000'u64, low: 0x0000000000000000'u64, expectedText: "-1", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3fff000000000000'u64, low: 0x0000000000000001'u64, expectedText: "1.0000000000000000000000000000000002", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xbfff000000000000'u64, low: 0x0000000000000001'u64, expectedText: "-1.0000000000000000000000000000000002", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x7ffeffffffffffff'u64, low: 0xfffffffffffffffe'u64, expectedText: "1.1897314953572317650857593266280069e4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xfffeffffffffffff'u64, low: 0xfffffffffffffffe'u64, expectedText: "-1.1897314953572317650857593266280069e4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x7ffeffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "1.189731495357231765085759326628007e4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xfffeffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "-1.189731495357231765085759326628007e4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x016ffa953875c78e'u64, low: 0x49f1182a501f6c43'u64, expectedText: "1.0000000000000000000000000000000002e-4821", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x816ffa953875c78e'u64, low: 0x49f1182a501f6c43'u64, expectedText: "-1.0000000000000000000000000000000002e-4821", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x016ffa953875c78e'u64, low: 0x49f1182a501f6c44'u64, expectedText: "1.00000000000000000000000000000000025e-4821", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x816ffa953875c78e'u64, low: 0x49f1182a501f6c44'u64, expectedText: "-1.00000000000000000000000000000000025e-4821", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x016ffa953875c78e'u64, low: 0x49f1182a501f6c45'u64, expectedText: "1.0000000000000000000000000000000003e-4821", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x816ffa953875c78e'u64, low: 0x49f1182a501f6c45'u64, expectedText: "-1.0000000000000000000000000000000003e-4821", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0001800000000000'u64, low: 0x0000000000000000'u64, expectedText: "5.043154714668140259394016725982629e-4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8001800000000000'u64, low: 0x0000000000000000'u64, expectedText: "-5.043154714668140259394016725982629e-4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0001ffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "6.7242062862241870125253556346435046e-4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8001ffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "-6.7242062862241870125253556346435046e-4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0002000000000000'u64, low: 0x0000000000000000'u64, expectedText: "6.724206286224187012525355634643505e-4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8002000000000000'u64, low: 0x0000000000000000'u64, expectedText: "-6.724206286224187012525355634643505e-4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0002000000000000'u64, low: 0x0000000000000001'u64, expectedText: "6.724206286224187012525355634643507e-4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8002000000000000'u64, low: 0x0000000000000001'u64, expectedText: "-6.724206286224187012525355634643507e-4932", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0002800000000000'u64, low: 0x0000000000000000'u64, expectedText: "1.0086309429336280518788033451965258e-4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8002800000000000'u64, low: 0x0000000000000000'u64, expectedText: "-1.0086309429336280518788033451965258e-4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0002ffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "1.3448412572448374025050711269287009e-4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8002ffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "-1.3448412572448374025050711269287009e-4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x000a000000000000'u64, low: 0x0000000000000000'u64, expectedText: "1.7213968092733918752064910424687373e-4929", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x800a000000000000'u64, low: 0x0000000000000000'u64, expectedText: "-1.7213968092733918752064910424687373e-4929", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x000a000000000000'u64, low: 0x0000000000000001'u64, expectedText: "1.7213968092733918752064910424687377e-4929", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x800a000000000000'u64, low: 0x0000000000000001'u64, expectedText: "-1.7213968092733918752064910424687377e-4929", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x000a800000000000'u64, low: 0x0000000000000000'u64, expectedText: "2.582095213910087812809736563703106e-4929", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x800a800000000000'u64, low: 0x0000000000000000'u64, expectedText: "-2.582095213910087812809736563703106e-4929", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x000affffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "3.4427936185467837504129820849374743e-4929", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x800affffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "-3.4427936185467837504129820849374743e-4929", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0064000000000000'u64, low: 0x0000000000000000'u64, expectedText: "2.130986033697630994296322538756716e-4902", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8064000000000000'u64, low: 0x0000000000000000'u64, expectedText: "-2.130986033697630994296322538756716e-4902", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0064000000000000'u64, low: 0x0000000000000001'u64, expectedText: "2.1309860336976309942963225387567165e-4902", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8064000000000000'u64, low: 0x0000000000000001'u64, expectedText: "-2.1309860336976309942963225387567165e-4902", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0064800000000000'u64, low: 0x0000000000000000'u64, expectedText: "3.196479050546446491444483808135074e-4902", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8064800000000000'u64, low: 0x0000000000000000'u64, expectedText: "-3.196479050546446491444483808135074e-4902", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0064ffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "4.2619720673952619885926450775134317e-4902", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8064ffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "-4.2619720673952619885926450775134317e-4902", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3ffd000000000000'u64, low: 0x0000000000000000'u64, expectedText: "0.25", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xbffd000000000000'u64, low: 0x0000000000000000'u64, expectedText: "-0.25", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3ffd000000000000'u64, low: 0x0000000000000001'u64, expectedText: "0.25000000000000000000000000000000005", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xbffd000000000000'u64, low: 0x0000000000000001'u64, expectedText: "-0.25000000000000000000000000000000005", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3ffd800000000000'u64, low: 0x0000000000000000'u64, expectedText: "0.375", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xbffd800000000000'u64, low: 0x0000000000000000'u64, expectedText: "-0.375", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3ffdffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "0.49999999999999999999999999999999995", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xbffdffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "-0.49999999999999999999999999999999995", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3ffe000000000000'u64, low: 0x0000000000000000'u64, expectedText: "0.5", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xbffe000000000000'u64, low: 0x0000000000000000'u64, expectedText: "-0.5", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3ffe000000000000'u64, low: 0x0000000000000001'u64, expectedText: "0.5000000000000000000000000000000001", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xbffe000000000000'u64, low: 0x0000000000000001'u64, expectedText: "-0.5000000000000000000000000000000001", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3ffe800000000000'u64, low: 0x0000000000000000'u64, expectedText: "0.75", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xbffe800000000000'u64, low: 0x0000000000000000'u64, expectedText: "-0.75", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3fff800000000000'u64, low: 0x0000000000000000'u64, expectedText: "1.5", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xbfff800000000000'u64, low: 0x0000000000000000'u64, expectedText: "-1.5", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3fffffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "1.9999999999999999999999999999999998", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xbfffffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "-1.9999999999999999999999999999999998", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x4000000000000000'u64, low: 0x0000000000000000'u64, expectedText: "2", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xc000000000000000'u64, low: 0x0000000000000000'u64, expectedText: "-2", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x4000000000000000'u64, low: 0x0000000000000001'u64, expectedText: "2.0000000000000000000000000000000004", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xc000000000000000'u64, low: 0x0000000000000001'u64, expectedText: "-2.0000000000000000000000000000000004", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x4000800000000000'u64, low: 0x0000000000000000'u64, expectedText: "3", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xc000800000000000'u64, low: 0x0000000000000000'u64, expectedText: "-3", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x4000ffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "3.9999999999999999999999999999999996", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xc000ffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "-3.9999999999999999999999999999999996", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x4001000000000000'u64, low: 0x0000000000000000'u64, expectedText: "4", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xc001000000000000'u64, low: 0x0000000000000000'u64, expectedText: "-4", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x4001000000000000'u64, low: 0x0000000000000001'u64, expectedText: "4.000000000000000000000000000000001", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xc001000000000000'u64, low: 0x0000000000000001'u64, expectedText: "-4.000000000000000000000000000000001", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x4001800000000000'u64, low: 0x0000000000000000'u64, expectedText: "6", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xc001800000000000'u64, low: 0x0000000000000000'u64, expectedText: "-6", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x4001ffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "7.999999999999999999999999999999999", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xc001ffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "-7.999999999999999999999999999999999", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x7ffd000000000000'u64, low: 0x0000000000000000'u64, expectedText: "2.974328738393079412714398316570018e4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xfffd000000000000'u64, low: 0x0000000000000000'u64, expectedText: "-2.974328738393079412714398316570018e4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x7ffd000000000000'u64, low: 0x0000000000000001'u64, expectedText: "2.9743287383930794127143983165700184e4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xfffd000000000000'u64, low: 0x0000000000000001'u64, expectedText: "-2.9743287383930794127143983165700184e4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x7ffd800000000000'u64, low: 0x0000000000000000'u64, expectedText: "4.461493107589619119071597474855027e4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xfffd800000000000'u64, low: 0x0000000000000000'u64, expectedText: "-4.461493107589619119071597474855027e4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x7ffdffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "5.948657476786158825428796633140035e4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xfffdffffffffffff'u64, low: 0xffffffffffffffff'u64, expectedText: "-5.948657476786158825428796633140035e4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x7ffe000000000000'u64, low: 0x0000000000000000'u64, expectedText: "5.948657476786158825428796633140036e4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xfffe000000000000'u64, low: 0x0000000000000000'u64, expectedText: "-5.948657476786158825428796633140036e4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x7ffe000000000000'u64, low: 0x0000000000000001'u64, expectedText: "5.948657476786158825428796633140037e4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xfffe000000000000'u64, low: 0x0000000000000001'u64, expectedText: "-5.948657476786158825428796633140037e4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x7ffe800000000000'u64, low: 0x0000000000000000'u64, expectedText: "8.922986215179238238143194949710053e4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xfffe800000000000'u64, low: 0x0000000000000000'u64, expectedText: "-8.922986215179238238143194949710053e4931", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xd7efedcf5733ce15'u64, low: 0x5fe90f6e60e0f281'u64, expectedText: "-9.934208653822687031176379155435662e1844", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x36e8c92da88d1aea'u64, low: 0x28458026fa152d29'u64, expectedText: "5.6891290267923367748087845301419854e-701", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0e6e503954c9c339'u64, low: 0x12de763eaef2e183'u64, expectedText: "2.2324086696207839393236439874083023e-3820", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x4198afa380d56d99'u64, low: 0x78ffb49ae1494753'u64, expectedText: "2.229197881352817053690231655265678e123", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x743c63922c329655'u64, low: 0xb463e98c0e3d67b6'u64, expectedText: "6.558709059019558007685088637150944e4025", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x77f8afb2b3bd7d5c'u64, low: 0xac15775dc5e4b5a0'u64, expectedText: "4.8500698797336082680140097157124337e4313", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x941290c9c50d709f'u64, low: 0xfbbc9d0f33adca05'u64, expectedText: "-1.2953098847421663515655257086280673e-3385", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xfbc9be64adb3a1af'u64, low: 0xa2449c1d743ef04b'u64, expectedText: "-6.40606456221495861069585254026267e4607", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x7e4166524d2ba062'u64, low: 0xcfb26544eef1d209'u64, expectedText: "9.164394639301581990410557870816499e4797", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xc6e5af3277b50a44'u64, low: 0x9e1831ca3e8f3612'u64, expectedText: "-7.005001748156585739214385513260409e531", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xd7180c1df0fb52e6'u64, low: 0x80f26d62a2d573fb'u64, expectedText: "-1.02435072627256407936665794147394e1780", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x4429dc76a777966a'u64, low: 0x1c5726e4a7821511'u64, expectedText: "1.4715161830238482576410052495698917e321", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xe306e49c0e02dc72'u64, low: 0x734394e611707137'u64, expectedText: "-4.1032044468129350626981073957822504e2699", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xdb9050802aff09fb'u64, low: 0xd0eb13e8c7ec290e'u64, expectedText: "-3.0720292799515419761062179876334402e2124", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x1b8fff3c4eb1d01c'u64, low: 0xe1e212279221d1c1'u64, expectedText: "1.9614694524194760791296039696439823e-2808", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x96bf7a3696265f12'u64, low: 0x049e52200818c06e'u64, expectedText: "-1.9621966863153553122246839241147988e-3179", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3114124d84b1ff3f'u64, low: 0x885a87413b8797dc'u64, expectedText: "2.49136204732354462863234519625711e-1150", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x85fe6c6a2ac2d942'u64, low: 0x57417d3e45c65f9f'u64, expectedText: "-1.4419504124724829216406432277901584e-4470", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xa90ada306d6b875d'u64, low: 0xc3492ed391eadb63'u64, expectedText: "-1.3014489819848008989125465934956629e-1769", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xd087e53fa42eff14'u64, low: 0x7db0639c9706fcb4'u64, expectedText: "-1.7245110234844795925783444444189235e1274", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0644c0e9eba25fe4'u64, low: 0x0e5443223b0815e5'u64, expectedText: "2.0970897919209064990344747566014686e-4449", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x6e0914079b4f1683'u64, low: 0xbf02351042b13d24'u64, expectedText: "9.380905588399221327616560674110797e3547", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x15b1aff089fe150f'u64, low: 0x6a4e0b5faa83d6cc'u64, expectedText: "1.1812179043280462946264940466905353e-3260", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x4ad908aa4f484c5b'u64, low: 0x66e9726d41ef8aef'u64, expectedText: "1.8870566969782147215905217762543966e836", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0575daa07a40ef5e'u64, low: 0x4375859b071f578b'u64, expectedText: "1.0779468092653517173768155746909144e-4511", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x4b45158b210c6a0d'u64, low: 0x8c232cd3bb4e5c6b'u64, expectedText: "6.421826078590256649828816600327776e868", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x55eddb7c136b0ec4'u64, low: 0xb59b01916c69d717'u64, expectedText: "1.7835784360375579508283131929723527e1690", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x28335f3a10de1859'u64, low: 0xad8e5e6234e343dc'u64, expectedText: "1.8306870996160182346810274677895003e-1834", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x890fcb014886b2ce'u64, low: 0xc82465764f3fd8b9'u64, expectedText: "-3.695884963185045686236172997832696e-4234", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x66baec041fe92a8c'u64, low: 0xaeb5c47085aa1e1c'u64, expectedText: "9.911659355991621993077284120919793e2984", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0cc47fdc41fe2862'u64, low: 0x02216da010bdf780'u64, expectedText: "1.4707545231837296094301448954289541e-3948", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x46f9dbd7b2b31e23'u64, low: 0x314233c4c3dc71c8'u64, expectedText: "8.105794392601717463206342379469443e537", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x1cb4329730d84d4c'u64, low: 0x27200ef9d12c345f'u64, expectedText: "1.872009422968038789145238387500454e-2720", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x739755e5379d0b35'u64, low: 0x89514be47cf7d491'u64, expectedText: "1.3484535675338411641346560268329263e3976", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x0101b12c2527b1a7'u64, low: 0xda2c7e26bf642b35'u64, expectedText: "6.587350571343373593124094947680521e-4855", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xec81a636de10405b'u64, low: 0x323c7a8f938ca9bc'u64, expectedText: "-1.4225370784817316408532083470000396e3430", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x207c3fb464956bd5'u64, low: 0xa9b8ff34311a7175'u64, expectedText: "4.870056274814613552430687506922252e-2429", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xbe8290c8052bd2b4'u64, low: 0x6d2248822d584080'u64, expectedText: "-3.178624069517219423063424995523153e-115", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xb2306b15540a081c'u64, low: 0x8b09787d557fac12'u64, expectedText: "-1.0250183795731962773515736942272374e-1064", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x23b674b957d52699'u64, low: 0x57806ee749a6faa0'u64, expectedText: "2.540673079540500538277677129178086e-2180", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x08468037b40e2a92'u64, low: 0x635494028466cafb'u64, expectedText: "9.626072601878632474498150570951187e-4295", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xabfcef7dfd81c241'u64, low: 0x18cd49d0a2c9a84f'u64, expectedText: "-1.2886323390905287426729194190182795e-1542", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x6dd3f0750ac26234'u64, low: 0xf5f6591021ad5727'u64, expectedText: "9.365931433549047948525658602032642e3531", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x65a2776ff4318f27'u64, low: 0x4e2f1195690adfa8'u64, expectedText: "3.893190886250848717489412990020198e2900", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x4b7e1f596f12215b'u64, low: 0x0bae00b8d502dbed'u64, expectedText: "9.581808666860691637355725307919733e885", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xd323c6516281365f'u64, low: 0x40595f03751c0232'u64, expectedText: "-1.9774187385616686244749709241809974e1475", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xc358e0be2b7c037a'u64, low: 0xd2295b4711901145'u64, expectedText: "-1.804592522179033742825585059533206e258", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xfac531d1d9c899af'u64, low: 0xd138c1520ce65eb8'u64, expectedText: "-2.3688649089629360572760538915826818e4529", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xfabf8978682a89ee'u64, low: 0xf399a5da985996a0'u64, expectedText: "-4.762191120823947450540215860986727e4527", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x6a1b19623eed29b9'u64, low: 0xb2bfe34a45b4b729'u64, expectedText: "1.3944801628287435543592716638274074e3245", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x47e446a6a78eabab'u64, low: 0xfd5425732e73ad97'u64, expectedText: "3.0723115672180824204484584016811776e608", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8b85e4dc662b463d'u64, low: 0x4e632d4084781735'u64, expectedText: "-1.739464134101114775293273567109471e-4044", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xdda2a77f0f7fc191'u64, low: 0x2aa1651b4f2ccb5a'u64, expectedText: "-1.35889777852420426029886181349002e2284", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x1816f40fa0fff322'u64, low: 0x2254bfb65a2fde86'u64, expectedText: "4.648548480028924873059271516490921e-3076", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x995ec9a7bb24bea9'u64, low: 0x15d597a0f89e50df'u64, expectedText: "-2.3263299620916256491916456206502627e-2977", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x38b47fb0fa351335'u64, low: 0x4b3f68a3953838e7'u64, expectedText: "1.4214778677428139970673369181781091e-562", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xe8843dc220ed6110'u64, low: 0xae6fc786497d0b31'u64, expectedText: "-4.764331599318120521400447539100382e3122", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x72b3fd049f058329'u64, low: 0x75ace4c9397099aa'u64, expectedText: "4.6541131471199827767561999526878e3907", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xf0469249360e283c'u64, low: 0xb7d65d4109c86261'u64, expectedText: "-4.226796550254321515104303897084609e3720", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x1750d6525f09d3fb'u64, low: 0xb2fd07e9053aac61'u64, expectedText: "1.0883041096483657980183215985794247e-3135", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xe21558765ef5f370'u64, low: 0x0e7338279675bf1d'u64, expectedText: "-8.253611158987308873501709792788891e2626", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x9454f2d974bf8306'u64, low: 0x97dcdd2753ec8989'u64, expectedText: "-1.1896192797977012214568224537828955e-3365", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x349c8fdb9ded4bff'u64, low: 0xb92c99ddece5b28d'u64, expectedText: "4.911660403376145056803997537067307e-878", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x283ac161968d6006'u64, low: 0x397418603152c333'u64, expectedText: "2.9981359526753918426482391697795625e-1832", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xfa647a23e74bddd5'u64, low: 0x7549738e992cd7a0'u64, expectedText: "-1.8484943194615568883997052982221477e4500", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x1166edd79750b1c3'u64, low: 0x63153e578421e74d'u64, expectedText: "1.9885197835612904741045598485957907e-3591", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xf94eb5e477d7262a'u64, low: 0x49f84d6b78a49159'u64, expectedText: "-4.4075158407078714869066218968231754e4416", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x9254768fc5c7f148'u64, low: 0x913e6d151d0371ad'u64, expectedText: "-6.66199024005463723745880029771783e-3520", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xb00d31f22f9f6bb1'u64, low: 0x93399ed79109a327'u64, expectedText: "-1.8748329147362118009461293052250845e-1229", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xe992a9d686fc54f2'u64, low: 0x18ca0313ee7c11a5'u64, expectedText: "-1.2112904607786211443857052896088513e3204", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xfceaa263d3ea9fa0'u64, low: 0x1be2975fda6e261c'u64, expectedText: "-5.972053103957168070470232581624262e4694", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xfb6d9ac468f138ab'u64, low: 0xb99e3af41745bf0f'u64, expectedText: "-1.190446416231412111626866136048021e4580", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x571a9c574eb68f8b'u64, low: 0xdff9ef0e07b5b67c'u64, expectedText: "6.3014566679598194477153185618384234e1780", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x87e5666b314e76f1'u64, low: 0xf3daeedaf462846d'u64, expectedText: "-5.6669971530220911460508335921533924e-4324", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x53fa7cce02fecf4f'u64, low: 0x4b006e7db3db0440'u64, expectedText: "8.727506757560937124138640768077971e1539", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x747cace0385c9d49'u64, low: 0xd943ca24b801f88f'u64, expectedText: "1.4592959378267996492495735467769845e4045", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x19c719d94e8b7e25'u64, low: 0xae06190e4e1bffa4'u64, expectedText: "5.811640381733184149575362546075793e-2946", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x40c75cdc4bf5e1b2'u64, low: 0x5b70a077b096ac6c'u64, expectedText: "2.1898330637864994447801838497127533e60", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xa9ad4771e158a5c0'u64, low: 0x9edbe0dfc5cd81cf'u64, expectedText: "-1.0507586359377059901125600874797365e-1720", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x25eda8269d57c4eb'u64, low: 0x25904dce25b150e5'u64, expectedText: "1.3966555227596342112904289283497129e-2009", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8a69aa2d84fec023'u64, low: 0x8610c1c3b2badefa'u64, expectedText: "-4.9189266913700805496701002060391035e-4130", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x5b00bf8bf02886c4'u64, low: 0x437723c40c4cad94'u64, expectedText: "1.8321387248097240879635139145073963e2081", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x627348605c6cb653'u64, low: 0x7259a3bf013d06c0'u64, expectedText: "1.55845311723403193182779079677996e2655", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x08593efec08c68d9'u64, low: 0x8eba05bd555108e1'u64, expectedText: "4.1901141302349818447873266740864584e-4289", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x573c61a77acd1570'u64, low: 0x0cc67fd7ae3651a0'u64, expectedText: "9.285025084973712793380978538576009e1790", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xdc305b52639f2754'u64, low: 0x1a87c50acff954a0'u64, expectedText: "-4.6341578792114835542491475352208804e2172", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x073a8788b2c19965'u64, low: 0x958a760c76667b42'u64, expectedText: "2.068247492500999559964628790996792e-4375", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x235e46480a6ba5bd'u64, low: 0x86d28050c180057f'u64, expectedText: "7.186445600870544412402325968657672e-2207", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x67470863498ff048'u64, low: 0x24efe916e6b931c4'u64, expectedText: "1.4846972716074716969923179217031882e3027", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xeb1f48864fcd25cc'u64, low: 0x0bc57862a7de800e'u64, expectedText: "-3.016338887332742421664623005443067e3323", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xbac29d1ef7ebf5c0'u64, low: 0xaf2af11a0d16fce2'u64, expectedText: "-3.362119070895104550408306454797674e-404", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xb594a8568bd5c02e'u64, low: 0x13313d5b2558cfc4'u64, expectedText: "-2.357618859025561584940499526988216e-803", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xd9588f56e9f9d10d'u64, low: 0x12af5bc11ee6a852'u64, expectedText: "-3.773498454509038128166123961271472e1953", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x86cf052425f88ccf'u64, low: 0x703f82eec6ccd3bd'u64, expectedText: "-8.501565726840498249086892333398105e-4408", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xdf237cf38c4c28a9'u64, low: 0x5c5a9a7f7b5da94c'u64, expectedText: "-9.632854394336899345187675789027507e2399", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xae9a2e52dfb2690c'u64, low: 0x1602ee9156264802'u64, expectedText: "-3.851780890226722086314078968465304e-1341", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x034325c67d96bf08'u64, low: 0x64d2d54b4d16e031'u64, expectedText: "4.419801949481139562068700563800675e-4681", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x9829cc860174ce35'u64, low: 0x09772a819f2f3a60'u64, expectedText: "-2.2444814068539077967317399433964437e-3070", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xb81039a103abb321'u64, low: 0xf331a23f8eb8da40'u64, expectedText: "-4.968839883342756262663278505082252e-612", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x053bb03c55c32bab'u64, low: 0xfc4d840d9ee9e977'u64, expectedText: "3.4058528739657394106611427484824055e-4529", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x9b194c61ade8dfb7'u64, low: 0x92a5ec2e21526c17'u64, expectedText: "-3.837584173580563737942685065008919e-2844", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xd83ecd826e8ff446'u64, low: 0xe93a52a99616f778'u64, expectedText: "-5.6120788703784940862823465066970695e1868", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x4b009cad28f225cc'u64, low: 0xe38abcdda9374534'u64, expectedText: "1.6175862989906469159107484711661345e848", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8b4c326c460515bc'u64, low: 0xc7d4577943c47d6c'u64, expectedText: "-7.627984675704954508421434433540513e-4062", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8a65cc7404270831'u64, low: 0x8e4774ab9bac05fd'u64, expectedText: "-3.321582303873370620729661156988205e-4131", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x775348dc55ce7c54'u64, low: 0xc5a17975abf45e35'u64, expectedText: "7.900063378940918386482527329343204e4263", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x5c046aae71b9ece2'u64, low: 0xc49b9ab57c79494a'u64, expectedText: "2.7507064338365085769397204396998697e2159", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x46a6757ffb575e06'u64, low: 0x0b2a6d18683ec33c'u64, expectedText: "6.5785953532845346571310943694772535e512", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x9ef57e2de320001f'u64, low: 0xe94dabe5975e733a'u64, expectedText: "-1.1543135907908493497954917118835262e-2546", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x029649867ef90194'u64, low: 0x9053e29a881559f3'u64, expectedText: "4.1408267869214073473351231378753574e-4733", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xb45e0a3c8b9abe8e'u64, low: 0x3e8a9323ada00f21'u64, expectedText: "-7.091376548667163914970414914482455e-897", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xc1288baf0e3ba15b'u64, low: 0x04ca7b7868e1b352'u64, expectedText: "-3.935655068906353619501360707360211e89", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xfedadbaadb20a12e'u64, low: 0xcbc36c9453e6be59'u64, expectedText: "-1.3890684822213951103051953951587233e4844", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xb0bb147752c521b1'u64, low: 0x37a65d235b46f083'u64, expectedText: "-4.0567559008928466580301156643319155e-1177", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3815d50071fc948f'u64, low: 0x9cc71c9300a04188'u64, expectedText: "2.3777340263836954251178078727381843e-610", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x67339c6cf738f7ac'u64, low: 0x36816cf40a68adc0'u64, expectedText: "2.208727727222738146669654838313909e3021", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xb61a2f83a7bb2085'u64, low: 0x499f9c8836950357'u64, expectedText: "-3.6724859594864570407062823801458326e-763", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x2530ce79a133f8e8'u64, low: 0x8d3ec51a2911a987'u64, expectedText: "1.940832977181606778128054712155505e-2066", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x9b0a612e8ea6da72'u64, low: 0xfd3d86c25ea10249'u64, expectedText: "-1.2444270773920232191887701895721278e-2848", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x88bc227d5b5f5c0d'u64, low: 0x4c52451ece6e9d88'u64, expectedText: "-2.4184776470941000213309695956815148e-4259", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xfda4decbb4e4f379'u64, low: 0xcf525955c281a8e2'u64, expectedText: "-6.7030409977287125859323590150800154e4750", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8b6360356debdea7'u64, low: 0xaf21664b09ee7cd6'u64, expectedText: "-7.354929633516826500765822590844575e-4055", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x397de689e79f001c'u64, low: 0x631c298e82e72656'u64, expectedText: "5.7930148317803723136282642960838145e-502", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x1f6ad58ba53988ad'u64, low: 0x59f2b249a779e80d'u64, expectedText: "2.3563721154861004489248801359865177e-2511", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x06582f773707f0f0'u64, low: 0xfa81f8f33942a5ec'u64, expectedText: "1.4864955630241021411174760764612823e-4443", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xec71bfa654342c46'u64, low: 0xaad7d4f3c4eda9b7'u64, expectedText: "-2.3013836265201726536022368890129803e3425", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8eee07b66d0a7c49'u64, low: 0x866b5140b979b795'u64, expectedText: "-5.958204184632422656474235221286453e-3782", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x1f909e52414c6f82'u64, low: 0x1c535eaf09ce98cb'u64, expectedText: "5.715356257742836700736205459051754e-2500", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x2900b64f95c235f0'u64, low: 0xb982ef3dcb66a663'u64, expectedText: "1.1747834260188869098012316757545693e-1772", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xb02d4f1b34155750'u64, low: 0x0d02c13c91511ba7'u64, expectedText: "-8.819828509119168814138462363442732e-1220", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x4a339a3d850ff234'u64, low: 0x708b77de251208dc'u64, expectedText: "3.1271379668983912219182584558529926e786", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x5cc0d98a618d0f1d'u64, low: 0xf65caf91a5ef3813'u64, expectedText: "1.4090139484765240432755040350336697e2216", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x2c552c8342d1a398'u64, low: 0xface7cbef89a3079'u64, expectedText: "4.837541993960205177868134892748823e-1516", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xa7d582489cfbe46a'u64, low: 0x23019d1b58d88ac0'u64, expectedText: "-1.0165135650155005917249091926265324e-1862", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xf5882f2f90ab95a0'u64, low: 0xf8617272a54fcef1'u64, expectedText: "-4.892822582171489483712610890625258e4125", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xec429bcc61c1454a'u64, low: 0xc7cc671c02f687e2'u64, expectedText: "-1.5042690598770303895754077495606819e3411", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3395af678fb39fe5'u64, low: 0xca04283e7e2a3be8'u64, expectedText: "3.5753496690710113806849387338075843e-957", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x94c312fdba89aaad'u64, low: 0xa9ee76007f54a95a'u64, expectedText: "-1.7024983809278508751042247067494877e-3332", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x786809770006f700'u64, low: 0xeaa02b92001f30df'u64, expectedText: "1.5485828072710641192112125327266666e4347", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3b53fa72fddca5dc'u64, low: 0xa0faa9f4a93c79a8'u64, expectedText: "1.8383199406780644068349207229817392e-360", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xc63af5784bf63948'u64, low: 0xa30357014c22a91a'u64, expectedText: "-2.721748528867102532957689106614244e480", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x8b48cc8096d1cc34'u64, low: 0x97c260fbe432d3ac'u64, expectedText: "-7.164738666503382518650518185431634e-4063", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3eb617f7d4ed8c33'u64, low: 0xde6cafd69db678ab'u64, expectedText: "1e-99", nanCanonicalization: false, expectedCrossDecade: true),
    F128ShortestContractVector(high: 0xbeb617f7d4ed8c33'u64, low: 0xde6cafd69db678ab'u64, expectedText: "-1e-99", nanCanonicalization: false, expectedCrossDecade: true),
    F128ShortestContractVector(high: 0x3eb617f7d4ed8c33'u64, low: 0xde6cafd69db678aa'u64, expectedText: "9.999999999999999999999999999999997e-100", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xbeb617f7d4ed8c33'u64, low: 0xde6cafd69db678aa'u64, expectedText: "-9.999999999999999999999999999999997e-100", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0x3eb617f7d4ed8c33'u64, low: 0xde6cafd69db678ac'u64, expectedText: "1.0000000000000000000000000000000001e-99", nanCanonicalization: false, expectedCrossDecade: false),
    F128ShortestContractVector(high: 0xbeb617f7d4ed8c33'u64, low: 0xde6cafd69db678ac'u64, expectedText: "-1.0000000000000000000000000000000001e-99", nanCanonicalization: false, expectedCrossDecade: false),
  ]

var
  vectorCount = 0
  finiteVectorCount = 0
  exactRoundtripCount = 0
  nanCanonicalizationCount = 0
  expectedCrossDecadeCount = 0
  oneEMinus99WitnessSeen = false

for vector in f128ShortestContractVectors:
  let
    original = fromBits(
      vector.high,
      vector.low,
    )

    formatted =
      toShortestString(original)

  doAssert formatted ==
    vector.expectedText

  var parsed: Float128

  doAssert tryParseFloat128(
    formatted,
    parsed,
  )

  if vector.nanCanonicalization:
    doAssert isNaN(original)
    doAssert isNaN(parsed)
    doAssert isQuietNaN(parsed)
    doAssert signBit(parsed) ==
      signBit(original)
    inc nanCanonicalizationCount
  else:
    doAssert sameBits(
      parsed,
      original,
    )
    inc exactRoundtripCount

  if isFinite(original) and
      not isZero(original):
    inc finiteVectorCount

  if vector.expectedCrossDecade:
    inc expectedCrossDecadeCount

  if vector.high ==
      0x3eb617f7d4ed8c33'u64 and
      vector.low ==
      0xde6cafd69db678ab'u64:
    doAssert formatted == "1e-99"
    oneEMinus99WitnessSeen = true

  inc vectorCount

doAssert vectorCount == 262
doAssert finiteVectorCount == 254
doAssert exactRoundtripCount == 258
doAssert nanCanonicalizationCount == 4
doAssert expectedCrossDecadeCount == 2
doAssert oneEMinus99WitnessSeen

echo "F128_SHORTEST_CONTRACT_OK\t262\t254\t258\t4\t2\t1e-99"
