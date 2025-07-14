import std/core/string
import std/text/regex

// no idea how to properly use these with conan/vcpkg, relying on linux libs
extern import
  c { conan="icu/77.1"; vcpkg="icu"; library="icuuc" }
  c { conan="icu/77.1"; vcpkg="icu"; library="icudata" }
  c { conan="icu/77.1"; vcpkg="icu"; library="icui18n" }
  c { conan="icu/77.1"; vcpkg="icu"; library="stdc++" }

extern import
  c file "unicode_ops.c"

fun trim_chars(input: string, chars: string): string
  input.replace(regex("^[" ++ chars ++ "]+(.*)[" ++ chars ++ "]"), "$1")

pub extern to-lower-unic: (input: string) -> string
  c "kk_string_to_lower_unicode"
  js inline "(#1).toLowerCase()"


