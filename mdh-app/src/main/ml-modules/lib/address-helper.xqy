module namespace ah = 'http://marklogic.com/address-helper';

import module namespace qh = 'http://marklogic.com/query-helper' at
  '/lib/query-helper.xqy';
  
declare namespace http = "xdmp:http";

declare variable $USERID as xs:string := "063000003894";
declare variable $VALIDATION_SERVICE_URI := "http://production.shippoingapis.com/ShippingAPI.dll?API=Verify&amp;XML=";
declare variable $TRACE_LEVEL_TRACE := "ADDRESS-HELPER-TRACE";
declare variable $TRACE_LEVEL_DETAIL := "ADDRESS-HELPER-DETAIL";

declare function ah:validate-address($street as xs:string, $city as xs:string, $state as xs:string, $zip as xs:string) {
  let $_ := (
    fn:trace("validate-address -- CALLED", $TRACE_LEVEL_TRACE),
    fn:trace(fn:concat(" -- Param: street=", $street), $TRACE_LEVEL_DETAIL),
    fn:trace(fn:concat(" -- Param: city=", $city), $TRACE_LEVEL_DETAIL),
    fn:trace(fn:concat(" -- Param: state=", $state), $TRACE_LEVEL_DETAIL),
    fn:trace(fn:concat(" -- Param: zip=", $zip), $TRACE_LEVEL_DETAIL)
  )
  let $results := xdmp:http-get(
    fn:concat($VALIDATION_SERVICE_URI, 
      xdmp:url-encode(xdmp:quote(ah:build-request($street, $city, $state, $zip)))
    )
  )
  return
    if($results/http:response/http:code = 200) then
      let $response := $results[2]/AddressValidateResponse
      return
        if($response/Address/Error) then
          xdmp:log(fn:concat("Address failed USPS validatation: ", xdmp:quote($response/Address/Error)), "error")
        else
          <Address>
            <LocationStreet>{$response/Address/Address2/fn:string(.)}</LocationStreet>
            <LocationCityName>{$response/Address/City/fn:string(.)}</LocationCityName>
            <LocationStateName>{$response/Address/State/fn:string(.)}</LocationStateName>
            <LocationPostalCode>{$response/Address/Zip5/fn:string(.)}</LocationPostalCode>
            <LocationPostalCodeExtension>{$response/Address/Zip4/fn:string(.)}</LocationPostalCodeExtension>
          </Address>            
    else (
      xdmp:log(fn:concat("Unexepected service error for validate-address: ", xdmp:quote($results[1])), "error"),
      xdmp:log(xdmp:quote(xdmp:binary-decode($results[2], "UTF-8")), "error")
    )
};

declare function ah:build-request($street as xs:string, $city as xs:string, $state as xs:string, $zip as xs:string) {
  <AddressValidateRequest USERID="{$USERID}">
    <Address>
      <Address1>{$street}</Address1>
      <Address2/>
      <City>{$city}</City>
      <State>{$state}</State>
      {     
        let $parts := fn:tokenize($zip, "-")
        return (
          <Zip5>{$parts[1]}</Zip5>,
          if(fn:count($parts) = 2) then 
            <Zip4>{$parts[2]}</Zip4>
          else <Zip4/>
        )
      }
    </Address>
  </AddressValidateRequest>
};

declare function ah:build-street-query($property as xs:string, $street as xs:string, $alternate as xs:string?,
  $weight as xs:double, $multiplier as xs:double) as cts:query* {
    qh:value-q($property, ($street, $alternate), (), $weight),
    let $parts := 
      for $part in fn:distinct-values((fn:tokenize($street, " "), fn:tokenize(fn:lower-case($alternate), " ")))
      where fn:string-length($part) > 0
      return $part
    return qh:word-q($property, $parts, (), $weight * $multiplier) 
};

declare function ah:build-citystate-query($property as xs:string, $citystate as xs:string, 
  $alternate as xs:string?, $weight as xs:double) as cts:query {
    qh:value-q($property, ($citystate, $alternate), (), $weight)
};

declare function ah:build-zip-query($property as xs:string, $part as xs:string?, $alternate as xs:string?,
  $weight as xs:double) as cts:query? {
    if(fn:empty(($part, $alternate))) then ()
    else qh:value-q($property, ($part, $alternate), (), $weight)
}; 