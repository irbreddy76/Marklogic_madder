xquery version "1.0-ml";

module namespace plugin = "http://marklogic.com/data-hub/plugins";

import module namespace config = "http://marklogic.com/data-hub/config"
  at "/com.marklogic.hub/lib/config.xqy";

import module namespace fx = "http://www.functx.com"
  at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

declare namespace envelope = "http://marklogic.com/data-hub/envelope";

declare option xdmp:mapping "false";

(:~
 : Create Content Plugin
 :
 : @param $id          - the identifier returned by the collector
 : @param $options     - a map containing options. Options are sent from Java
 :
 : @return - your transformed content
 :)
declare function plugin:create-content(
  $id as xs:string,
  $options as map:map) as node()?
{
  let $_ := xdmp:log("content -- id: " || $id)
  let $json := json:object()
  let $base-uri := "/person/chessie/" || $id || "/images/"
  let $image-array := json:array()
  let $_ :=
    for $metadata in cts:search(fn:doc(),
      cts:and-query(( 
        cts:json-property-value-query("chessieId", $id),
        cts:and-not-query(
          cts:collection-query("CHESSIEPersonImage"),
          cts:collection-query("processed")
        ) 
      ))
    )
    let $metadata-json := xdmp:from-json($metadata)
    let $content := map:get($metadata-json, "content")
    let $original-uri := map:get($content, "original")
    let $binary := fn:doc($original-uri)
    let $filename := fn:tokenize($original-uri, "/")[last()]
    let $image-uri := fn:concat($base-uri, fn:substring-before($filename, "."), 
      "/image.", fn:substring-after($filename, "."))
    let $_ := map:put($content, "imageUri", $image-uri)
    let $_ := map:put($metadata-json, "content", $content)
    let $metadata-uri := fn:concat($base-uri, 
      fn:substring-before($filename, "."), "/metadata.json")
    let $_ := (
      xdmp:invoke("/lib/binary/loadImage.xqy", (xs:QName("params"),
        map:new((
          map:entry("metadata-uri", $metadata-uri),
          map:entry("metadata", xdmp:to-json($metadata-json)),
          map:entry("binary-uri", $image-uri),
          map:entry("binary", $binary),
          map:entry("collections", ("PersonImage", "CHESSIE")),
          map:entry("permissions", (
            xdmp:permission("rest-reader", "read"),
            xdmp:permission("rest-writer", "update")
          ))
        ))),
        map:new((
          map:entry("isolation", "different-transaction"),
          map:entry("database", xdmp:database($config:FINAL-DATABASE)),
          map:entry("transactionMode", "update-auto-commit")
        ))
      ),
      xdmp:document-add-collections(fn:document-uri($metadata), "processed")
      
    )
    let $loadDate := 
      let $parts := fn:tokenize($filename, "_")
      return fx:dateTime($parts[4], $parts[2] ,$parts[3],
        $parts[5], $parts[6], $parts[7])
    let $content := map:get($metadata-json, "content")
    let $image-json := json:object()
    let $master-image := json:object()
    let $image-metadata := json:object()
    let $dimensions := json:object()
    let $wxh := fn:tokenize(map:get($content, "Dimensions"), "x")
    let $_ := (
      map:put($master-image, "filepath", $image-uri),
      map:put($master-image, "format", map:get($content, "Image_Format")),
      map:put($dimensions, "height", fn:concat(fn:normalize-space($wxh[2]), "px")),
      map:put($dimensions, "width", fn:concat(fn:normalize-space($wxh[1]), "px")),
      map:put($dimensions, "resolution", fn:concat(
        (map:get($content, "XResolution"), map:get($content, "YResolution"))[1], "dpi")),
      map:put($image-metadata, "filename", $filename),
      map:put($image-metadata, "metadata", $metadata-uri),
      map:put($image-metadata, "loadDate", $loadDate),
      map:put($master-image, "dimensions", $dimensions),
      map:put($image-json, "masterImage", $master-image),
      map:put($image-json, "metadata", $image-metadata)
    )
    return json:array-push($image-array, $image-json)
  let $_ := map:put($json, "images", $image-array)
  return xdmp:to-json($json)
};
