xquery version "1.0-ml";

module namespace resource = "http://marklogic.com/rest-api/resource/relationship";

import module namespace rel = "http://marklogic.com/search/relationship" at
  "/lib/relationship-lib.xqy";

declare function get(
  $context as map:map,
  $params  as map:map
  ) as document-node()*
{
  try {
    map:put($context, "output-types", "application/json"),
    xdmp:set-response-code(200, "Ok"),
    let $target := map:get($params, "target")
    let $Id := map:get($params, "id")
    let $format := map:get($params, "format")
    let $results := 
      if ($target = "person") then rel:getPersonRelationship($Id, $format)
      else if ($target = "case") then rel:getCaseRelationshipRDF($Id)
      else if ($format = "json" and $target = "case") then rel:getCaseRelationship($Id)
      else json:object()
    (: return xdmp:to-json($results)    :)
    return $results
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
    let $target := map:get($params, "target")
    let $Id := map:get($params, "id")
    let $format := map:get($params, "format")
    let $results := 
      if ($target = "person") then rel:getPersonRelationship($Id, $format)
      else if ($target = "case") then rel:getCaseRelationshipRDF($Id)
      else if ($format = "json" and $target = "case") then rel:getCaseRelationship($Id)
      else json:object()
    (: return xdmp:to-json($results)    :)
    return $results
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
