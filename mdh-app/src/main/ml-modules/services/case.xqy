xquery version "1.0-ml";

module namespace resource = "http://marklogic.com/rest-api/resource/case";

import module namespace cm = "http://marklogic.com/case-matcher" at
  "/lib/case-matcher-lib.xqy";

declare function get(
  $context as map:map,
  $params  as map:map
  ) as document-node()*
{
  try {
    map:put($context, "output-types", "application/json"),
    xdmp:set-response-code(200, "Ok"),
    let $target := map:get($params, "target")
    let $result := 
      if($target = ("case", "personParticipation")) then cm:algorithm-new($params, map:map())
      else cm:get-query($params, map:map(), "json")
    return xdmp:to-json($result)
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
    let $config := (xdmp:from-json($input[1]), map:map())[1]
    let $result := 
      if($target = "case") then cm:algorithm-new($params, $config)
      else cm:get-query($params, $config, "json")
    return xdmp:to-json($result)
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
