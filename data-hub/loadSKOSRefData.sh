#!/bin/bash

mlcp.sh import \
-host localhost -port 8011 \
-username admin -password admin \
-input_file_type RDF \
-input_file_path ./data/ABAWD-SKOS/CountyDesignations.ttl \
-output_collections "http://www.dhr.state.md.us/conceptschemes/ABAWD" \
-output_graph "http://www.dhr.state.md.us/conceptschemes/ABAWD/CountyDesignations" \
-output_permissions rest-reader,read,rest-writer,update


mlcp.sh import \
-host localhost -port 8011 \
-username admin -password admin \
-input_file_type RDF \
-input_file_path ./data/Reference-SKOS/Counties.ttl \
-output_collections "http://www.dhr.state.md.us/conceptschemes/reference" \
-output_graph "http://www.dhr.state.md.us/conceptschemes/reference/Counties" \
-output_permissions rest-reader,read,rest-writer,update

mlcp.sh import \
-host localhost -port 8011 \
-username admin -password admin \
-input_file_type RDF \
-input_file_path ./data/ABAWD-SKOS/DisabilityTypes.ttl \
-output_collections "http://www.dhr.state.md.us/conceptschemes/ABAWD" \
-output_graph "http://www.dhr.state.md.us/conceptschemes/ABAWD/DisabilityTypes" \
-output_permissions rest-reader,read,rest-writer,update

mlcp.sh import \
-host localhost -port 8011 \
-username admin -password admin \
-input_file_type RDF \
-input_file_path ./data/ABAWD-SKOS/INSStatus.ttl \
-output_collections "http://www.dhr.state.md.us/conceptschemes/ABAWD" \
-output_graph "http://www.dhr.state.md.us/conceptschemes/ABAWD/INSStatus" \
-output_permissions rest-reader,read,rest-writer,update

mlcp.sh import \
-host localhost -port 8011 \
-username admin -password admin \
-input_file_type RDF \
-input_file_path ./data/ABAWD-SKOS/PrimaryLanguageCodes.ttl \
-output_collections "http://www.dhr.state.md.us/conceptschemes/ABAWD" \
-output_graph "http://www.dhr.state.md.us/conceptschemes/ABAWD/PrimaryLanguageCodes" \
-output_permissions rest-reader,read,rest-writer,update

mlcp.sh import \
-host localhost -port 8011 \
-username admin -password admin \
-input_file_type RDF \
-input_file_path ./data/ABAWD-SKOS/UnearnedIncomeCodes.ttl \
-output_collections "http://www.dhr.state.md.us/conceptschemes/ABAWD" \
-output_graph "http://www.dhr.state.md.us/conceptschemes/ABAWD/UnearnedIncomeCodes" \
-output_permissions rest-reader,read,rest-writer,update

mlcp.sh import \
-host localhost -port 8011 \
-username admin -password admin \
-input_file_type RDF \
-input_file_path ./data/ABAWD-SKOS/UnearnedIncomeFrequency.ttl \
-output_collections "http://www.dhr.state.md.us/conceptschemes/ABAWD" \
-output_graph "http://www.dhr.state.md.us/conceptschemes/ABAWD/UnearnedIncomeFrequency" \
-output_permissions rest-reader,read,rest-writer,update
