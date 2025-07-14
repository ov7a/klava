import std/async/async
import libs/html/html
import std/jsextern

import utils/http
import utils/dom

import utils/map
import utils/serde
import core/index
import core/search

fun load(url: string): <asyncx, div> index
  val data = fetch_data(url)
  deserialize(data)

fun layout(query_id: string, results_id: string): component
  build
    div
      add-class("page-content")
      div
        add-class("wrapper")
        h1
          text("Blog search")
        p  
          // input helper can't be extened to have extra attrs
          classcomponent("input")
            add-attrs([
              ("id", query_id),
              ("name", "query"),
              ("type", "text"),
              ("placeholder", "Type to search..."),
              // I don't want an extra css file just for that
              ("style", "width: 100%")
            ])
        div
          add-attr("id", results_id)  

fun search_result(result: result): component-builder ()
  div
    a(result.url)
      h1
        add-class("post-link")
        text(result.title)
    p
      add-class("post-meta")
      result.tags.foreach fn(tag)
        // creating a without href
        classcomponent("a", classes=["post-tag"])
          text(tag)

fun update_items(results_id: string, index: index, query: string): ()
  with handler
    final ctl throw-exn(error)
      set_body("Error occurred " ++ error.show)
  val results = search(index, query)
  val items = build
    results.foreach(search_result)
    
  set_element(results_id, items.show)

fun init(url: string): <asyncx, div> index
  load(url)

pub fun main()
  with handler
    final ctl throw-exn(error)
      set_body("Error occurred " ++ error.show)

  val query_id = "query"   
  val results_id = "results" 

  set_body("Loading...")
  
  // why not? I don't want to rewrite all styles
  load_style("https://ov7a.github.io/assets/main.css")
  
  trace("loading index...")
  val index = init("index.json")
  trace("index loaded")

  set_body(layout(query_id, results_id).show)
  add_listener(query_id, "input") fn(event: any) ->
    val value = Jsobject(event).get-obj("target").get-string("value")
    update_items(results_id, index, value)
