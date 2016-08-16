/*
 * Create Content Plugin
 *
 * @param id         - the identifier returned by the collector
 * @param options    - an object containing options. Options are sent from Java
 *
 * @return - your content
 */
function createContent(id, options) {

  var docs = cts.search(cts.andQuery([
    cts.collectionQuery(['LoadABAWDPerson']),
    cts.jsonPropertyValueQuery('CLIENT_ID', id)
  ])).toArray();

  var root = docs[0].root;

  // for xml we need to use xpath
  if (root && xdmp.nodeKind(root) === 'element') {
    return root.xpath('/*:envelope/*:content/node()');
  }
  // for json we need to return the content
  else if (root && root.content) {

    //Identifiers
    var systemIdentifiers = new Array();
    systemIdentifiers.push({"SourceSystem": "LDSS_ID","SourceKey": root.content.LDSS_ID});
    systemIdentifiers.push({"SourceSystem": "DO","SourceKey": root.content.DO_NUM});
    systemIdentifiers.push({"SourceSystem": "CLIENTID","SourceKey": root.content.CLIENT_ID});
    systemIdentifiers.push({"SourceSystem": "AU","SourceKey": root.content.AU_NUM});

    //Addresses
    var addresses = [];
    if(root.content.STREET_NUM != '-' && root.content.STREET_DTCTN_CODE != '-' &&
        root.content.STREET_NAME != '-' && root.content.STREET_TYPE_CODE != '-' &&
        root.content.APT_NUM != '-' && root.content.CITY != '-' &&
        root.content.STATE != '-' && root.content.COL2 != '-') {

          addresses.push({"AddressType":"Mailing",
                  "StreetNumberText":root.content.STREET_NUM,
                  "StreetName":root.content.STREET_DTCTN_CODE + " " + root.content.STREET_NAME + " " + root.content.STREET_TYPE_CODE,
                  "AdditionalStreetName":root.content.APT_NUM,
                  "CityName":root.content.CITY,
                  "StateName":root.content.STATE,
                  "PostalCode":root.content.COL2.toString().substr(0,5),
                  "PostalExtensionCode":root.content.COL2.toString().substr(5)});
    }

    if(root.content.STREET_NUM1 != '-' && root.content.STREET_DIRECTION_CODE2 != '-' &&
        root.content.STREET_NAME3 != '-' && root.content.STREET_TYPE_CODE4 != '-' &&
        root.content.Apartment_Number5 != '-' && root.content.CITY6 != '-' &&
        root.content.STATE7 != '-' && root.content.COL8 != '-') {

          addresses.push({"AddressType":"Home",
                  "StreetNumberText":root.content.STREET_NUM1,
                  "StreetName":root.content.STREET_DIRECTION_CODE2 + " " + root.content.STREET_NAME3 + " " + root.content.STREET_TYPE_CODE4,
                  "AdditionalStreetName":root.content.Apartment_Number5,
                  "CityName":root.content.CITY6,
                  "StateName":root.content.STATE7,
                  "PostalCode":root.content.COL8.toString().substr(0,5),
                  "PostalExtensionCode":root.content.COL8.toString().substr(5)});
    }

    var uniqueEarnedIncomeArray = uniqueEarnedIncome(docs);
    var uniqueUnEarnedIncomeArray = uniqueUnEarnedIncome(docs);

    //summarize Earned Income by income type
    var summaryIncome = [];
    for (var i in uniqueEarnedIncomeArray) {
      var earnedIncome = uniqueEarnedIncomeArray[i];
      if(! updateEarnedIncome(summaryIncome, earnedIncome)) {
        var newIncome = {"IncomeTypeCode": earnedIncome.IncomeTypeCode,
                         "IncomeFrequencyCode": "AC",
                         "IncomeWorkHoursNumber": "0",
                         "IncomeAmount": "0"
                        };
        updateAddWorkHours(newIncome, earnedIncome.IncomeFrequencyCode, newIncome.IncomeWorkHoursNumber, earnedIncome.IncomeWorkHoursNumber);
        updateAddIncome(newIncome, earnedIncome.IncomeFrequencyCode, newIncome.IncomeAmount, earnedIncome.IncomeAmount);
        summaryIncome.push(newIncome);
      }
    }

    //Summarize UnEarned Income by income type
    var summaryUnEarnedIncome = [];
    for (var i in uniqueUnEarnedIncomeArray) {
      var unEarnedIncome = uniqueUnEarnedIncomeArray[i];

      if(!updateUnEarnedIncome(summaryUnEarnedIncome, unEarnedIncome)) {
        var newIncome = {"IncomeTypeCode": unEarnedIncome.IncomeTypeCode,
                         "IncomeFrequencyCode": "AC",
                         "IncomeAmount": "0"
                        };
        updateAddIncome(newIncome, unEarnedIncome.IncomeFrequencyCode, newIncome.IncomeAmount, unEarnedIncome.IncomeAmount)
        summaryUnEarnedIncome.push(newIncome);
      }
    }

    var datePattern = /(\d{4})(\d{2})(\d{2})/;
    var birthDate = root.content.DOB.toString().replace(datePattern,'$1-$2-$3');

    //content
    var jsonDoc = {
      SystemIdentifiers: systemIdentifiers,
      PersonName: [{
          "PersonNameType":"Primary",
          "PersonGivenName": root.content.FIRST_NAME,
          "PersonSurName": root.content.LAST_NAME,
          "PersonFullName": root.content.FIRST_NAME + " " + root.content.LAST_NAME
        }],
      PersonSSNIdentification: [{"IdentificationId":root.content.SSN}],
      PersonBirthDate: birthDate,
      Addresses: addresses,
      PersonHOHCode: root.content.HOH_REL_CODE,
      PersonLanguageCode: root.content.PRIMARY_LANGUAGE_CODE,
      PersonLivingArrangementTypeCode: root.content.Living_Arrangement_Type_code
    };

    if(uniqueEarnedIncomeArray.length > 0) {
      jsonDoc.EarnedIncome = uniqueEarnedIncomeArray;
    }

    if(uniqueUnEarnedIncomeArray.length > 0) {
      jsonDoc.UnEarnedIncome = uniqueUnEarnedIncomeArray;
    }

    if(summaryIncome.length > 0) {
      jsonDoc.SummaryEarnedIncome = summaryIncome;
    }

    if(summaryUnEarnedIncome.length > 0) {
      jsonDoc.SummaryUnEarnedIncome = summaryUnEarnedIncome;
    }

    if(root.content.INS_STATUS_CODE && root.content.INS_STATUS_CODE != '-' && root.content.INS_STATUS_CODE != "") {
      jsonDoc.ImmigrationStatusCode = root.content.INS_STATUS_CODE;
    }

    if(datePattern.test(root.content.PREGNANCY_DUE_DATE.toString())) {
      jsonDoc.PregnancyDueDate = root.content.PREGNANCY_DUE_DATE.toString().replace(datePattern,'$1-$2-$3');
    }

    if(root.content.HOH_REL_CODE && root.content.HOH_REL_CODE != '-') {
      jsonDoc.PersonHOHCode = root.content.HOH_REL_CODE;
    }

    if(root.content.Disability_Type_Code && root.content.Disability_Type_Code != "-") {
      var disability = [];
      disability.push({
            "DisabilityTypeCode": root.content.Disability_Type_Code,
            "DisabilityStartDate": root.content.Disability_Start_Date,
            "DisabilityEndDate": root.content.Disability_End_Date
      });
      jsonDoc.Disability = disability;
    }
    return jsonDoc;

  }
  // for everything else
  else {
    return doc;
  }
}

