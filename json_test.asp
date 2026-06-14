<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%
Response.CodePage = 65001
Response.Charset = "utf-8"
Response.ContentType = "application/json"

Function J(v)
    Dim s
    s = CStr(v)
    s = Replace(s, Chr(92), Chr(92) & Chr(92))
    s = Replace(s, Chr(34), Chr(92) & Chr(34))
    s = Replace(s, vbCrLf, Chr(92) & "n")
    s = Replace(s, vbCr, Chr(92) & "n")
    s = Replace(s, vbLf, Chr(92) & "n")
    J = s
End Function

Response.Write "{" & Chr(34) & "ok" & Chr(34) & ":false," & Chr(34) & "error" & Chr(34) & ":" & Chr(34) & J("WScript.Shell failed. IIS may block local command execution.") & Chr(34) & "}"
%>
