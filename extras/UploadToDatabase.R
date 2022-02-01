# Using the official uploading functions to get data from zip files into the postgres database
library(CohortDiagnostics)

# OHDSI's server:
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = dbms,
  server = paste0(Sys.getenv("phenotypeLibraryServer"), "/", Sys.getenv("phenotypeLibrarydb")),
  port = Sys.getenv("phenotypeLibraryDbPort", unset = 5432),
  user = Sys.getenv("phenotypeLibrarydbUser"),
  password = Sys.getenv("phenotypeLibrarydbPw")
)
resultsSchema <- 'phenotype_phebruary'

# commenting this function as it maybe accidentally run - loosing data.
# createResultsDataModel(connectionDetails = connectionDetails, schema = resultsSchema)

Sys.setenv("POSTGRES_PATH" = Sys.getenv('POSTGRES_PATH'))

folderWithZipFilesToUpload <- "D:\\studyResults\\phenotypePhebruary"
listOfZipFilesToUpload <-
  list.files(
    path = folderWithZipFilesToUpload,
    pattern = ".zip",
    full.names = TRUE,
    recursive = TRUE
  )

for (i in (1:length(listOfZipFilesToUpload))) {
  CohortDiagnostics::uploadResults(
    connectionDetails = connectionDetails,
    schema = resultsSchema,
    zipFileName = listOfZipFilesToUpload[[i]]
  )
}

# uploadPrintFriendly was removed in version 2.1
# uploadPrintFriendly(connectionDetails = connectionDetails,
#                     schema = resultsSchema)

launchDiagnosticsExplorer(connectionDetails = connectionDetails,
                          resultsDatabaseSchema = resultsSchema)
