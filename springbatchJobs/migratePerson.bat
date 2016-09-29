jobs\bin\jobs.bat  --config com.marklogic.spring.batch.config.MigrateSQLXMLToJsonConfig ^
	 --jdbcDriver org.postgresql.Driver --jdbcUrl jdbc:postgresql://localhost/CHESSIE ^
	 --collections person ^
	 --output_file_path "C:\\temp\\json\\"	 ^
	 --jdbcUsername postgres --jdbcPassword postgres ^
	 --root_local_name person ^
	 --sql  ^
"select ^
		xmlelement(name \"Person\", ^
		XMLATTRIBUTES(c.cis_client_id AS \"ClientId\"), ^
		xmlconcat( xmlelement(name \"PersonPrimaryName\", ^
		xmlforest(FIRST_NM as \"PersonGivenName\", MIDDLE_NM as \"PersonMiddleName\", ^
		LAST_NM as \"PersonSurName\", MAIDEN_NM as \"PersonMaidenName\", ^
		FULL_NM as \"PersonFullName\", PREFIX_CD as \"PersonNamePrefixText\", ^
		SUFFIX_CD as \"PersonNameSuffixText\")), xmlelement(name \"PersonAlternateName\", ^
		xmlforest(AKA_PREFIX_CD as \"PersonAKAPrefixCode\", AKA_FIRST_NM as \"PersonAlternateFirstName\", ^
		AKA_MIDDLE_NM as \"PersonAlternateMiddleName\", AKA_LAST_NM as \"PersonAlternateLastName\", ^
		AKA_SUFFIX_CD as \"PeronAlternateSuffixCode\", AKA_TYPE_CD as \"PersonAlternateNameType\")))) from TB_CLIENT c"