//creates new earned income array without duplicates
function uniqueEarnedIncome(docs) {
    var uniqueIncome = new Array();
    var inArrayCounter = 0;
    for (var i in docs) {
      var doc = docs[i].root;
      for (var j in uniqueIncome) {
        var income = uniqueIncome[j];
        if(! (String(doc.content.Income_Type_Code) == String(income.IncomeTypeCode) &&
            String(doc.content.Income_Frequency_Code) == String(income.IncomeFrequencyCode) &&
            String(doc.content.Work_Hours_Number) == String(income.IncomeWorkHoursNumber) &&
            String(doc.content.Income_Amount) == String(income.IncomeAmount))) {
          inArrayCounter++;
        }
      }

      if(inArrayCounter == uniqueIncome.length) {
        var newIncome = {"IncomeTypeCode": doc.content.Income_Type_Code,
                         "IncomeFrequencyCode": doc.content.Income_Frequency_Code,
                         "IncomeWorkHoursNumber": doc.content.Work_Hours_Number,
                         "IncomeAmount": doc.content.Income_Amount
                        };
        if(newIncome.IncomeTypeCode != "-" &&  newIncome.IncomeFrequencyCode != "-" &&
          newIncome.IncomeWorkHoursNumber != "-" &&  newIncome.IncomeAmount != "-") {
              uniqueIncome.push(newIncome);
        }
      }
      inArrayCounter = 0;
    }
    return uniqueIncome;
}

//Creates new un earned income array without duplicates
function uniqueUnEarnedIncome(docs) {
    var uniqueIncome = new Array();
    var inArrayCounter = 0;
    for (var i in docs) {
      var doc = docs[i].root;
      for (var j in uniqueIncome) {
        var income = uniqueIncome[j];
        if(! (String(doc.content.UI_type_Code) == String(income.IncomeTypeCode) &&
            String(doc.content.UI_Frequency_Code) == String(income.IncomeFrequencyCode) &&
            String(doc.content.UI_Amount) == String(income.IncomeAmount))) {
          inArrayCounter++;
        }
      }

      if(inArrayCounter == uniqueIncome.length) {
        var newIncome = {"IncomeTypeCode": doc.content.UI_type_Code,
                         "IncomeFrequencyCode": doc.content.UI_Frequency_Code,
                         "IncomeAmount": doc.content.UI_Amount
                        };
        if(newIncome.IncomeTypeCode != "-" &&  newIncome.IncomeFrequencyCode != "-" &&
            newIncome.IncomeAmount != "-") {
              uniqueIncome.push(newIncome);
        }
      }
      inArrayCounter = 0;
    }
    return uniqueIncome;
}

