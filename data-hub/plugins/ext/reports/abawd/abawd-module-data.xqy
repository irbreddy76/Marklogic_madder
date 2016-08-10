module namespace rep = "http://marklogic.com/md-dhr/report-modules";

declare function rep:getAbawdData(
   $source as xs:string,
   $contextId as xs:string,
   $contextIdValue as xs:string,
   $format as xs:string
) 
{
	let $docs := cts:search(/,cts:and-query((
		cts:collection-query($source),
		cts:json-property-value-query($contextId, $contextIdValue))
	  ))	  
	return $docs  
};