#include "kklib.h"
#include "stdio.h"
#include <unicode/ucasemap.h>
#include <unicode/uchar.h>
#include <unicode/utf8.h>

kk_string_t  kk_string_to_lower_unicode(kk_string_t str, kk_context_t* ctx) {
  if (kk_string_is_empty_borrow(str, ctx)) {
    kk_string_drop(str, ctx);
    return kk_string_empty();
  }
  kk_ssize_t original_len;
  const uint8_t *s = kk_string_buf_borrow(str, &original_len, ctx);

  UErrorCode status = U_ZERO_ERROR;
  UCaseMap *case_map = ucasemap_open(NULL, 0, &status);
  kk_assert_internal(!U_FAILURE(status));
  int32_t new_len = ucasemap_utf8ToLower(case_map, NULL, 0, (const char *)s, original_len, &status); 
  
  kk_assert_internal(status == U_BUFFER_OVERFLOW_ERROR);
  status = U_ZERO_ERROR;
  
  kk_string_dup(str, ctx);  // multi-thread safe as we still reference str with s
  uint8_t *tbytes;
  kk_string_t tstr = kk_unsafe_string_alloc_buf(new_len, &tbytes, ctx);
  kk_assert_internal(!kk_datatype_eq(str.bytes, tstr.bytes));

  uint8_t* t = (uint8_t*)kk_string_buf_borrow(tstr, NULL, ctx);   // t & s may alias!

  ucasemap_utf8ToLower(case_map, (char *)t, new_len, (const char *)s, original_len, &status);
  ucasemap_close(case_map);
  kk_assert_internal(!U_FAILURE(status));
  if (!kk_datatype_eq(str.bytes, tstr.bytes)) kk_string_drop(str, ctx);  // drop if not reused in-place
  return tstr;
}