Option Explicit

Dim fileSystem : Set fileSystem = CreateObject("Scripting.FileSystemObject")
Dim sourceFolder, destinationFolder
sourceFolder = WScript.Arguments(0) & "\"
destinationFolder = WScript.Arguments(1) & "\"

Dim validExtensions
validExtensions = Array("jpeg", "jpg", "png")

Dim totalFilesMoved, totalFoldersCreated
totalFilesMoved = 0
totalFoldersCreated = 0

If Not fileSystem.FolderExists(sourceFolder) Or Not fileSystem.FolderExists(destinationFolder) Then
    WScript.Echo "Source or destination folder does not exist."
    WScript.Quit
End If

Function FormatNumberWithLeadingZeros(number, totalDigits)
    FormatNumberWithLeadingZeros = Right(String(totalDigits, "0") & number, totalDigits)
End Function

Function ProcessFileAndMove(file)
    Dim fileExtension
    fileExtension = LCase(fileSystem.GetExtensionName(file.Path))

    If Not IsExtensionInList(fileExtension, validExtensions) Then Exit Function

    Dim fileYear, formattedDate, yearPath, datePath
    fileYear = Year(file.DateLastModified)
    formattedDate = fileYear & "-" & FormatNumberWithLeadingZeros(Month(file.DateLastModified), 2) & "-" & FormatNumberWithLeadingZeros(Day(file.DateLastModified), 2)
    yearPath = destinationFolder & fileYear & "\"
    datePath = yearPath & formattedDate & "\"

    If Not fileSystem.FolderExists(yearPath) Then
        CreateFolderAndIncrementCount yearPath
    End If

    If Not fileSystem.FolderExists(datePath) Then
        CreateFolderAndIncrementCount datePath
    End If

    file.Copy datePath
    totalFilesMoved = totalFilesMoved + 1
End Function

Function IsExtensionInList(value, arr)
    Dim item
    For Each item In arr
        If LCase(item) = value Then
            IsExtensionInList = True
            Exit Function
        End If
    Next
    IsExtensionInList = False
End Function

Function CreateFolderAndIncrementCount(folderPath)
    fileSystem.CreateFolder folderPath
    totalFoldersCreated = totalFoldersCreated + 1
End Function

Function TraverseFoldersAndProcess(sourcePath)
    Dim currentFolder, subFolder, file
    Set currentFolder = fileSystem.GetFolder(sourcePath)

    For Each file In currentFolder.Files
        ProcessFileAndMove file
    Next

    For Each subFolder In currentFolder.SubFolders
        TraverseFoldersAndProcess subFolder.Path
    Next
End Function

Function OutputFileMovementLog(destinationDirPath)
    Dim currentFolder, subFolder, file
    Dim fileList, fileCount
    Set currentFolder = fileSystem.GetFolder(destinationDirPath)

    For Each subFolder In currentFolder.SubFolders
        Set fileList = CreateObject("System.Collections.ArrayList")
        fileCount = 0

        For Each file In subFolder.Files
            fileList.Add(file.Name)
            fileCount = fileCount + 1
        Next
        
        If fileCount = 1 Then
            WScript.Echo "1 file"
            WScript.Echo
            WScript.Echo fileList(0)
            WScript.Echo
            WScript.Echo "was moved to folder"
            WScript.Echo
            WScript.Echo subFolder.Path
            WScript.Echo
            WScript.Echo "--------"
            WScript.Echo
        ElseIf fileCount > 1 Then
            WScript.Echo fileCount & " files"
            WScript.Echo
            WScript.Echo Join(fileList.ToArray(), ", ")
            WScript.Echo
            WScript.Echo "were moved to folder"
            WScript.Echo
            WScript.Echo subFolder.Path
            WScript.Echo
            WScript.Echo "--------"
            WScript.Echo
        End If

        OutputFileMovementLog subFolder.Path
    Next
End Function

TraverseFoldersAndProcess sourceFolder
OutputFileMovementLog destinationFolder

Dim filesText, foldersText
If totalFilesMoved = 1 Then
    filesText = "1 picture was"
Else
    filesText = totalFilesMoved & " pictures were"
End If

If totalFoldersCreated = 1 Then
    foldersText = "1 folder."
Else
    foldersText = totalFoldersCreated & " folders."
End If

WScript.Echo filesText & " sorted into " & foldersText