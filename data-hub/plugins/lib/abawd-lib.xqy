
module namespace abawd-lib = "http://marklogic.com/md-dhr/abawd-lib";

import module namespace qh = 'http://marklogic.com/query-helper' at  '/lib/query-helper.xqy';

declare function abawd-lib:not-q($query as item()?) {
  let $not-query := json:object()
  let $_ :=  map:put($not-query, "not-query", $query)
  return $not-query
};

declare function abawd-lib:and-q($queries as item()*) {
  let $and-query := json:object()
  let $json-queries := json:object()
  let $_ :=  (
    map:put($json-queries, "queries", qh:build-array($queries)),
    map:put($and-query, "and-query", $json-queries)
  )
  return $and-query
};

declare function abawd-lib:or-q($queries as item()*) {
  let $or-query := json:object()
  let $json-queries := json:object()
  let $_ :=  (
    map:put($json-queries, "queries", qh:build-array($queries)),
    map:put($or-query, "or-query", $json-queries)
  )
  return $or-query
};

declare function abawd-lib:get-abawd-structured-query($cert-period as xs:string) as item()? {

  let $ageQuery := abawd-lib:and-q((
      qh:range-q("PersonBirthDate", xs:date(fn:current-date() - xs:yearMonthDuration("P18Y")), "<", (), 8, $qh:OUTPUT_JSON, "date", ()),
      qh:range-q("PersonBirthDate", xs:date(fn:current-date() - xs:yearMonthDuration("P50Y")), ">", (), 8, $qh:OUTPUT_JSON, "date", ())
  ))

  let $pregQuery := abawd-lib:not-q(qh:range-q("PregnancyDueDate", xs:date(fn:current-date()), ">=", (), 8, $qh:OUTPUT_JSON, "date", ()))

  let $doQuery := abawd-lib:or-q((
      qh:value-q("DONum", "20", (), 8, $qh:OUTPUT_JSON, "string"), qh:value-q("DONum", "100", (), 8, $qh:OUTPUT_JSON, "string"),
      qh:value-q("DONum", "21", (), 8, $qh:OUTPUT_JSON, "string"), qh:value-q("DONum", "130", (), 8, $qh:OUTPUT_JSON, "string"),
      qh:value-q("DONum", "22", (), 8, $qh:OUTPUT_JSON, "string"), qh:value-q("DONum", "150", (), 8, $qh:OUTPUT_JSON, "string"),
      qh:value-q("DONum", "30", (), 8, $qh:OUTPUT_JSON, "string"), qh:value-q("DONum", "151", (), 8, $qh:OUTPUT_JSON, "string"),
      qh:value-q("DONum", "31", (), 8, $qh:OUTPUT_JSON, "string"), qh:value-q("DONum", "152", (), 8, $qh:OUTPUT_JSON, "string"),
      qh:value-q("DONum", "32", (), 8, $qh:OUTPUT_JSON, "string"), qh:value-q("DONum", "154", (), 8, $qh:OUTPUT_JSON, "string"),
      qh:value-q("DONum", "33", (), 8, $qh:OUTPUT_JSON, "string"), qh:value-q("DONum", "160", (), 8, $qh:OUTPUT_JSON, "string"),
      qh:value-q("DONum", "34", (), 8, $qh:OUTPUT_JSON, "string"), qh:value-q("DONum", "161", (), 8, $qh:OUTPUT_JSON, "string"),
      qh:value-q("DONum", "36", (), 8, $qh:OUTPUT_JSON, "string"), qh:value-q("DONum", "162", (), 8, $qh:OUTPUT_JSON, "string"),
      qh:value-q("DONum", "60", (), 8, $qh:OUTPUT_JSON, "string"), qh:value-q("DONum", "210", (), 8, $qh:OUTPUT_JSON, "string")
  ))

  let $livingArrgmnt := abawd-lib:and-q((
      abawd-lib:not-q(qh:value-q("PersonLivingArrangementTypeCode", "HL", (), 8, $qh:OUTPUT_JSON, "string")),
      abawd-lib:not-q(qh:value-q("PersonLivingArrangementTypeCode", "RR", (), 8, $qh:OUTPUT_JSON, "string")),
      abawd-lib:not-q(qh:value-q("PersonLivingArrangementTypeCode", "LD", (), 8, $qh:OUTPUT_JSON, "string"))
    ))

  (:Update to iterate through list checking date, confirm with customer if we should check end date :)
  let $disability := abawd-lib:or-q((
      qh:value-q("DisabilityTypeCode", "", (), 8, $qh:OUTPUT_JSON, "string"),
      qh:value-q("DisabilityTypeCode", "-", (), 8, $qh:OUTPUT_JSON, "string"),
      qh:value-q("DisabilityTypeCode", "U", (), 8, $qh:OUTPUT_JSON, "string")
  ))

  (:
  let $disability := abawd-lib:or-q((
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "A", (), 8, $qh:OUTPUT_JSON, "string")),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "B", (), 8, $qh:OUTPUT_JSON, "string"),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "C", (), 8, $qh:OUTPUT_JSON, "string"),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "D", (), 8, $qh:OUTPUT_JSON, "string"),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "E", (), 8, $qh:OUTPUT_JSON, "string"),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "F", (), 8, $qh:OUTPUT_JSON, "string"),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "G", (), 8, $qh:OUTPUT_JSON, "string"),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "H", (), 8, $qh:OUTPUT_JSON, "string"),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "I", (), 8, $qh:OUTPUT_JSON, "string"),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "J", (), 8, $qh:OUTPUT_JSON, "string"),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "K", (), 8, $qh:OUTPUT_JSON, "string"),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "L", (), 8, $qh:OUTPUT_JSON, "string"),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "M", (), 8, $qh:OUTPUT_JSON, "string"),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "N", (), 8, $qh:OUTPUT_JSON, "string"),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "O", (), 8, $qh:OUTPUT_JSON, "string"),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "P", (), 8, $qh:OUTPUT_JSON, "string"),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "R", (), 8, $qh:OUTPUT_JSON, "string"),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "S", (), 8, $qh:OUTPUT_JSON, "string"),
      abawd-lib:not-q(qh:value-q("DisabilityTypeCode", "T", (), 8, $qh:OUTPUT_JSON, "string")
    ))
  )
  :)

  let $finalQuery := abawd-lib:and-q((
      $ageQuery,
      $pregQuery,
      $doQuery,
      $livingArrgmnt,
      $disability
  ))

  return $finalQuery
};

