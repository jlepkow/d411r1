# Joseph Lepkowski - Student ID: 010128419
# File: prompts.ps1

# This script provides a menu to perform different administrative tasks

# Function to display menu options
function Show-Menu {
    Write-Host "Please choose an option:"
    Write-Host "1. List .log files and append to DailyLog.txt"
    Write-Host "2. List files in alphabetical order in C916contents.txt"
    Write-Host "3. Show current CPU and memory usage"
    Write-Host "4. Show running processes sorted by virtual size"
    Write-Host "5. Exit"
}

# Infinite loop for menu until user exits
do {
    Show-Menu
    $choice = Read-Host "Enter your choice (1-5)"

    switch ($choice) {
        1 {
            # B1: List .log files and append to DailyLog.txt
            try {
                $logFiles = Get-ChildItem -Path .\Requirements1\*.log
                $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                $logFiles | ForEach-Object { 
                    Add-Content -Path .\Requirements1\DailyLog.txt -Value "$date $_"
                }
                Write-Host "Log files listed and appended to DailyLog.txt"
            } catch {
                Write-Host "Error listing log files."
            }
        }
        2 {
            # B2: List files in alphabetical order and output to C916contents.txt
            try {
                Get-ChildItem -Path .\Requirements1\ | Sort-Object Name | Format-Table -AutoSize | Out-File .\Requirements1\C916contents.txt
                Write-Host "Files listed and saved to C916contents.txt"
            } catch {
                Write-Host "Error listing files."
            }
        }
        3 {
            # B3: Show current CPU and memory usage
            try {
                $cpuUsage = Get-WmiObject win32_processor | Measure-Object -Property LoadPercentage -Average | Select-Object Average
                $memoryUsage = Get-WmiObject win32_OperatingSystem | Select-Object @{Name="TotalVisibleMemorySize (KB)";Expression={$_.TotalVisibleMemorySize}},@{Name="FreePhysicalMemory (KB)";Expression={$_.FreePhysicalMemory}}
                Write-Host "CPU Usage: $($cpuUsage.Average)%"
                Write-Host "Memory Usage:"
                $memoryUsage | Format-Table -AutoSize
            } catch {
                Write-Host "Error retrieving CPU and memory usage."
            }
        }
        4 {
            # B4: Show running processes sorted by virtual size
            try {
                Get-Process | Sort-Object -Property VM -Descending | Out-GridView
            } catch {
                Write-Host "Error listing processes."
            }
        }
        5 {
            # B5: Exit the script
            Write-Host "Exiting script..."
        }
        default {
            Write-Host "Invalid option. Please select a number between 1 and 5."
        }
    }
} while ($choice -ne 5)

# Apply try-catch for OutOfMemoryException
try {
    # Simulated operation that could cause OutOfMemoryException
} catch [System.OutOfMemoryException] {
    Write-Host "System ran out of memory while processing."
}
