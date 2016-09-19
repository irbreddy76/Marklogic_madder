module namespace s = "http://marklogic.com/md-dhr/search-extensions";

import module namespace search = "http://marklogic.com/appservices/search"
  at "/MarkLogic/appservices/search/search.xqy";

declare function s:buildSummary(
   $result as node(),
   $ctsquery as schema-element(cts:query),
   $options as element(search:transform-results)?
) as element(search:snippet) {
  let $json := xdmp:from-json($result)
  let $header := map:get($json, "headers")
  let $content := map:get($json, "content")
  let $type := map:get($header, "RecordType")
  let $summary :=
    if($type = "Case") then s:buildCase($header, $content)
    else if($type = "MasterPerson") then s:buildPersonParticipation($header, $content)
    else if($type = "Person") then s:buildPerson($header, $content)
    else if($type = "ABAWD") then s:buildABAWD($header, $content)
    else ()
  let $collections := xdmp:document-get-collections(fn:document-uri($result))
  let $_ :=
    if("CHESSIE" = $collections) then
      map:put($summary, "sourceSystem", "CHESSIE")
    else if("CARES" = $collections) then
      map:put($summary, "sourceSystem", "CARES")
    else ()
  let $jsonResult := json:object()
  let $_ := (
    map:put($jsonResult, "summary", $summary)
  )
  return
    <search:snippet format="json">
    {
      xdmp:to-json-string($jsonResult)
    }
    </search:snippet>
 };

declare function s:buildCase($header as map:map, $content as map:map) {
    let $summaryJson := json:object()
    let $caseType := map:get($header, "CaseType")
    let $ids := map:get($header, "ParticipationIds")
    let $caseId := (map:get($ids, "ServiceCaseId"), map:get($ids, "AdoptionPlanningId"))[1]
    let $_ := (
      map:put($summaryJson, "recordType", "Case"),
      map:put($summaryJson, "caseId", $caseId),
      map:put($summaryJson, "caseType", $caseType),
      map:put($summaryJson, "status", map:get($header, "status")),
      map:put($summaryJson, "program", map:get($content, "ParticipationProgramName")),
      map:put($summaryJson, "closeDate", map:get($content, "CloseDate")),
      map:put($summaryJson, "closeCode", map:get($content, "CloseCode"))
    )
    return $summaryJson
};

declare function s:buildPerson($header as map:map, $content as map:map) {
  let $json := json:object()
  let $name := map:get($header, "PersonPrimaryName")
  let $ids := map:get($header, "SystemIdentifiers")
  let $personId := (map:get($ids, "cisId"), map:get($ids,"chessieId"))[1]
  let $_ := (
    map:put($json, "recordType", "Person"),
    map:put($json, "personId", $personId),
    map:put($json, "firstName", map:get($name, "PersonGivenName")),
    map:put($json, "middleName", map:get($name, "PersonMiddleName")),
    map:put($json, "lastName", map:get($name, "PersonSurName")),
    map:put($json, "id", map:get($header, "SSNIdentificationId")),
    map:put($json, "gender", map:get($content, "PersonSexCode")),
    map:put($json, "race", map:get($content, "PersonRaceCode"))
  )
  return $json
};

declare function s:get-annotation-prop($props as item()*, $prop-name as xs:string) as item()* {
  let $value := for $property in json:array-values($props)
    return
      if (map:get($property, "name") = $prop-name) then
        map:get($property, "value")
      else ()
  return $value
};

