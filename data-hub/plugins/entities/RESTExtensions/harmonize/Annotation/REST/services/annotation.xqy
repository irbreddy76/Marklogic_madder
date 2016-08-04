xquery version "1.0-ml";

module namespace resource = "http://marklogic.com/rest-api/resource/annotation";

import module namespace an = "http://www.dhr.state.md.us/datalake/annotation" at
  "/lib/annotation-lib.xqy";

declare namespace rapi = "http://marklogic.com/rest-api";

declare function get(
  $context as map:map,
  $params  as map:map
  ) as document-node()*
{
  try {
    let $results := an:getAnnotation($params)
    let $array := json:to-array($results)
    let $json := json:object()
    let $_ := (
      map:put($json, "annotations", $array),
      map:put($json, "count", fn:count($results)),
      map:put($json, "params", $params)
    )
    return (
      xdmp:set-response-code(200, "OK"),
      map:put($context, "output-types", "application/json"),
      xdmp:to-json($json)
    )  
  } catch ($e) {
    fn:error((),"RESTAPI-SRVEXERR", (500, "Internal Server Error", 
     "An unexpected error has occurred"))
  }
};

declare function put(
  $context as map:map,
  $params  as map:map,
  $input   as document-node()*
  ) as document-node()?
{
  post($context, $params, $input)
};

declare 
%rapi:transaction-mode("update") 
function post(
  $context as map:map,
  $params  as map:map,
  $input   as document-node()*
  ) as document-node()*
{
  try {
    let $annotation-params := 
      if(fn:empty($input)) then $params
      else xdmp:from-json($input[1])
    let $results := an:addAnnotation($annotation-params)
    let $array := json:to-array($results)
    let $json := json:object()
    let $_ := (
      map:put($json, "results", $array),
      map:put($json, "count", fn:count($results)),
      map:put($json, "params", $params)
    )
    return (
      xdmp:set-response-code(200, "OK"),
      map:put($context, "output-types", "application/json"),
      xdmp:to-json($json)
    )
  } catch($e) {
    fn:error((),"RESTAPI-SRVEXERR", (500, "Internal Server Error", 
     "An unexpected error has occurred"))
  } 
};

declare function delete(
  $context as map:map,
  $params  as map:map
  ) as document-node()?
{
  fn:error((), "RESTAPI-SRVEXERR", (405, "Method Not Allowed", "DELETE is not implemented"))
};
