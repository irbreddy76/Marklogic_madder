module namespace ah = 'http://marklogic.com/address-helper';

declare namespace http = "xdmp:http";

declare variable $USERID as xs:string := "063000003894";
declare variable $VALIDATION_SERVICE_URI := "http://production.shippingapis.com/ShippingAPI.dll?API=Verify&amp;XML=";
declare variable $TRACE_LEVEL_TRACE := "ADDRESS-HELPER-TRACE";
declare variable $TRACE_LEVEL_DETAIL := "ADDRESS-HELPER-DETAIL";

declare function ah:validate-address($street as xs:string?, $city as xs:string?, $state as xs:string?, $zip as xs:string?,
  $zip-ext as xs:string?) as element(Address)? {
  let $_ := (
    fn:trace("validate-address -- CALLED", $TRACE_LEVEL_TRACE),
    fn:trace(fn:concat(" -- Param: street=", $street), $TRACE_LEVEL_DETAIL),
    fn:trace(fn:concat(" -- Param: city=", $city), $TRACE_LEVEL_DETAIL),
    fn:trace(fn:concat(" -- Param: state=", $state), $TRACE_LEVEL_DETAIL),
    fn:trace(fn:concat(" -- Param: zip=", $zip), $TRACE_LEVEL_DETAIL),
    fn:trace(fn:concat(" -- Param: zip-ext=", $zip-ext), $TRACE_LEVEL_DETAIL)
  )
  return 
    if(fn:empty($street) or (fn:empty($city) and fn:empty($state)) or fn:empty($zip)) then ()
    else
      let $results := xdmp:http-get(
        fn:concat($VALIDATION_SERVICE_URI, 
          xdmp:url-encode(xdmp:quote(ah:build-request($street, $city, $state, $zip, $zip-ext)))
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
                <LocationStreet>{fn:lower-case($response/Address/Address2/fn:string(.))}</LocationStreet>
                <LocationCityName>{fn:lower-case($response/Address/City/fn:string(.))}</LocationCityName>
                <LocationStateName>{fn:lower-case($response/Address/State/fn:string(.))}</LocationStateName>
                <LocationPostalCode>{$response/Address/Zip5/fn:string(.)}</LocationPostalCode>
                <LocationPostalCodeExtension>{$response/Address/Zip4/fn:string(.)}</LocationPostalCodeExtension>
              </Address>            
      else (
        xdmp:log(fn:concat("Unexepected service error for validate-address: ", xdmp:quote($results[1])), "error"),
        xdmp:log(xdmp:quote(xdmp:binary-decode($results[2], "UTF-8")), "error")
      )
};

declare function ah:build-request($street as xs:string, $city as xs:string?, $state as xs:string?, $zip as xs:string?,
  $zip-ext as xs:string?) as element(AddressValidateRequest) {
  <AddressValidateRequest USERID="{$USERID}">
    <Address>
      <Address1>{$street}</Address1>
      <Address2/>
      <City>{$city}</City>
      <State>{$state}</State>
      <Zip5>{$zip}</Zip5>
      <Zip4>{$zip-ext}</Zip4>
    </Address>
  </AddressValidateRequest>
};