extern set_body : (body: string) -> ()
  js inline "document.body.innerHTML = #1"

extern set_element : (id: string, body: string) -> ()
  js inline "document.getElementById(#1).innerHTML = #2"

extern add_listener: (element_id: string, event: string, f: any -> ()) -> ()
  js inline "document.getElementById(#1).addEventListener(#2, #3)"  

extern load_style: (path: string) -> ()
  js inline "document.head.appendChild(Object.assign(document.createElement('link'), {rel: 'stylesheet', href: #1, type: 'text/css'}))"  