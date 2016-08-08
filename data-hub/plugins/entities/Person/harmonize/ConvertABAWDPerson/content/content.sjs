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
    addresses.push({"AddressType":"Mailing",
            "StreetNumberText":root.content.STREET_NUM,
            "StreetName":root.content.STREET_DTCTN_CODE + " " + root.content.STREET_NAME + " " + root.content.STREET_TYPE_CODE,
            "AdditionalStreetName":root.content.APT_NUM,
            "CityName":root.content.CITY,
            "StateName":root.content.STATE,
            "PostalCode":root.content.COL2.toString().substr(0,5),
            "PostalExtensionCode":root.content.COL2.toString().substr(5)});

    addresses.push({"AddressType":"Home",
            "StreetNumberText":root.content.STREET_NUM1,
            "StreetName":root.content.STREET_DIRECTION_CODE2 + " " + root.content.STREET_NAME3 + " " + root.content.STREET_TYPE_CODE4,
            "AdditionalStreetName":root.content.Apartment_Number5,
            "CityName":root.content.CITY6,
            "StateName":root.content.STATE7,
            "PostalCode":root.content.COL8.toString().substr(0,5),
            "PostalExtensionCode":root.content.COL8.toString().substr(5)});

    //Income
    var income = [];
    for (var i in docs) {
      var doc = docs[i].root;

      income.push({"IncomeTypeCode": doc.content.Income_Type_Code,
          "IncomeFrequencyCode": doc.content.Income_Frequency_Code,
          "IncomeWorkHoursNumber": doc.content.Work_Hours_Number,
          "IncomeAmount": doc.content.Income_Amount,
      });
    }

    //Unearned Income
    var ueIncome = [];
    for (var i in docs) {
      var doc = docs[i].root;

      ueIncome.push({"IncomeTypeCode": doc.content.UI_type_Code,
            "IncomeFrequencyCode": doc.content.UI_Frequency_Code,
            "IncomeAmount": doc.content.UI_Amount,
      });
    }

    var datePattern = /(\d{4})(\d{2})(\d{2})/;
    var birthDate = root.content.DOB.toString().replace(datePattern,'$1-$2-$3');

    //content
    return {
      SystemIdentifiers: systemIdentifiers,
      PersonName: [{
          "PersonNameType":"Primary",
          "PersonGivenName": root.content.FIRST_NAME,
          "PersonSurName": root.content.LAST_NAME,
          "PersonFullName":" "
        }],
      PersonSSNIdentification: [{"IdentificationId":root.content.SSN}],
      PersonBirthDate: birthDate,
      Addresses: addresses,
      PersonHOHCode: root.content.HOH_REL_CODE,
      PersonLanguageCode: root.content.PRIMARY_LANGUAGE_CODE,
      PersonLivingArrangementTypeCode: root.content.Living_Arrangement_Type_code,
      ImmigrationStatusCode: root.content.INS_STATUS_CODE,
      Disability: [{
            "DisabilityTypeCode": root.content.Disability_Type_Code,
            "DisabilityStartDate": root.content.Disability_Start_Date,
            "DisabilityEndDate": root.content.Disability_End_Date
          }],
      Income: income,
      UnEarnedIncome: ueIncome
    };

    if(datePattern.test(root.content.PREGNANCY_DUE_DATE.toString())) {
      jsonObject.PregnancyDueDate = root.content.PREGNANCY_DUE_DATE.toString().replace(datePattern,'$1-$2-$3');
    }

  }
  // for everything else
  else {
    return doc;
  }
}

module.exports = {
  createContent: createContent
};
