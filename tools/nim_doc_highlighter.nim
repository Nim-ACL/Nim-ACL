when not declared NIM_ACL_DOC_HIGHLIGHTER_HPP:
  const NIM_ACL_DOC_HIGHLIGHTER_HPP* = 1

  import std/base64
  import packages/docutils/highlite

  proc escapeHtml(text: string): string =
    result = newStringOfCap(text.len)

    for ch in text:
      case ch
      of '&':
        result.add "&amp;"
      of '<':
        result.add "&lt;"
      of '>':
        result.add "&gt;"
      of '"':
        result.add "&quot;"
      of '\'':
        result.add "&#39;"
      else:
        result.add ch

  proc tokenCssClass(kind: TokenClass): string =
    case kind
    of gtKeyword:
      "tok-keyword"

    of gtStringLit, gtLongStringLit, gtCharLit:
      "tok-string"

    of gtEscapeSequence:
      "tok-escape"

    of gtDecNumber, gtBinNumber, gtHexNumber,
       gtOctNumber, gtFloatNumber:
      "tok-number"

    of gtComment, gtLongComment:
      "tok-comment"

    of gtOperator:
      "tok-operator"

    of gtPunctuation:
      "tok-punctuation"

    of gtIdentifier:
      "tok-identifier"

    of gtPreprocessor, gtDirective:
      "tok-directive"

    of gtHyperlink:
      "tok-hyperlink"

    of gtWhitespace, gtEof:
      ""

    else:
      "tok-other"

  proc appendHighlightedToken(
    resultHtml: var string,
    text: string,
    cssClass: string
  ) =
    ## A token may contain line breaks, for example a long comment or string.
    ## Each line fragment is wrapped independently so that line-number markup
    ## can later split lines without producing unbalanced span elements.
    var segmentStart = 0

    for i, ch in text:
      if ch != '\n':
        continue

      let segment =
        if segmentStart < i:
          text[segmentStart ..< i]
        else:
          ""

      if cssClass.len == 0:
        resultHtml.add escapeHtml(segment)
      elif segment.len > 0:
        resultHtml.add "<span class=\""
        resultHtml.add cssClass
        resultHtml.add "\">"
        resultHtml.add escapeHtml(segment)
        resultHtml.add "</span>"

      resultHtml.add '\n'
      segmentStart = i + 1

    let tail =
      if segmentStart < text.len:
        text[segmentStart ..< text.len]
      else:
        ""

    if cssClass.len == 0:
      resultHtml.add escapeHtml(tail)
    elif tail.len > 0:
      resultHtml.add "<span class=\""
      resultHtml.add cssClass
      resultHtml.add "\">"
      resultHtml.add escapeHtml(tail)
      resultHtml.add "</span>"

  type
    BrokenCharLiteral = tuple[
      found: bool,
      first: int,
      last: int,
    ]

  proc appendTokenizedNim(
    resultHtml: var string,
    code: string
  ) =
    for item in tokenize(code, langNim):
      let
        token = item[0]
        kind = item[1]

      resultHtml.appendHighlightedToken(
        token,
        tokenCssClass(kind),
      )

  proc firstBrokenCharLiteral(
    code: string
  ): BrokenCharLiteral =
    ## Nim 2.2.4's docutils tokenizer may report the opening quote of
    ## a character literal as punctuation and absorb later separators
    ## into a string token. Detect only that broken opening-quote shape.
    var offset = 0

    for item in tokenize(code, langNim):
      let
        token = item[0]
        kind = item[1]

      if kind == gtPunctuation and token == "'" and offset < code.len and ord(code[offset]) == 39:
        var
          j = offset + 1
          escaped = false

        while j < code.len:
          let value = ord(code[j])

          if value == 10 or value == 13:
            break

          if not escaped and value == 39:
            let bodyLen = j - offset - 1

            if bodyLen == 1 or (bodyLen >= 2 and ord(code[offset + 1]) == 92):
              return (
                found: true,
                first: offset,
                last: j,
              )

            break

          if not escaped and value == 92:
            escaped = true
          else:
            escaped = false

          inc j

      offset += token.len

    return (
      found: false,
      first: 0,
      last: 0,
    )

  proc appendStableNim(
    resultHtml: var string,
    code: string
  ) =
    if code.len == 0:
      return

    let repair = firstBrokenCharLiteral(code)

    if not repair.found:
      resultHtml.appendTokenizedNim(code)
      return

    if repair.first > 0:
      resultHtml.appendTokenizedNim(
        code[0 ..< repair.first]
      )

    resultHtml.appendHighlightedToken(
      code[repair.first .. repair.last],
      "tok-string",
    )

    let next = repair.last + 1

    if next < code.len:
      resultHtml.appendStableNim(
        code[next ..< code.len]
      )

  proc highlightNim(code: string): string =
    result.appendStableNim(code)

  proc processLine(encoded: string): string =
    if encoded.len == 0:
      return ""

    let code = decode(encoded)
    encode(highlightNim(code))

  when isMainModule:
    for encodedLine in stdin.lines:
      stdout.writeLine processLine(encodedLine)
