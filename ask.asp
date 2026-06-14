<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%
Response.CodePage = 65001
Response.Charset = "utf-8"
Response.ContentType = "application/json"
Server.ScriptTimeout = 120

Function JsonEscape(v)
    Dim s
    s = CStr(v)
    s = Replace(s, Chr(92), Chr(92) & Chr(92))
    s = Replace(s, Chr(34), Chr(92) & Chr(34))
    s = Replace(s, vbCrLf, Chr(92) & "n")
    s = Replace(s, vbCr, Chr(92) & "n")
    s = Replace(s, vbLf, Chr(92) & "n")
    s = Replace(s, vbTab, Chr(92) & "t")
    JsonEscape = s
End Function

Function ShellQuote(v)
    ShellQuote = Chr(34) & Replace(CStr(v), Chr(34), "") & Chr(34)
End Function

Sub SaveUtf8(pathValue, textValue)
    Dim stm
    Set stm = Server.CreateObject("ADODB.Stream")
    stm.Type = 2
    stm.Charset = "utf-8"
    stm.Open
    stm.WriteText textValue
    stm.SaveToFile pathValue, 2
    stm.Close
    Set stm = Nothing
End Sub

Sub WriteJson(okValue, answerValue, errorValue)
    Dim q
    q = Chr(34)
    If okValue Then
        Response.Write "{" & q & "ok" & q & ":true," & q & "answer" & q & ":" & q & JsonEscape(answerValue) & q & "}"
    Else
        Response.Write "{" & q & "ok" & q & ":false," & q & "error" & q & ":" & q & JsonEscape(errorValue) & q & "}"
    End If
End Sub

Dim q
q = Trim(Request.Form("q"))
If q = "" Then q = Trim(Request.QueryString("q"))

If q = "" Then
    WriteJson False, "", "empty question"
    Response.End
End If

If Len(q) > 4000 Then q = Left(q, 4000)

On Error Resume Next
Dim fso, tmpDir, promptFile, scriptFile, shell, cmd, execObj, startedAt, stdoutText, stderrText, errText
Set fso = Server.CreateObject("Scripting.FileSystemObject")
If Err.Number <> 0 Then
    errText = "FileSystemObject failed. IIS may block filesystem access."
    Err.Clear
    WriteJson False, "", errText
    Response.End
End If

tmpDir = Server.MapPath("tmp")
If Not fso.FolderExists(tmpDir) Then fso.CreateFolder tmpDir
promptFile = tmpDir & "\prompt_" & Replace(Replace(Replace(Now(), ":", ""), "/", ""), " ", "_") & "_" & CStr(Int(Rnd() * 100000)) & ".txt"
scriptFile = Server.MapPath("ask_claude.ps1")
SaveUtf8 promptFile, q
If Err.Number <> 0 Then
    errText = "Save prompt failed. Check write permission for voice tmp folder."
    Err.Clear
    WriteJson False, "", errText
    Response.End
End If

Set shell = Server.CreateObject("WScript.Shell")
If Err.Number <> 0 Then
    errText = "WScript.Shell failed. IIS may block local command execution."
    Err.Clear
    WriteJson False, "", errText
    Response.End
End If

cmd = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File " & ShellQuote(scriptFile) & " -PromptFile " & ShellQuote(promptFile)
Set execObj = shell.Exec(cmd)
If Err.Number <> 0 Then
    errText = "Shell exec failed. IIS could not start PowerShell."
    Err.Clear
    WriteJson False, "", errText
    Response.End
End If

startedAt = Timer
Do While execObj.Status = 0
    If Timer - startedAt > 95 Then
        WriteJson False, "", "timeout waiting for local assistant"
        Response.End
    End If
Loop

stdoutText = execObj.StdOut.ReadAll
stderrText = execObj.StdErr.ReadAll
If fso.FileExists(promptFile) Then fso.DeleteFile promptFile, True

If Err.Number <> 0 Then
    errText = "Runtime failed while reading local assistant output."
    Err.Clear
    WriteJson False, "", errText
ElseIf execObj.ExitCode <> 0 Then
    errText = Trim(stderrText & vbCrLf & stdoutText)
    If errText = "" Then errText = "local assistant exited with code " & CStr(execObj.ExitCode)
    WriteJson False, "", errText
Else
    WriteJson True, stdoutText, ""
End If
%>
