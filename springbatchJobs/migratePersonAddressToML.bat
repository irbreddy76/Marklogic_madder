jobs\bin\jobs.bat  --config com.marklogic.spring.batch.config.MigrateColumnMapsConfig ^
	 --jdbcDriver org.postgresql.Driver --jdbcUrl jdbc:postgresql://localhost/CHESSIE ^
	 --collections person ^
	 --jdbcUsername postgres --jdbcPassword postgres ^
	 --rootLocalName PersonAddress ^
	 --host localhost ^
	 --username admin ^
     --password admin ^
	 --port 8200 ^
	 --format json ^
	 --sql  ^
"SELECT ^
c.cis_client_id as "CISClientId", ^
c.state_assn_student_id, ^
c.aka_prefix_cd as \"PersonAlternateName/PeronAlternatePrefixCode\", ^
c.aka_first_nm as  \"PersonAlternateName/PersonAlternateFirstName\", ^
c.aka_middle_nm as \"PersonAlternateName/PersonAlternateMiddleName\",^
c.aka_last_nm as \"PersonAlternateName/PersonAlternateLastName\", ^
c.dob_dt as \"PersonPrimaryName/PersonBirthDate\", ^
c.dod_dt as \"PersonPrimaryName/PersonDeathDate\", ^
c.gender_cd as \"PersonPrimaryName/PersonSexCode\", ^
ca.ADR_TYPE_CD as \"Address/AddressTypeCd\", ^
ca.ADR_STREET_NO as \"Address/AddressStreetNo\", ca.ADR_BOX_NO as \"Address/AddressBoxNo\", ^
ca.ADR_STREET_NM as \"Address/AddressStreetName\", ^
ca.ADR_CITY_NM as \"Address/AddressCityName\", ^
ca.ADR_COUNTY_CD as \"Address/AddressCountyCd\", ^
ca.ADR_STATE_CD as \"Address/AddressStateCd\", ^
ca.ADR_ZIP5_NO as \"Address/AddressZip5No\", ^
ca.ADR_ZIP4_NO as \"Address/AddressZip4No\" ^
FROM TB_CLIENT c INNER JOIN TB_CLIENT_ADDRESSES ca ON c.CIS_CLIENT_ID = ca.CIS_CLIENT_ID ORDER BY c.CIS_CLIENT_ID"	 