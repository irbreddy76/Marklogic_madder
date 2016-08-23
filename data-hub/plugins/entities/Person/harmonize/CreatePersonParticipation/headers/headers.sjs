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
  var header = {
    RecordType: 'MasterPerson',
    SystemIdentifiers: [],
    ParticipationIdentifiers: [],
    Addresses: [],
    SystemLoadDate: fn.currentDateTime(),
    SystemModifiedDate: fn.currentDateTime()
  };
 
  var i, j;
  var person = content.records[0].Person;
  for(i = 0; i < person.SystemIdentifiers.length; i++) {
    var identifier = person.SystemIdentifiers[i];
    var value = {};
    
    if(identifier.ExtractDateTime) {
      value.SourceExtractDateTime = new Date(identifier.ExtractDateTime.replace(' ', 'T'));
    }
    if(identifier.SourceSystem == 'MDCHESSIE') {
        value.chessieId = identifier.SourceKey;
        header.SystemIdentifiers.push(value);
    } else if(identifier.SourceSystem == 'CIS') {
        value.cisId = identifier.SourceKey;
        header.SystemIdentifiers.push(value);
    }
  };

  for(i = 0; i < person.PersonName.length; i++) {
    var name = person.PersonName[i];
    if(name.PersonNameType == 'Primary') {
      header.PersonPrimaryName = {
        PersonGivenName: name.PersonGivenName,
        PersonMiddleName: name.PersonMiddleName,
        PersonSurName: name.PersonSurName,
        PersonFullName: name.PersonFullName
      };
    }
  }

  header.SSNIdentificationId = person.PersonSSNIdentification[0].IdentificationID;
 
  for(i = 0; i < content.records[0].ProgramParticipations.length; i++) {
    var participation = content.records[0].ProgramParticipations[i];
    for(j = 0; j < participation.ParticipationIdentifiers.length; j++) {
      var identifier = participation.ParticipationIdentifiers[j];
      if(identifier.ParticipationType == 'Service Case') {
        header.ParticipationIdentifiers.push( { serviceCaseId: identifier.ParticipationKey } );
      } else if(identifier.ParticipationType == 'Adoption Planning') {
        header.ParticipationIdentifiers.push( { adoptionPlanningId: identifier.ParticipationKey } );
      };
    }
  }

  for(i = 0; i < content.records[0].Person.Addresses.length; i++) {
    var address = content.records[0].Person.Addresses[i];
    var entry = {
      AddressType: address.AddressType,
      StartDate: address.StartDate,
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
