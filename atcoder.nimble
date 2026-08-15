# Package

version       = "0.5.0"
author        = "zer0-star"
description   = "ACL (AtCoder Library) implementation in Nim"
license       = "CC0"
srcDir        = "src"

skipDirs      = @["verify", ".verify-helper"]
skipFiles = @["lib"]

backend       = "cpp"

# Dependencies

requires "nim >= 1.0.0"

after install:
  if defined(linux):
    exec("ln -s ./atcoder/extra lib")
