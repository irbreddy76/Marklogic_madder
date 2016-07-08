xquery version "1.0-ml";
module namespace img="http://marklogic.com/mdh-app/transform/image-xform";

import module namespace sem = "http://marklogic.com/semantics" at "/MarkLogic/semantics.xqy";
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";
declare namespace mdh-meta="http://marklogic.com/meta";
declare namespace mdh-doc="http://marklogic.com/document";
declare namespace html = "http://www.w3.org/1999/xhtml";

declare function img:getImportedDate($uri as xs:string) as xs:dateTime
{
	let $filename := fn:substring-before(fn:tokenize($uri, "/")[last()], ".")
	let $dateTokens := fn:tokenize($filename, "_")
	(: CHESSIE ID :)
	let $id := $dateTokens[1]
	(: Date format from filename is Month_DAY_YEAR_HOURS_MINUTES_SECONDS_MILLISECONDS :)
	let $year :=  $dateTokens[4]
	let $month := functx:pad-integer-to-length( $dateTokens[2], 2 )
	let $day := functx:pad-integer-to-length( $dateTokens[3], 2 )   
	let $hour := functx:pad-integer-to-length( $dateTokens[5], 2 )
	let $mins := functx:pad-integer-to-length( $dateTokens[6], 2 )   
	let $secs := functx:pad-integer-to-length( $dateTokens[7], 2 )
	let $dateTime := 
		xs:dateTime( fn:concat( $year,"-",$month,"-",$day,"T",$hour,":",$mins,":",$secs, ".", $dateTokens[8]) )	
	return $dateTime
};

declare function img:getSourceId($uri as xs:string) as xs:string
{
	let $filename := fn:substring-before(fn:tokenize($uri, "/")[last()], ".")
	let $dateTokens := fn:tokenize($filename, "_")
	(: CHESSIE ID :)
	return $dateTokens[1] 
};

declare function img:extract($uri as xs:string, $doc, $source as xs:string)
{
(: let $uri := "/tmp/SAMPLE_IMAGES/1291293_08_07_2014_12_12_59_000000.jpg" :)
(: let $doc := xdmp:document-get($uri) :)
(: let $doc := fn:doc($uri) :)
let $meta := xdmp:document-filter($doc)
let $meta-map := map:new()
let $importedDate := img:getImportedDate($uri)
let $id := img:getSourceId($uri)

let $meta-temp := 
  for $tag in $meta/html:html/html:head/html:meta
  return $tag/@name/fn:string(.) || ":" || $tag/@content/fn:string(.)

let $meta-data := for $tag in $meta/html:html/html:head/html:meta
					return 
						element {$tag/@name/fn:string(.)} { $tag/@content/fn:string(.) }
let $_ := 
  (: Parse Metadata tags to JSON here :)
		map:put($meta-map, "value", document {
			element mdh-doc:document {
				element mdh-meta:meta {
					$meta-data,
					element imported-date { $importedDate },
					element source-id { $id }
				}				
			}
		})
let $_ := xdmp:log(map:get($meta-map, "value"))

let $filename := fn:substring-before(fn:tokenize($uri, "/")[last()], ".") 
let $metaFileName := fn:concat("/person/",$source,"/",$id,"/images/",$filename,"-metadata.xml")
let $_ := xdmp:log($metaFileName)

return 
  try {
        xdmp:document-insert( $metaFileName, map:get($meta-map, "value"),
                                xdmp:default-permissions(),
                                ( xdmp:default-collections(), "source (CHESSIE)", "Image" )
                            )
        } catch ($e) 
		{
			"Failed: " || fn:string($e)
        }
};

declare function img:transform(
  $content as map:map,
  $context as map:map
) as map:map*
{
	let $doc := map:get($content, 'value')
    let $uri := map:get($content, 'uri')
	let $_ := xdmp:log($uri)
	let $_ := img:extract($uri, $doc, "CHESSIE")
	return ($content)
};