declare function abawd-lib:get-abawd-query($cert-period as xs:string) as item()? {
  let $ageQuery := cts:and-query((
    cts:json-property-range-query("PersonBirthDate", "<", xs:date(fn:current-date() - xs:yearMonthDuration("P18Y"))),
    cts:json-property-range-query("PersonBirthDate", ">", xs:date(fn:current-date() - xs:yearMonthDuration("P50Y")))
    ))

  (:load these values into a document:)
  (: These disctricts are not exempt from ABAWD :)
  let $doQuery := cts:or-query((
      cts:json-property-value-query("DONum", "20"),cts:json-property-value-query("DONum", "100"),
      cts:json-property-value-query("DONum", "21"),cts:json-property-value-query("DONum", "130"),
      cts:json-property-value-query("DONum", "22"),cts:json-property-value-query("DONum", "150"),
      cts:json-property-value-query("DONum", "30"),cts:json-property-value-query("DONum", "151"),
      cts:json-property-value-query("DONum", "31"),cts:json-property-value-query("DONum", "152"),
      cts:json-property-value-query("DONum", "32"),cts:json-property-value-query("DONum", "154"),
      cts:json-property-value-query("DONum", "33"),cts:json-property-value-query("DONum", "160"),
      cts:json-property-value-query("DONum", "34"),cts:json-property-value-query("DONum", "161"),
      cts:json-property-value-query("DONum", "36"),cts:json-property-value-query("DONum", "162"),
      cts:json-property-value-query("DONum", "60"),cts:json-property-value-query("DONum", "210")
    ))

  (:let $pregQuery := cts:json-property-range-query("PregnancyDueDate", "<", xs:date(fn:current-date() - xs:yearMonthDuration("P1Y"))):)
  let $pregQuery := cts:json-property-range-query("PregnancyDueDate", "&lt;", xs:date(fn:current-date()))

  (: We do not have special circumstances field in our data below should be ANDed with this field/value of "HO" :)
  let $chronicallyHomeless := cts:not-query(cts:json-property-value-query("PersonLivingArrangementTypeCode", "HL"))

  let $rehabHouse := cts:not-query(cts:json-property-value-query("PersonLivingArrangementTypeCode", "RR"))
  let $domHouse := cts:not-query(cts:json-property-value-query("PersonLivingArrangementTypeCode", "LD"))

  (:Update to iterate through list checking date, confirm with customer if we should check end date :)
  let $disability := cts:not-query(cts:or-query((
      cts:json-property-word-query("DisabilityTypeCode", "A"),
      cts:json-property-word-query("DisabilityTypeCode", "B"),
      cts:json-property-word-query("DisabilityTypeCode", "C"),
      cts:json-property-word-query("DisabilityTypeCode", "D"),
      cts:json-property-word-query("DisabilityTypeCode", "E"),
      cts:json-property-word-query("DisabilityTypeCode", "F"),
      cts:json-property-word-query("DisabilityTypeCode", "G"),
      cts:json-property-word-query("DisabilityTypeCode", "H"),
      cts:json-property-word-query("DisabilityTypeCode", "I"),
      cts:json-property-word-query("DisabilityTypeCode", "J"),
      cts:json-property-word-query("DisabilityTypeCode", "K"),
      cts:json-property-word-query("DisabilityTypeCode", "L"),
      cts:json-property-word-query("DisabilityTypeCode", "M"),
      cts:json-property-word-query("DisabilityTypeCode", "N"),
      cts:json-property-word-query("DisabilityTypeCode", "O"),
      cts:json-property-word-query("DisabilityTypeCode", "P"),
      cts:json-property-word-query("DisabilityTypeCode", "R"),
      cts:json-property-word-query("DisabilityTypeCode", "S"),
      cts:json-property-word-query("DisabilityTypeCode", "T"))
  ))

  return
    cts:and-query((
        cts:collection-query($cert-period),
        $ageQuery,
        $doQuery,
        $pregQuery,
        $chronicallyHomeless,
        $rehabHouse,
        $domHouse,
        $disability
      ))
};

