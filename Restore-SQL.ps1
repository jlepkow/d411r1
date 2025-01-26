<#
Name: Joseph Lepkowski
Student ID: 010128419
#>

try {
    $sqlServerInstanceName = ".\SQLEXPRESS"
    $databaseName = "ClientDB"
    
    # Check for database existence and output message
    $query = "SELECT COUNT(*) as Count FROM sys.databases WHERE name = '$databaseName'"
    $result = Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Query $query
    
    if ($result.Count -gt 0) {
        Write-Host "Database '$databaseName' exists."
        Write-Host "Deleting existing database..."
        Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Query "ALTER DATABASE [$databaseName] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$databaseName]"
        Write-Host "Database '$databaseName' has been deleted."
    } else {
        Write-Host "Database '$databaseName' does not exist."
    }

    # Create new database
    Write-Host "Creating new database '$databaseName'..."
    Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Query "CREATE DATABASE [$databaseName]"
    Write-Host "Database '$databaseName' has been created."

    # Create table with auto-incrementing ID
    Write-Host "Creating table 'Client_A_Contacts'..."
    $createTableQuery = @"
    CREATE TABLE [Client_A_Contacts] (
        ID INT IDENTITY(1,1) PRIMARY KEY,
        FirstName NVARCHAR(50),
        LastName NVARCHAR(50),
        City NVARCHAR(50),
        County NVARCHAR(50),
        Zip NVARCHAR(10),
        OfficePhone NVARCHAR(20),
        MobilePhone NVARCHAR(20)
    )
"@
    Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Database $databaseName -Query $createTableQuery
    Write-Host "Table 'Client_A_Contacts' has been created."

    # Import data from CSV
    Write-Host "Importing data from NewClientData.csv..."
    $csvPath = Join-Path $PSScriptRoot "NewClientData.csv"
    $csvData = Import-Csv $csvPath

    foreach ($row in $csvData) {
        $insertQuery = @"
        INSERT INTO Client_A_Contacts (FirstName, LastName, City, County, Zip, OfficePhone, MobilePhone)
        VALUES (
            '$(($row.first_name -replace "'", "''"))',
            '$(($row.last_name -replace "'", "''"))',
            '$(($row.city -replace "'", "''"))',
            '$(($row.county -replace "'", "''"))',
            '$(($row.zip -replace "'", "''"))',
            '$(($row.officePhone -replace "'", "''"))',
            '$(($row.mobilePhone -replace "'", "''"))'
        )
"@
        Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Database $databaseName -Query $insertQuery
    }
    Write-Host "Data import completed successfully."

    # Generate output file
    Write-Host "Generating SqlResults.txt..."
    Invoke-Sqlcmd -Database ClientDB -ServerInstance .\SQLEXPRESS -Query 'SELECT * FROM dbo.Client_A_Contacts' > .\SqlResults.txt
    Write-Host "SqlResults.txt has been generated."

} catch {
    Write-Host "Error occurred: $_"
    Write-Host "Stack Trace: $($_.ScriptStackTrace)"
    throw
}