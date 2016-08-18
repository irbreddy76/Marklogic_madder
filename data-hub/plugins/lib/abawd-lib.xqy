
module namespace abawd-lib = "http://marklogic.com/md-dhr/abawd-lib";

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
