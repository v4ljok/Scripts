Dim inputFile, wordLimit
Set fileSystem = CreateObject("Scripting.FileSystemObject")

If WScript.Arguments.Count < 2 Then
    WScript.Echo "Usage: cscript books.vbs <inputFile> <wordLimit>"
    WScript.Quit
End If

inputFile = WScript.Arguments(0)
wordLimit = CInt(WScript.Arguments(1))

Set textFile = fileSystem.OpenTextFile(inputFile, 1)
Set wordFrequency = CreateObject("Scripting.Dictionary")

Function RemovePunctuation(str)
    Dim punctuationChars
    punctuationChars = Array(",", ";", ":", ")", "(", "!", "?", ".", """", "--", "&", "$", "  ", "_")

    For Each punctuationChar In punctuationChars
        str = Replace(str, punctuationChar, "")
    Next

    RemovePunctuation = str
End Function

Do Until textFile.AtEndOfStream
    currentLine = LCase(textFile.ReadLine())
    words = Split(currentLine, " ")

    For Each currentWord In words
        processedWord = RemovePunctuation(currentWord)

        Select Case processedWord
            Case "me", "my", "mine", "i'm"
                processedWord = "i"
            Case "him", "his", "himself"
                processedWord = "he"
            Case "her", "hers", "herself"
                processedWord = "she"
            Case "its", "itself"
                processedWord = "it"
            Case "them", "their", "theirs", "themselves"
                processedWord = "they"
            Case "your", "yours", "yourself", "yourselves"
                processedWord = "you"
            Case "us", "our", "ours", "ourselves"
                processedWord = "we"
            Case "has", "had", "having"
                processedWord = "have"
            Case "don't", "doesn't", "didn't", "cannot", "couldn't"
                processedWord = "do not"
            Case "who's", "whom", "whose"
                processedWord = "who"
            Case "am", "is", "are", "was", "were", "being", "been"
                processedWord = "be"
        End Select

        If wordFrequency.Exists(processedWord) Then
            wordFrequency(processedWord) = wordFrequency(processedWord) + 1
        Else
            wordFrequency.Add processedWord, 1
        End If
    Next
Loop

WScript.Echo "CHECKING ZIPF's LAW"
WScript.Echo
WScript.Echo "The first column is the number of corresponding words in the text, and the second column is the number of words which should occur in the text according to Zipf's law."
WScript.Echo
WScript.Echo "The most popular words in " & inputFile & " are:"
WScript.Echo

For currentIndex = 0 To wordLimit
    mostFrequentWord = "" : maxFrequency = 0
    For Each currentTerm In wordFrequency
        If wordFrequency(currentTerm) > maxFrequency Then
            mostFrequentWord = currentTerm
            maxFrequency = wordFrequency(currentTerm)
        End If
    Next

    If maxFrequency <> 0 Then
        wordFrequency.Remove mostFrequentWord
        If Not (mostFrequentWord = vbLf Or mostFrequentWord = vbCr Or mostFrequentWord = "" Or mostFrequentWord = " ") Then
            zipfLawFrequency = maxFrequency
            WScript.Echo mostFrequentWord, vbTab, maxFrequency, vbTab, Round(zipfLawFrequency / currentIndex)
        End If
    End If
Next

WScript.Echo
WScript.Echo "The most popular remaining short forms in " & inputFile & " are:"
WScript.Echo

For currentIndex = 0 To wordLimit
    mostFrequentWord = "" : maxFrequency = 0
    For Each currentTerm In wordFrequency
        If wordFrequency(currentTerm) > maxFrequency And InStr(currentTerm, "'") Then
            mostFrequentWord = currentTerm
            maxFrequency = wordFrequency(currentTerm)
        End If
    Next

    If maxFrequency <> 0 Then
        wordFrequency.Remove mostFrequentWord
        If Not (mostFrequentWord = vbLf Or mostFrequentWord = vbCr Or mostFrequentWord = "" Or mostFrequentWord = " ") Then
            WScript.Echo mostFrequentWord, vbTab, maxFrequency
        End If
    End If
Next

textFile.Close