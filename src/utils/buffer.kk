struct buffer<t>
  internal: list<t> = []

pub fun buffer<t>(): buffer<t>
  Buffer()

// I never thought I will care about these tricks again :/
pub fun append<t>(b: buffer<t>, item: t): buffer<t>
  Buffer([item] ++ b.internal)

pub fun list(b: buffer<t>): list<t>
  b.internal.reverse