declare function abawd-lib:get-potential-abawds($cert-period as xs:string) as xs:string* {

  let $query := abawd-lib:get-abawd-query($cert-period)

  return
  cts:uris((),(), $query)
};

(:Not used anymore since we are summing the income during harmonization:)
declare function abawd-lib:calc-earned-income($uri as xs:string, $incomeTypeCode as xs:string) as xs:double {

  (: Weekly :)
  let $weEarnedIncome := cts:sum-aggregate(cts:json-property-reference("IncomeAmount"), (), cts:and-query((
      cts:document-query($uri),
      cts:json-property-value-query("IncomeTypeCode", $incomeTypeCode),
      cts:json-property-value-query("IncomeFrequencyCode", "WE")
    ))
  )

  (: Bi Weekly :)
  let $bwEarnedIncome := cts:sum-aggregate(cts:json-property-reference("IncomeAmount"), (), cts:and-query((
      cts:document-query($uri),
      cts:json-property-value-query("IncomeTypeCode", $incomeTypeCode),
      cts:json-property-value-query("IncomeFrequencyCode", "BW")
    ))
  )

  (: Bi Monthly :)
  let $bmEarnedIncome := cts:sum-aggregate(cts:json-property-reference("IncomeAmount"), (), cts:and-query((
      cts:document-query($uri),
      cts:json-property-value-query("IncomeTypeCode", $incomeTypeCode),
      cts:json-property-value-query("IncomeFrequencyCode", "BM")
    ))
  )

  (: Quarterly :)
  let $quEarnedIncome := cts:sum-aggregate(cts:json-property-reference("IncomeAmount"), (), cts:and-query((
      cts:document-query($uri),
      cts:json-property-value-query("IncomeTypeCode", $incomeTypeCode),
      cts:json-property-value-query("IncomeFrequencyCode", "QU")
    ))
  )

  (: Annual :)
  let $anEarnedIncome := cts:sum-aggregate(cts:json-property-reference("IncomeAmount"), (), cts:and-query((
      cts:document-query($uri),
      cts:json-property-value-query("IncomeTypeCode", $incomeTypeCode),
      cts:json-property-value-query("IncomeFrequencyCode", "AN")
    ))
  )

  (: Semi Annual :)
  let $saEarnedIncome := cts:sum-aggregate(cts:json-property-reference("IncomeAmount"), (), cts:and-query((
      cts:document-query($uri),
      cts:json-property-value-query("IncomeTypeCode", $incomeTypeCode),
      cts:json-property-value-query("IncomeFrequencyCode", "SA")
    ))
  )

  (: Actual :)
  let $acEarnedIncome := cts:sum-aggregate(cts:json-property-reference("IncomeAmount"), (), cts:and-query((
      cts:document-query($uri),
      cts:json-property-value-query("IncomeTypeCode", $incomeTypeCode),
      cts:json-property-value-query("IncomeFrequencyCode", "AC")
    ))
  )

  (: One Time :)
  let $otEarnedIncome := cts:sum-aggregate(cts:json-property-reference("IncomeAmount"), (), cts:and-query((
      cts:document-query($uri),
      cts:json-property-value-query("IncomeTypeCode", $incomeTypeCode),
      cts:json-property-value-query("IncomeFrequencyCode", "OT")
    ))
  )

  return ($weEarnedIncome * 4)
    + ($bwEarnedIncome * 2)
    + ($bmEarnedIncome div 2)
    + ($quEarnedIncome div 3)
    + ($anEarnedIncome div 12)
    + ($saEarnedIncome div 6)
    + $acEarnedIncome
    + $otEarnedIncome
};