declare function s:buildABAWD($header as map:map, $content as map:map) {
  let $json := json:object()
  let $name := map:get($header, "PersonPrimaryName")
  let $ids := map:get($header, "SystemIdentifiers")
  let $ssn := (map:get($content, "PersonSSNIdentification"))[1]

  let $abawd-status-annotation := map:get($content, "annotation-ABAWDStatus")
  let $abawd-status-annotation-hdr := map:get($abawd-status-annotation, "headers")
  let $abawd-status-annotation-props := map:get(map:get($abawd-status-annotation, "content"), "properties")

  let $abawd-action-annotation := map:get($content, "annotation-ABAWDAction")
  let $abawd-action-annotation-hdr := map:get($abawd-action-annotation, "headers")
  let $abawd-action-annotation-props := map:get(map:get($abawd-action-annotation, "content"), "properties")

  let $abawd-notification-annotation := map:get($content, "annotation-ABAWDNotification")
  let $abawd-notification-annotation-hdr := map:get($abawd-notification-annotation, "headers")
  let $abawd-notification-annotation-props := map:get(map:get($abawd-notification-annotation, "content"), "properties")


  let $LdssID := map:get($ids[1], "LdssID")
  let $DONum := map:get($ids[2], "DONum")
  let $personId := map:get($ids[3], "ClientID")
  let $AUNum := map:get($ids[4], "AUNum")

  let $address := (map:get($header, "Addresses"))[1]
  let $addressStr := map:get($address, "LocationStreet") || " " || map:get($address, "LocationCityName") || ", "
      || map:get($address, "LocationStateName") || " " || map:get($address, "LocationPostalCode")

  let $_ := (
    map:put($json, "recordType", "ABAWD"),

    map:put($json, "ldssID", $LdssID),
    map:put($json, "doNum", $DONum),
    map:put($json, "auNum", $AUNum),

    map:put($json, "personId", $personId),
    map:put($json, "firstName", map:get($name, "PersonGivenName")),
    map:put($json, "middleName", map:get($name, "PersonMiddleName")),
    map:put($json, "lastName", map:get($name, "PersonSurName")),
    map:put($json, "id", map:get($ssn, "IdentificationId")),
    map:put($json, "dob", map:get($content, "PersonBirthDate")),

    (: start adding here :)
    map:put($json, "hohCode", map:get($content, "PersonHOHCode")),
    map:put($json, "languageCode", map:get($content, "PersonLanguageCode")),
    map:put($json, "liveArrngmentCode", map:get($content, "PersonLivingArrangementTypeCode")),
    map:put($json, "summaryUnEIncome", map:get($content, "SummaryUnEarnedIncome")),
    map:put($json, "summaryEIncome", map:get($content, "SummaryEarnedIncome")),
    map:put($json, "pregnancyDueDate", map:get($content, "PregnancyDueDate")),
    map:put($json, "disability", map:get($content, "Disability")),
    map:put($json, "address", $addressStr),

    (: Need to update the below to get the current certification month/period :)
    map:put($json, "abawdScreeningStatusDate", map:get($abawd-status-annotation-hdr, "annotationDateTime")),
    map:put($json, "actualScreeningResult", s:get-annotation-prop($abawd-status-annotation-props, "actualScreeningResult")),

    map:put($json, "abawdActionStatusDate", map:get($abawd-action-annotation-hdr, "annotationDateTime")),
    map:put($json, "abawdAction", s:get-annotation-prop($abawd-action-annotation-props, "abawdAction")),

    map:put($json, "notificationDate", map:get($abawd-action-annotation-hdr, "annotationDateTime")),
    map:put($json, "notification", s:get-annotation-prop($abawd-action-annotation-props, "abawdAction"))

  )
  return $json
};


declare function s:buildPersonParticipation($header as map:map, $content as map:map) {
  let $json := json:object()
  let $ids := map:get($header, "SystemIdentifiers")
  let $personId := (map:get($ids, "cisId"), map:get($ids,"chessieId"))[1]
  let $name := map:get($header, "PersonPrimaryName")
  let $cases := map:get($header, "ParticipationIdentifiers")
  let $person := map:get(json:array-values(map:get($content, "records"))[1], "Person")
  let $_ := (
    map:put($json, "recordType", "MasterPerson"),
    map:put($json, "personId", $personId),
    map:put($json, "firstName", map:get($name, "PersonGivenName")),
    map:put($json, "middleName", map:get($name, "PersonMiddleName")),
    map:put($json, "lastName", map:get($name, "PersonSurName")),
    map:put($json, "id", map:get($header, "SSNIdentificationId")),
    map:put($json, "gender", map:get($person, "PersonSexCode")),
    map:put($json, "race", map:get($person, "PersonRaceCode")),
    map:put($json, "caseCount", fn:count(map:keys($cases))),
    map:put($json, "dob", map:get($person, "PersonBirthDate"))
  )
  return $json
};
