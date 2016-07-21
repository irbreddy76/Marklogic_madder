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
    let $caseId := map:get($params, "caseId")
    let $format := map:get($params, "format")
    let $results := 
      if(fn:empty($target) or fn:empty($caseId)) then json:object()
      else if ($format = "json") then rel:getCaseRelationship($caseId)
      else rel:getCaseRelationshipRDF($caseId)
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
    let $target := map:get($params, "target")
    let $caseId := map:get($params, "caseId")
    let $format := map:get($params, "format")
    let $results := 
      if(fn:empty($target) or fn:empty($caseId)) then json:object()
      else if ($format = "json") then rel:getCaseRelationship($caseId)
      else rel:getCaseRelationshipRDF($caseId)
    return xdmp:to-json($results)    
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