(:Not used anymore since we are summing the income during harmonization:)
declare function abawd-lib:calc-work-hours($uri as xs:string, $incomeTypeCode as xs:string) as xs:double {

  (: Weekly :)
  let $weWorkHours := cts:sum-aggregate(cts:json-property-reference("IncomeWorkHoursNumber"), (), cts:and-query((
      cts:document-query($uri),
      cts:json-property-value-query("IncomeTypeCode", $incomeTypeCode),
      cts:json-property-value-query("IncomeFrequencyCode", "WE")
    ))
  )

  (: Bi Weekly :)
  let $bwWorkHours := cts:sum-aggregate(cts:json-property-reference("IncomeWorkHoursNumber"), (), cts:and-query((
      cts:document-query($uri),
      cts:json-property-value-query("IncomeTypeCode", $incomeTypeCode),
      cts:json-property-value-query("IncomeFrequencyCode", "BW")
    ))
  )

  (: Bi Monthly :)
  let $bmWorkHours := cts:sum-aggregate(cts:json-property-reference("IncomeWorkHoursNumber"), (), cts:and-query((
      cts:document-query($uri),
      cts:json-property-value-query("IncomeTypeCode", $incomeTypeCode),
      cts:json-property-value-query("IncomeFrequencyCode", "BM")
    ))
  )

  (: Quarterly :)
  let $quWorkHours := cts:sum-aggregate(cts:json-property-reference("IncomeWorkHoursNumber"), (), cts:and-query((
      cts:document-query($uri),
      cts:json-property-value-query("IncomeTypeCode", $incomeTypeCode),
      cts:json-property-value-query("IncomeFrequencyCode", "QU")
    ))
  )

  (: Annual :)
  let $anWorkHours := cts:sum-aggregate(cts:json-property-reference("IncomeWorkHoursNumber"), (), cts:and-query((
      cts:document-query($uri),
      cts:json-property-value-query("IncomeTypeCode", $incomeTypeCode),
      cts:json-property-value-query("IncomeFrequencyCode", "AN")
    ))
  )

  (: Semi Annual :)
  let $saWorkHours := cts:sum-aggregate(cts:json-property-reference("IncomeWorkHoursNumber"), (), cts:and-query((
      cts:document-query($uri),
      cts:json-property-value-query("IncomeTypeCode", $incomeTypeCode),
      cts:json-property-value-query("IncomeFrequencyCode", "SA")
    ))
  )

  (: Actual :)
  let $acWorkHours := cts:sum-aggregate(cts:json-property-reference("IncomeWorkHoursNumber"), (), cts:and-query((
      cts:document-query($uri),
      cts:json-property-value-query("IncomeTypeCode", $incomeTypeCode),
      cts:json-property-value-query("IncomeFrequencyCode", "AC")
    ))
  )

  (: One Time :)
  let $otWorkHours := cts:sum-aggregate(cts:json-property-reference("IncomeWorkHoursNumber"), (), cts:and-query((
      cts:document-query($uri),
      cts:json-property-value-query("IncomeTypeCode", $incomeTypeCode),
      cts:json-property-value-query("IncomeFrequencyCode", "OT")
    ))
  )

  return ($weWorkHours * 4)
    + ($bwWorkHours * 2)
    + ($bmWorkHours div 2)
    + ($quWorkHours div 3)
    + ($anWorkHours div 12)
    + ($saWorkHours div 6)
    + $acWorkHours
    + $otWorkHours
};
