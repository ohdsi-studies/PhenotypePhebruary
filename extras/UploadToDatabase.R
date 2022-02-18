# Using the official uploading functions to get data from zip files into the postgres database
remotes::install_github("OHDSI/CohortDiagnostics")

library(CohortDiagnostics)

# OHDSI's server:
connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "postgresql",
  server = paste0(Sys.getenv("phenotypeLibraryServer"), "/", Sys.getenv("phenotypeLibrarydb")),
  port = Sys.getenv("phenotypeLibraryDbPort", unset = 5432),
  user = Sys.getenv("phenotypeLibrarydbUser"),
  password = Sys.getenv("phenotypeLibrarydbPw")
)
resultsSchema <- 'phenotype_phebruary2'

# commenting this function as it maybe accidentally run - loosing data.
createResultsDataModel(connectionDetails = connectionDetails, schema = resultsSchema)
sqlGrant <- "grant select on all tables in schema phenotype_phebruary to phenotypelibrary;"
connection <- DatabaseConnector::renderTranslateExecuteSql(connection = DatabaseConnector::connect(connectionDetails = connectionDetails))
DatabaseConnector::renderTranslateExecuteSql(connection = connection, sql = sqlGrant)
DatabaseConnector::disconnect(connection)


Sys.setenv("POSTGRES_PATH" = Sys.getenv('POSTGRES_PATH'))

folderWithZipFilesToUpload <- "D:\\studyResults\\phenotypePhebruary"
listOfZipFilesToUpload <-
  list.files(
    path = folderWithZipFilesToUpload,
    pattern = ".zip",
    full.names = TRUE,
    recursive = TRUE
  )

listOfZipFilesToUpload <-
  listOfZipFilesToUpload[stringr::str_detect(string = listOfZipFilesToUpload,
                                             pattern = "optum",
                                             negate = TRUE)]

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

# launchDiagnosticsExplorer(connectionDetails = connectionDetails,
#                           resultsDatabaseSchema = resultsSchema)
