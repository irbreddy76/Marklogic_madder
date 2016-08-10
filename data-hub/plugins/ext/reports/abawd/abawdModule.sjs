/*
 * ABAWD Module Data Retrieval
 *
 * @param aource         - the source for Modules data
 * @param contextId      - the primary context ID
 * @param contextIdValue - the primary context ID value
 * @param format         - the format of the data  for output
 *
 * @return - your content
 */
function getModuleData(source, contextId, contextIdValue, format) {
      var docs = cts.search(cts.andQuery([
          cts.collectionQuery([source]),
          cts.jsonPropertyValueQuery(contextId, contextIdValue)
        ])).toArray();
     return docs;
}