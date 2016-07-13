xquery version "1.0-ml";

module namespace mlcpFlow = "http://marklogic.com/data-hub/mlcp-flow-transform";

import module namespace bin = "http://marklogic.com/process-binary"
  at "/lib/binary/processBinary.xqy";

import module namespace flow = "http://marklogic.com/data-hub/flow-lib"
  at "/com.marklogic.hub/lib/flow-lib.xqy";

import module namespace perf = "http://marklogic.com/data-hub/perflog-lib"
  at "/com.marklogic.hub/lib/perflog-lib.xqy";

import module namespace trace = "http://marklogic.com/data-hub/trace"
  at "/com.marklogic.hub/lib/trace-lib.xqy";

declare namespace hub = "http://marklogic.com/data-hub";

declare option xdmp:mapping "false";

declare function mlcpFlow:transform(
  $content as map:map,
  $context as map:map
) as map:map*
{
  let $uri := map:get($content, "uri")
  return
    perf:log('mlcp-flow-transform(' || $uri || ')', function() {
      let $paramNodes := xdmp:unquote(map:get($context, 'transform_param'))/node()/*
      let $paramMap := map:new()
      let $_ := $paramNodes ! map:put($paramMap, fn:local-name(.), ./string())

      let $flow := flow:get-flow(
        map:get($paramMap, 'entity-name'),
        map:get($paramMap, 'flow-name'),
        map:get($paramMap, 'flow-type'))

      let $data := map:get($content, "value")
      let $envelope := try {
          let $metadata := bin:processBinary($uri, $data, $flow/hub:data-format)
          let $_ := map:put($content, "uri", fn:concat($uri, "/metadata.",
            if($flow/hub:data-format = "application/json") then "json"
            else "xml"))
          return flow:run-plugins($flow, $uri, $metadata, $paramMap)
      }
      catch($ex) {
        xdmp:log(xdmp:describe($ex, (), ())),
        xdmp:rethrow()
      }
      let $_ := map:put($content, "value", $envelope)
      let $_ :=
        if (trace:enabled()) then
          trace:plugin-trace(
            $uri,
            if ($envelope instance of element()) then ()
            else
              null-node {},
            "writer",
            $flow/hub:type,
            $envelope,
            if ($envelope instance of element()) then ()
            else
              null-node {},
            xs:dayTimeDuration("PT0S")
          )
        else ()
      let $_ := trace:write-trace()
      return
        $content
    })
};

