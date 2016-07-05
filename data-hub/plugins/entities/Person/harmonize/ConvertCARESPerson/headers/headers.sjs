/*
 * Create Headers Plugin
 *
 * @param id       - the identifier returned by the collector
 * @param content  - the output of your content plugin
 * @param options  - an object containing options. Options are sent from Java
 *
 * @return - an object of headers
 */
function createHeaders(id, content, options) {
  xdmp.log(content, 'notice');
  var header = {
    RecordType: 'Person',
    SystemIdentifiers: [],
    Addresses: []
  };

  var i;

  for(i = 0; i < content.SystemIdentifiers.length; i++) {
    var identifier = content.SystemIdentifiers[i];
    if(identifier.SourceSystem == 'MDCHESSIE') {
        header.SystemIdentifiers.push({ChessieId: identifier.SourceKey});
    } else if(identifier.SourceSystem == 'CIS') {
        header.SystemIdentifiers.push({CisId: identifier.SourceKey});
    } 
  }
 
  for(i = 0; i < content.PersonName.length; i++) {
    var name = content.PersonName[i];
    if(name.PersonNameType == 'Primary') {
        header.PersonPrimaryName = {
          PersonGivenName: name.PersonGivenName,
          PersonMiddleName: name.PersonMiddleName,
          PersonSurName: name.PersonSurName,
          PersonFullName: name.PersonFullName
        };
    }
  }

  if(content.PersonSSNIdentification) {
    header.SSNIdentificationId = content.PersonSSNIdentification.IdentificationId;
  }

  for(i = 0; i < content.Addresses.length; i++) {
    var address = content.Addresses[i];
    var entry = {
      AddressType: address.AddressType,
      StateDate: address.StartDate,
      CloseDate: address.CloseDate,
      LocationStreet: address.StreetNumberText + " " + address.StreetName,
      LocationCityName: address.CityName,
      LocationCounty: address.CountyName,
      LocationStateName: address.StateName,
      LocationPostalCode: address.PostalCode,
      LocationPostalCodeExtension: address.PostalExtensionCode
    };
    header.Addresses.push(entry);
  }

  return header;
}

module.exports = {
  createHeaders: createHeaders
};
