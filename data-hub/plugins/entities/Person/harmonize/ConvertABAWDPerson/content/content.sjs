/*
 * Create Content Plugin
 *
 * @param id         - the identifier returned by the collector
 * @param options    - an object containing options. Options are sent from Java
 *
 * @return - your content
 */
function createContent(id, options) {
  var doc = cts.doc(id);
  var root = doc.root;

  // for xml we need to use xpath
  if (root && xdmp.nodeKind(root) === 'element') {
    return root.xpath('/*:envelope/*:content/node()');
  }
  // for json we need to return the content
  else if (root && root.content) {

    //Identifiers
    var systemIdentifiers = [];
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
      PersonBirthDate: root.content.DOB,
      Addresses: addresses,
      PersonHOHCode: root.content.HOH_REL_CODE,
      PersonLanguageCode: root.content.PRIMARY_LANGUAGE_CODE,
      PersonLivingArrangementTypeCode: root.content.Living_Arrangement_Type_code,
      PregnancyDueDate: root.content.PREGNANCY_DUE_DATE,
      ImmigrationStatusCode: root.content.INS_STATUS_CODE,
      Disability: [{
            "DisabilityTypeCode": root.content.Disability_Type_Code,
            "DisabilityStartDate": root.content.Disability_Start_Date,
            "DisabilityEndDate": root.content.Disability_End_Date,
          }],
      Income: [ {
            "IncomeTypeCode": root.content.Income_Type_Code,
            "IncomeFrequencyCode": root.content.Income_Frequency_Code,
            "IncomeWorkHoursNumber": root.content.Work_Hours_Number,
            "IncomeAmount": root.content.Income_Amount,
            "IncomeDate": root.content.Benefit_Status_Date
          }],
      UnEarnedIncome: [{
            "IncomeTypeCode": root.content.UI_type_Code,
            "IncomeFrequencyCode": root.content.UI_Frequency_Code,
            "IncomeAmount": root.content.UI_Amount,
            "IncomeDate": root.content.Benefit_Status_Date
          }]
    };

  }
  // for everything else
  else {
    return doc;
  }
}

module.exports = {
  createContent: createContent
};
