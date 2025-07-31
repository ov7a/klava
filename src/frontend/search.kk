import std/async/async
import html/html
import std/jsextern

import utils/http
import utils/dom

import utils/map
import utils/serde
import core/index
import core/search

val search_container_id = "search_container"
val query_id = "query"
val results_id = "results"
val data_path = "index.json"

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
          input("query", "text", "")
            add-attr("id", query_id)
            add-attr("placeholder", "Type to search...")
            // I don't want an extra css file just for that
            add-attr("style", "width: 100%")
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
      set_output(search_container_id, "Error occurred " ++ error.show)
  val results = search(index, query)
  val items = build
    results.foreach(search_result)
    
  set_element(results_id, items.show)

fun init(url: string): <asyncx, div> index
  load(url)

pub fun main()
  with handler
    final ctl throw-exn(error)
      val err_msg = match error.info
        JSError(nested) -> "JS error happened: " ++ nested.show
        _ -> "Unknown error happened: " ++ error.show
      set_output(search_container_id, err_msg)

  set_output(search_container_id, "Loading...")
  
  // why not? I don't want to rewrite all styles
  load_style("https://ov7a.github.io/assets/main.css")
  
  trace("loading index...")
  val index = init(data_path)
  trace("index loaded")

  set_output(search_container_id, layout(query_id, results_id).show)
  add_listener(query_id, "input") fn(event: any) ->
    val value = Jsobject(event).get-obj("target").get-string("value")
    update_items(results_id, index, value)
