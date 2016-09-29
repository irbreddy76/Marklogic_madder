jobs\bin\jobs.bat  --config com.marklogic.spring.batch.config.MigrateSQLXMLToJsonConfig ^
	 --jdbcDriver org.postgresql.Driver --jdbcUrl jdbc:postgresql://localhost/CHESSIE ^
	 --collections person ^
	 --output_file_path "C:\\temp\\json\\"	 ^
	 --jdbcUsername postgres --jdbcPassword postgres ^
	 --root_local_name PersonAddress ^
	 --sql  ^
"SELECT ^
   XMLELEMENT(NAME \"Person\", ^
      XMLATTRIBUTES(c.CIS_CLIENT_ID AS \"id\"), ^
      XMLELEMENT(NAME \"PersonGivenName\",c.AKA_FIRST_NM), ^
      XMLELEMENT(NAME \"PersonSurName\",c.AKA_LAST_NM), ^
      XMLELEMENT(NAME \"Addresses\", ^
      (SELECT XMLAGG(XMLELEMENT(NAME \"Address\", ^
                 XMLATTRIBUTES(p.CIS_CLIENT_ID AS \"id\"), ^
                 XMLELEMENT(NAME \"AddressTypeCd\",p.ADR_TYPE_CD), ^
                 XMLELEMENT(NAME \"AddressStreetNo\",p.ADR_STREET_NO), ^
                 XMLELEMENT(NAME \"AddressBoxNo\",p.ADR_BOX_NO), ^
                 XMLELEMENT(NAME \"AddressStreetName\",p.ADR_STREET_NM), ^
                 XMLELEMENT(NAME \"AddressCityName\",p.ADR_CITY_NM), ^
                 XMLELEMENT(NAME \"AddressStateCd\",p.ADR_STATE_CD), ^
                 XMLELEMENT(NAME \"AddressZip5No\",p.ADR_ZIP5_NO), ^
                 XMLELEMENT(NAME \"AddressZip4No\",p.ADR_ZIP4_NO))) ^
      FROM TB_CLIENT_ADDRESSES p ^
      WHERE p.CIS_CLIENT_ID=c.CIS_CLIENT_ID))) AS \"Addresses\" ^
FROM TB_CLIENT c"