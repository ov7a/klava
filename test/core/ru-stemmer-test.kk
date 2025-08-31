import std/test
import std/os/file
import std/os/path
import std/data/buffer
import core/stem

// print text as is without \u escapes
fun errors-printer(errors: list<string>): string
  "Failures:\n" ++ errors.join("\n") ++ "\ntotal: " ++ errors.length.show

fun suite()
  val data = read-text-file("test/core/ru-stemmer-dataset.txt".path)
    .split("\n")
    .map(_.split(" ", 2).map(_.trim))
    .filter(_.length == 2)
    .map(fn(l) (l.head.unjust, l.last.unjust))

  group("russian stemmer")
    val errors = data
      .filter-map fn((original, stemmed))
        val actual = ru-stem(original)
        if actual == stemmed then
          Nothing
        else
          Just(original ++ "\t->\t" ++ actual ++ ",\texpected " ++ stemmed)  
      
    test("all words should be stemmed correctly")
      expect([], ?show=errors-printer)
        errors
      