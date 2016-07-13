xquery version "1.0-ml";

declare variable $params as map:map external;

let $permissions := map:get($params, "permissions")
let $collections := map:get($params, "collections")
return (
  xdmp:document-insert(map:get($params, "metadata-uri"),
    map:get($params, "metadata"), $permissions,
    ($collections, "metadata")),
  xdmp:document-insert(map:get($params, "binary-uri"),
    map:get($params, "binary"), $permissions,
    ($collections, "image"))
)