//Add to income amount, normalize income frequency to monthly
function updateAddIncome(targetItem, incomeFreqCD, srcIncome, addIncome) {
  if (incomeFreqCD == 'WE') {
    targetItem.IncomeAmount = parseFloat(srcIncome) + parseFloat(addIncome) * 4;
    return true;
  } else if (incomeFreqCD == 'BW') {
    targetItem.IncomeAmount = parseFloat(srcIncome) + parseFloat(addIncome) * 2;
    return true;
  } else if (incomeFreqCD == 'BM') {
    targetItem.IncomeAmount = parseFloat(srcIncome) + parseFloat(addIncome) / 2;
    return true;
  } else if (incomeFreqCD == 'QU') {
    targetItem.IncomeAmount = parseFloat(srcIncome) + parseFloat(addIncome) / 3;
    return true;
  } else if (incomeFreqCD == 'AN') {
    targetItem.IncomeAmount = parseFloat(srcIncome) + parseFloat(addIncome) / 12;
    return true;
  } else if (incomeFreqCD == 'SA') {
    targetItem.IncomeAmount = parseFloat(srcIncome) + parseFloat(addIncome) / 6;
    return true;
  } else if (incomeFreqCD == 'AC') {
    targetItem.IncomeAmount = parseFloat(srcIncome) + parseFloat(addIncome);
    return true;
  } else if (incomeFreqCD == 'OT') {
    targetItem.IncomeAmount = parseFloat(srcIncome) + parseFloat(addIncome);
    return true;
  } else {
    return false;
  }
}

//Add to work hours normalize income frequency to monthly
function updateAddWorkHours(targetItem, incomeFreqCD, srcHrs, addHrs) {
  if (incomeFreqCD == 'WE') {
    targetItem.IncomeWorkHoursNumber = parseFloat(srcHrs) + parseFloat(addHrs) * 4;
    return true;
  } else if (incomeFreqCD == 'BW') {
    targetItem.IncomeWorkHoursNumber = parseFloat(srcHrs) + parseFloat(addHrs) * 2;
    return true;
  } else if (incomeFreqCD == 'BM') {
    targetItem.IncomeWorkHoursNumber = parseFloat(srcHrs) + parseFloat(addHrs) / 2;
    return true;
  } else if (incomeFreqCD == 'QU') {
    targetItem.IncomeWorkHoursNumber = parseFloat(srcHrs) + parseFloat(addHrs) / 3;
    return true;
  } else if (incomeFreqCD == 'AN') {
    targetItem.IncomeWorkHoursNumber = parseFloat(srcHrs) + parseFloat(addHrs) / 12;
    return true;
  } else if (incomeFreqCD == 'SA') {
    targetItem.IncomeWorkHoursNumber = parseFloat(srcHrs) + parseFloat(addHrs) / 6;
    return true;
  } else if (incomeFreqCD == 'AC') {
    targetItem.IncomeWorkHoursNumber = parseFloat(srcHrs) + parseFloat(addHrs);
    return true;
  } else if (incomeFreqCD == 'OT') {
    targetItem.IncomeWorkHoursNumber = parseFloat(srcHrs) + parseFloat(addHrs);
    return true;
  } else {
    return false;
  }
}

//Loop thru earned income array to see if item already exists, if so add work hours and income amount.
function updateEarnedIncome(targetArray, sourceItem) {
  for (var i in targetArray) {
    //If same income type
    if (String(targetArray[i].IncomeTypeCode) == String(sourceItem.IncomeTypeCode)) {
      updateAddWorkHours(targetArray[i], sourceItem.IncomeFrequencyCode, targetArray[i].IncomeWorkHoursNumber, sourceItem.IncomeWorkHoursNumber);
      updateAddIncome(targetArray[i], sourceItem.IncomeFrequencyCode, targetArray[i].IncomeAmount, sourceItem.IncomeAmount);
      return true;
    }
  }
  return false;
}

//Loop through unearned income array to see if item already exists, if so add income amount.
function updateUnEarnedIncome(targetArray, sourceItem) {
  for (var i in targetArray) {
    if (String(targetArray[i].IncomeTypeCode) == String(sourceItem.IncomeTypeCode)) {
      updateAddIncome(targetArray[i], sourceItem.IncomeFrequencyCode, targetArray[i].IncomeAmount, sourceItem.IncomeAmount);
      return true;
    }
  }
  return false;
}

module.exports = {
  createContent: createContent
};
