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
    else if($type = "PersonParticipation") then s:buildPersonParticipation($header, $content)
    else if($type = "Person") then s:buildPerson($header, $content)
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

declare function s:buildPersonParticipation($header as map:map, $content as map:map) {
  let $json := json:object()
  let $ids := map:get($header, "SystemIdentifiers")
  let $personId := (map:get($ids, "cisId"), map:get($ids,"chessieId"))[1]
  let $name := map:get($header, "PersonPrimaryName")
  let $cases := map:get($header, "ParticipationIdentifiers")
  let $person := map:get($content, "Person")
  let $_ := (
    map:put($json, "recordType", "PersonParticipation"),
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