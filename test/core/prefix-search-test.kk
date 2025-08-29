import std/test
import utils/map
import core/search

fun suite()
  group("successor prefix")
    test("empty map - no matches")
      expect([]: list<int>)
        val m = empty-map()
        m.prefix_search("some")
    test("empty prefix matches all")
      val m = [("some", 7), ("keys", 4), ("in", 3), ("a", 1), ("non", 6), ("empty", 2), ("map", 5)].to-map
      expect([1, 2, 3, 4, 5, 6, 7])
        m.prefix_search("")
    test("single match works")
      val m = [("some", 7), ("keys", 4), ("in", 3), ("a", 1), ("non", 6), ("empty", 2), ("map", 5)].to-map
      expect([4])
        m.prefix_search("ke")
    test("multiple matches at start work")
      val m = [("some", 7), ("arrkeys", 4), ("arrin", 3), ("arr", 1), ("non", 6), ("arrempty", 2), ("map", 5)].to-map
      expect([1, 2, 3, 4])
        m.prefix_search("ar")
    test("multiple matches at end work")
      val m = [("quesome", 7), ("keys", 4), ("in", 3), ("a", 1), ("quenon", 6), ("empty", 2), ("quemap", 5)].to-map
      expect([5, 6, 7])
        m.prefix_search("que")
    test("multiple matches in the middle work")
      val m = [("some", 7), ("inkeys", 4), ("inin", 3), ("a", 1), ("non", 6), ("inempty", 2), ("map", 5)].to-map
      expect([2, 3, 4])
        m.prefix_search("in")
    test("exact match is skipped")
      val m = [("some", 7), ("inkeys", 4), ("in", 2), ("a", 1), ("non", 6), ("inempty", 3), ("map", 5)].to-map
      expect([3, 4])
        m.prefix_search("in")