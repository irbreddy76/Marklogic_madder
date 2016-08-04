xquery version "1.0-ml";

module namespace resource = "http://marklogic.com/rest-api/resource/merge";

import module namespace m = "http://marklogic.com/person-merge" at
  "/lib/merge-lib.xqy";

declare namespace err = "http:/marklogic.com/xdmp/error";

declare function get(
  $context as map:map,
  $params  as map:map
  ) as document-node()*
{
  fn:error((), "RESTAPI-SRVEXERR", (405, "Method Not Allowed", "GET is not implemented"))
};

declare function put(
  $context as map:map,
  $params  as map:map,
  $input   as document-node()*
  ) as document-node()?
{
  map:put($context, "output-types", "application/json"),
  xdmp:set-response-code(200, "Ok"),
  try {
    let $response := json:object()
    let $primary := map:get($params, "primary")
    let $secondary := map:get($params, "secondary")
    let $_ :=
      if(fn:doc-available($primary) and fn:doc-available($secondary)) then
        map:put($response, "uri", m:merge($primary, $secondary, ()))
      else map:put($response, "error", "Both documents must be available")
    return xdmp:to-json($response)
  } catch($e) {
    xdmp:log($e, "error"),
    let $error := json:object()
    let $_ := map:put($error, "error", $e/err:message)
    return xdmp:to-json($error)
  }
};

declare function post(
  $context as map:map,
  $params  as map:map,
  $input   as document-node()*
  ) as document-node()*
{
  fn:error((), "RESTAPI-SRVEXERR", (405, "Method Not Allowed", "POST is not implemented"))
};

declare function delete(
  $context as map:map,
  $params  as map:map
  ) as document-node()?
{
  fn:error((), "RESTAPI-SRVEXERR", (405, "Method Not Allowed", "DELETE is not implemented"))
};
