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

    var income = [];

    //Earned Income
    for (var i in docs) {
      var doc = docs[i].root;

      if(doc.content.Income_Type_Code != "-" &&  doc.content.Income_Frequency_Code != "-" &&
          doc.content.Work_Hours_Number != "-" &&  doc.content.Income_Amount != "-") {
          if(! updateEarnedIncome(income, doc.content)) {
            var newIncome = {"IncomeTypeCode": doc.content.Income_Type_Code,
                             "IncomeFrequencyCode": doc.content.Income_Frequency_Code,
                             "IncomeWorkHoursNumber": 0,
                             "IncomeAmount": 0,
                            };
            updateAddWorkHours(newIncome, doc.content.Income_Frequency_Code, doc.content.Work_Hours_Number);
            updateAddIncome(newIncome, doc.content.Income_Frequency_Code, doc.content.Income_Amount);
            income.push(newIncome);
          }
      }
    }

    //Unearned Income, add to Income array
    for (var i in docs) {
      var doc = docs[i].root;

      if(doc.content.UI_type_Code != "-" &&
          doc.content.UI_Frequency_Code != "-" &&  doc.content.UI_Amount != "-") {

          if(!updateUnEarnedIncome(income, doc.content)) {
            var newIncome = {"IncomeTypeCode": doc.content.UI_type_Code,
                             "IncomeFrequencyCode": doc.content.UI_Frequency_Code,
                             "IncomeAmount": doc.content.UI_Amount,
                            };
            updateAddIncome(newIncome, doc.content.UI_Frequency_Code, doc.content.UI_Amount);
            income.push(newIncome);
          }
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

    if(income.length > 0) {
      jsonDoc.Income = income;
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

function updateAddIncome(targetItem, incomeFreqCD, incomeAmount) {
  if (incomeFreqCD == 'WE') {
    targetItem.IncomeAmount = parseFloat(targetItem.IncomeAmount) + parseFloat(incomeAmount) * 4;
    return true;
  } else if (incomeFreqCD == 'BW') {
    targetItem.IncomeAmount = parseFloat(targetItem.IncomeAmount) + parseFloat(incomeAmount) * 2;
    return true;
  } else if (incomeFreqCD == 'BM') {
    targetItem.IncomeAmount = parseFloat(targetItem.IncomeAmount) + parseFloat(incomeAmount) / 2;
    return true;
  } else if (incomeFreqCD == 'QU') {
    targetItem.IncomeAmount = parseFloat(targetItem.IncomeAmount) + parseFloat(incomeAmount) / 3;
    return true;
  } else if (incomeFreqCD == 'AN') {
    targetItem.IncomeAmount = parseFloat(targetItem.IncomeAmount) + parseFloat(incomeAmount) / 12;
    return true;
  } else if (incomeFreqCD == 'SA') {
    targetItem.IncomeAmount = parseFloat(targetItem.IncomeAmount) + parseFloat(incomeAmount) / 6;
    return true;
  } else if (incomeFreqCD == 'AC') {
    targetItem.IncomeAmount = parseFloat(targetItem.IncomeAmount) + parseFloat(incomeAmount);
    return true;
  } else if (incomeFreqCD == 'OT') {
    targetItem.IncomeAmount = parseFloat(targetItem.IncomeAmount) + parseFloat(incomeAmount);
    return true;
  } else {
    return false;
  }
}

function updateAddWorkHours(targetItem, incomeFreqCD, workHours) {
  if (incomeFreqCD == 'WE') {
    targetItem.IncomeWorkHoursNumber = parseFloat(targetItem.IncomeWorkHoursNumber) + parseFloat(workHours) * 4;
    return true;
  } else if (incomeFreqCD == 'BW') {
    targetItem.IncomeWorkHoursNumber = (parseFloat(targetItem.IncomeWorkHoursNumber) + parseFloat(workHours) * 2).toString();
    xdmp.log("work hours total: " + targetItem.IncomeWorkHoursNumber);
    return true;
  } else if (incomeFreqCD == 'BM') {
    targetItem.IncomeWorkHoursNumber = parseFloat(targetItem.IncomeWorkHoursNumber) + parseFloat(workHours) / 2;
    return true;
  } else if (incomeFreqCD == 'QU') {
    targetItem.IncomeWorkHoursNumber = parseFloat(targetItem.IncomeWorkHoursNumber) + parseFloat(workHours) / 3;
    return true;
  } else if (incomeFreqCD == 'AN') {
    targetItem.IncomeWorkHoursNumber = parseFloat(targetItem.IncomeWorkHoursNumber) + parseFloat(workHours) / 12;
    return true;
  } else if (incomeFreqCD == 'SA') {
    targetItem.IncomeWorkHoursNumber = parseFloat(targetItem.IncomeWorkHoursNumber) + parseFloat(workHours) / 6;
    return true;
  } else if (incomeFreqCD == 'AC') {
    targetItem.IncomeWorkHoursNumber = parseFloat(targetItem.IncomeWorkHoursNumber) + parseFloat(workHours);
    return true;
  } else if (incomeFreqCD == 'OT') {
    targetItem.IncomeWorkHoursNumber = parseFloat(targetItem.IncomeWorkHoursNumber) + parseFloat(workHours);
    return true;
  } else {
    return false;
  }
}

function updateEarnedIncome(targetArray, sourceItem) {
  for (var i in targetArray) {
    if (String(targetArray[i].IncomeTypeCode) == String(sourceItem.Income_Type_Code)) {
      updateAddWorkHours(targetArray[i], sourceItem.Income_Frequency_Code, sourceItem.Work_Hours_Number);
      updateAddIncome(targetArray[i], sourceItem.Income_Frequency_Code, sourceItem.Income_Amount);
      return true;
    }
  }
  return false;
}

function updateUnEarnedIncome(targetArray, sourceItem) {
  for (var i in targetArray) {
    if (String(targetArray[i].IncomeTypeCode) == String(sourceItem.UI_type_Code)) {
      updateAddIncome(targetArray[i], sourceItem.UI_Frequency_Code, sourceItem.UI_Amount);
      return true;
    }
  }
  return false;
}

module.exports = {
  createContent: createContent
};
