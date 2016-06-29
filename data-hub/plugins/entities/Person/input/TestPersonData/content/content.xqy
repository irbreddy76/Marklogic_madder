xquery version "1.0-ml";

module namespace plugin = "http://marklogic.com/data-hub/plugins";

declare namespace envelope = "http://marklogic.com/data-hub/envelope";

declare option xdmp:mapping "false";

(:~
 : Create Content Plugin
 :
 : @param $id          - the identifier returned by the collector
 : @param $raw-content - the raw content being loaded.
 : @param $options     - a map containing options. Options are sent from Java
 :
 : @return - your transformed content
 :)
declare function plugin:create-content(
  $id as xs:string,
  $raw-content as node()?,
  $options as map:map) as node()?
{
   $raw-content
(: 
  let $json := json:object()
  let $_ := (
    let $name := json:object()
    let $_ := (
      map:put($name, "PersonGivenName", $raw-content//PersonGivenName/fn:string(.)),
      if($raw-content//PersonMiddleName) then 
        map:put($name, "PersonMiddleName", $raw-content//PersonMiddleName/fn:string(.))
      else (),
      map:put($name, "PersonSurName", $raw-content//PersonSurName/fn:string(.)),
      if($raw-content//PersonMaidenName) then
        map:put($name, "PersonMaidenName", $raw-content//PersonMaidenName/fn:string(.))
      else ()
    )
    let $ssn := json:object()
    let $_ := (
      map:put($ssn, "IdentificationID", $raw-content//IdentificationID/fn:string(.))
    )
    let $address := json:object()
    let $_ := (
      map:put($address, "LocationStreet", $raw-content//LocationStreet/fn:string(.)),
      map:put($address, "LocationCityName", $raw-content//LocationCityName/fn:string(.)),
      map:put($address, "LocationStateName", $raw-content//LocationStateName/fn:string(.)),
      map:put($address, "LocationPostalCode", $raw-content//LocationPostalCode/fn:string(.)),
      if($raw-content//LocationPostalCodeExtension) then 
        map:put($address, "LocationPostalCodeExtention", $raw-content//LocationPostalCodeExtension/fn:string(.))
      else ()
    )
    let $_ := (
      map:put($json, "PersonName", $name),
      map:put($json, "PersonSexCode", $raw-content//PersonSexCode/fn:string(.)),
      map:put($json, "ContactEmailId", $raw-content//ContactEmailId/fn:string(.)),
      map:put($json, "FullTelephoneNumber", $raw-content//FullTelephoneNumber/fn:string(.)),
      map:put($json, "Address", $address),
      map:put($json, "SSNIdentification", $ssn),
      map:put($json, "PersonBirthDate", $raw-content//PersonBirthDate/fn:string(.))
    )
    return ()
  )
  return $json :)
};
