xquery version "1.0-ml";

module namespace resource = "http://marklogic.com/rest-api/resource/abawd";

import module namespace abawd-lib = "http://marklogic.com/md-dhr/abawd-lib" at
  "/lib/abawd-lib.xqy";

import module namespace json="http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";


declare function get(
  $context as map:map,
  $params  as map:map
  ) as document-node()*
{
  try {
    map:put($context, "output-types", "application/xml"),
    xdmp:set-response-code(200, "Ok"),
    let $cert-period := map:get($params, "cert-period")
    let $q := abawd-lib:get-abawd-query($cert-period)
    let $obj := object-node{ "query": $q }
    
    return xdmp:to-json($obj/query)

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
  fn:error((), "RESTAPI-SRVEXERR", (405, "Method Not Allowed", "PUT is not implemented"))
};

declare function delete(
  $context as map:map,
  $params  as map:map
  ) as document-node()?
{
  fn:error((), "RESTAPI-SRVEXERR", (405, "Method Not Allowed", "DELETE is not implemented"))
};
