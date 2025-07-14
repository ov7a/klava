import std/jsextern

extern do_fetch(url: string): any
  js inline "fetch(#1).then(r => r.ok ? r.text() : Promise.reject(r.statusText))"

pub fun fetch_data(url: string): asyncx string
  Jspromise(do_fetch(url)).wrap.unsafe-as-string