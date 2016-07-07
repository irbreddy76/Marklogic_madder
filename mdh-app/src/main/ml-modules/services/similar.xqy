xquery version "1.0-ml";

module namespace resource = "http://marklogic.com/rest-api/resource/similar";

import module namespace s = "http://marklogic.com/search/similar" at
  "/lib/find-similar.xqy";

declare function get(
  $context as map:map,
  $params  as map:map
  ) as document-node()*
{
  try {
    map:put($context, "output-types", "application/json"),
    xdmp:set-response-code(200, "Ok"),
    let $uri := map:get($params, "uri")
    let $results := 
      if(fn:empty($uri) or fn:not(fn:doc-available($uri))) then json:object()
      else s:find-similar(xdmp:from-json(fn:doc($uri)), $uri, map:get($params, "limit"))
    return xdmp:to-json($results)
  } catch($e) {
    map:put($context, "output-types", "text/plain"),
    xdmp:set-response-code(500, "Error"),
    xdmp:log($e, "error"),
    document{ "An unexpected error has occurred.  Check logs for details" }
  }
};

declare function put(
  $context as map:map,
  $params  as map:map,
  $input   as document-node()*
  ) as document-node()?
{
  fn:error((), "RESTAPI-SRVEXERR", (405, "Method Not Allowed", "PUT is not implemented"))
};

declare function post(
  $context as map:map,
  $params  as map:map,
  $input   as document-node()*
  ) as document-node()*
{
  try {
    map:put($context, "output-types", "application/json"),
    xdmp:set-response-code(200, "Ok"),
    if(fn:count($input) = 1) then 
      let $target := map:get($params, "target")
      let $record := xdmp:from-json($input[1])
      let $result := s:find-similar($record, map:get($params, "uri"), map:get($params, "limit"))
      return xdmp:to-json($result)
    else xdmp:to-json(json:object())
  } catch($e) {
    map:put($context, "output-types", "text/plain"),
    xdmp:set-response-code(500, "Error"),
    xdmp:log($e, "error"),
    document{ "An unexpected error has occurred.  Check logs for details" }
  }
};

declare function delete(
  $context as map:map,
  $params  as map:map
  ) as document-node()?
{
  fn:error((), "RESTAPI-SRVEXERR", (405, "Method Not Allowed", "DELETE is not implemented"))
};
