<#
Name: Joseph Lepkowski
Student ID: 010128419
#>

try {
    $sqlServerInstanceName = ".\SQLEXPRESS"
    $databaseName = "ClientDB"
    
    # Check for database existence
    $databaseExists = Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Query "SELECT COUNT(*) FROM sys.databases WHERE name = '$databaseName'"

    if ($databaseExists -eq 1) {
        Write-Host -ForegroundColor Yellow "Database '$databaseName' exists. Deleting..."
        Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Query "DROP DATABASE [$databaseName]"
        Write-Host -ForegroundColor Green "Database '$databaseName' has been deleted."
    } else {
        Write-Host -ForegroundColor Green "Database '$databaseName' does not exist."
    }

    # Create the new database
    Write-Host "Creating database '$databaseName'..."
    Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Query "CREATE DATABASE [$databaseName]"
    Write-Host -ForegroundColor Green "Database '$databaseName' has been created."

    # Create the new table
    $tableName = "Client_A_Contacts"
    Write-Host "Creating table '$tableName'..."
    $tableScript = @"
CREATE TABLE [$databaseName].[dbo].[$tableName] (
    ContactID INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    Phone NVARCHAR(15)
)
"@
    Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Database $databaseName -Query $tableScript
    Write-Host -ForegroundColor Green "Table '$tableName' has been created."

    # Import data from CSV
    $csvPath = ".\NewClientData.csv"
$csvData = Import-Csv $csvPath

foreach ($row in $csvData) {
    $insertQuery = @"
INSERT INTO [$tableName] (ContactID, FirstName, LastName, Email, Phone)
VALUES ('$($row.ContactID)', '$($row.FirstName)', '$($row.LastName)', '$($row.Email)', '$($row.Phone)')
"@
    Invoke-Sqlcmd -ServerInstance $sqlServerInstanceName -Database $databaseName -Query $insertQuery
}

Write-Host -ForegroundColor Green "Data imported successfully from $csvPath"

# Generate output file
Invoke-Sqlcmd -Database ClientDB -ServerInstance .\SQLEXPRESS -Query 'SELECT * FROM dbo.Client_A_Contacts' > .\SqlResults.txt
Write-Host -ForegroundColor Green "Results exported to SqlResults.txt"

} catch {
    Write-Host -ForegroundColor Red "An error occurred:"
    Write-Host -ForegroundColor Red $_.Exception.Message
    Write-Host -ForegroundColor Red $_.ScriptStackTrace
}