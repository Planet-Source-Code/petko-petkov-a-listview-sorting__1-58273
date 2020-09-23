VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MsComCtl.ocx"
Begin VB.Form Form1 
   Caption         =   "Form1"
   ClientHeight    =   4455
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   8280
   LinkTopic       =   "Form1"
   ScaleHeight     =   4455
   ScaleWidth      =   8280
   StartUpPosition =   3  'Windows Default
   Begin MSComctlLib.ListView ListView1 
      Height          =   4215
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   8055
      _ExtentX        =   14208
      _ExtentY        =   7435
      View            =   3
      LabelWrap       =   -1  'True
      HideSelection   =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   0
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

'****************************************************************
' Win32 API
'----------------------------------------------------------------

Private Declare Function LockWindowUpdate Lib "user32" (ByVal hWndLock As Long) As Long

'****************************************************************
' Form_Load
' Initialises the list control, and populates it with random data
'----------------------------------------------------------------

Private Sub Form_Load()
    With ListView1
    
        ' Add three columns to the list - one for each data type.
        ' Note that the data type is set in the column header's
        ' tag in each case
    
        .ColumnHeaders.Add(, , "String").Tag = "STRING"
        .ColumnHeaders.Add(, , "Number").Tag = "NUMBER"
        .ColumnHeaders.Add(, , "Date").Tag = "DATE"
        
        ' Set the column alignment - has no bearing on the sorts.
        
        .ColumnHeaders(1).Alignment = lvwColumnLeft
        .ColumnHeaders(2).Alignment = lvwColumnRight
        .ColumnHeaders(3).Alignment = lvwColumnCenter
        
        ' Populate the list with data
        
        Dim l As Long
        Dim dblRnd As Double
        Dim dteRnd As Date
        With .ListItems
            For l = 1 To 1000
                With .Add(, , "ListItem " & Format(l, "0000"))
                    dblRnd = (Rnd() * 10000) - 5000
                    dteRnd = (Rnd() * 1000) + Date
                    .ListSubItems.Add , , Format(dblRnd, "### ##0.00")
                    .ListSubItems.Add , , Format(dteRnd, "yyyy/mm/dd")
                End With
            Next l
        End With
        
    End With
End Sub

'****************************************************************
' ListView1_ColumnClick
' Called when a column header is clicked on - sorts the data in
' that column
'----------------------------------------------------------------

Private Sub ListView1_ColumnClick(ByVal ColumnHeader As MSComctlLib.ColumnHeader)
  Select Case ColumnHeader.Index
    Case 1: SotrListView ListView1, ColumnHeader, ""
    Case 2: SotrListView ListView1, ColumnHeader, "NUMBER"
    Case 3: SotrListView ListView1, ColumnHeader, "DATE"
  End Select
End Sub

Public Sub SotrListView(ByVal lstView As ListView, ByVal ColumnHeader As MSComctlLib.ColumnHeader, Optional ByVal TypeSort As String = "NUMBER")

    On Error Resume Next
  
    With lstView
    
        ' Display the hourglass cursor whilst sorting
        
        Dim lngCursor As Long
        lngCursor = .MousePointer
        .MousePointer = vbHourglass
        
        ' Prevent the ListView control from updating on screen -
        ' this is to hide the changes being made to the listitems
        ' and also to speed up the sort
        
        LockWindowUpdate .hWnd
        
        ' Check the data type of the column being sorted,
        ' and act accordingly
        
        Dim l As Long
        Dim strFormat As String
        Dim strData() As String
        
        Dim lngIndex As Long
        lngIndex = ColumnHeader.Index - 1
    
        Select Case UCase$(TypeSort)
        Case "DATE"
        
            ' Sort by date.
            
            strFormat = "YYYYMMDDHhNnSs"
        
            ' Loop through the values in this column. Re-format
            ' the dates so as they can be sorted alphabetically,
            ' having already stored their visible values in the
            ' tag, along with the tag's original value
        
            With .ListItems
                If (lngIndex > 0) Then
                    For l = 1 To .Count
                        With .Item(l).ListSubItems(lngIndex)
                            .Tag = .Text & Chr$(0) & .Tag
                            If IsDate(.Text) Then
                                .Text = Format(CDate(.Text), _
                                                    strFormat)
                            Else
                                .Text = ""
                            End If
                        End With
                    Next l
                Else
                    For l = 1 To .Count
                        With .Item(l)
                            .Tag = .Text & Chr$(0) & .Tag
                            If IsDate(.Text) Then
                                .Text = Format(CDate(.Text), _
                                                    strFormat)
                            Else
                                .Text = ""
                            End If
                        End With
                    Next l
                End If
            End With
            
            ' Sort the list alphabetically by this column
            
            .SortOrder = (.SortOrder + 1) Mod 2
            .SortKey = ColumnHeader.Index - 1
            .Sorted = True
            
            ' Restore the previous values to the 'cells' in this
            ' column of the list from the tags, and also restore
            ' the tags to their original values
            
            With .ListItems
                If (lngIndex > 0) Then
                    For l = 1 To .Count
                        With .Item(l).ListSubItems(lngIndex)
                            strData = Split(.Tag, Chr$(0))
                            .Text = strData(0)
                            .Tag = strData(1)
                        End With
                    Next l
                Else
                    For l = 1 To .Count
                        With .Item(l)
                            strData = Split(.Tag, Chr$(0))
                            .Text = strData(0)
                            .Tag = strData(1)
                        End With
                    Next l
                End If
            End With
            
        Case "NUMBER"
        
            ' Sort Numerically
        
            strFormat = String(30, "0") & "." & String(30, "0")
        
            ' Loop through the values in this column. Re-format the values so as they
            ' can be sorted alphabetically, having already stored their visible
            ' values in the tag, along with the tag's original value
        
            With .ListItems
                If (lngIndex > 0) Then
                    For l = 1 To .Count
                        With .Item(l).ListSubItems(lngIndex)
                            .Tag = .Text & Chr$(0) & .Tag
                            If IsNumeric(Val(.Text)) Then
                                If CDbl(Val(.Text)) >= 0 Then
                                    .Text = Format(CDbl(Val(.Text)), _
                                        strFormat)
                                Else
                                    .Text = "&" & InvNumber( _
                                        Format(0 - CDbl(Val(.Text)), _
                                        strFormat))
                                End If
                            Else
                                .Text = ""
                            End If
                        End With
                    Next l
                Else
                    For l = 1 To .Count
                        With .Item(l)
                            .Tag = .Text & Chr$(0) & .Tag
                            If IsNumeric(.Text) Then
                                If CDbl(.Text) >= 0 Then
                                    .Text = Format(CDbl(.Text), _
                                        strFormat)
                                Else
                                    .Text = "&" & InvNumber( _
                                        Format(0 - CDbl(.Text), _
                                        strFormat))
                                End If
                            Else
                                .Text = ""
                            End If
                        End With
                    Next l
                End If
            End With
            
            ' Sort the list alphabetically by this column
            
            .SortOrder = (.SortOrder + 1) Mod 2
            .SortKey = ColumnHeader.Index - 1
            .Sorted = True
            
            ' Restore the previous values to the 'cells' in this
            ' column of the list from the tags, and also restore
            ' the tags to their original values
            
            With .ListItems
                If (lngIndex > 0) Then
                    For l = 1 To .Count
                        With .Item(l).ListSubItems(lngIndex)
                            strData = Split(.Tag, Chr$(0))
                            .Text = strData(0)
                            .Tag = strData(1)
                        End With
                    Next l
                Else
                    For l = 1 To .Count
                        With .Item(l)
                            strData = Split(.Tag, Chr$(0))
                            .Text = strData(0)
                            .Tag = strData(1)
                        End With
                    Next l
                End If
            End With
        
        Case Else   ' Assume sort by string
            
            ' Sort alphabetically. This is the only sort provided
            ' by the MS ListView control (at this time), and as
            ' such we don't really need to do much here
        
            .SortOrder = (.SortOrder + 1) Mod 2
            .SortKey = ColumnHeader.Index - 1
            .Sorted = True
            
        End Select
    
        ' Unlock the list window so that the OCX can update it
        
        LockWindowUpdate 0&
        
        ' Restore the previous cursor
        
        .MousePointer = lngCursor
    
    End With
    
    Set lstView = Nothing
    Set ColumnHeader = Nothing
End Sub


'****************************************************************
' InvNumber
' Function used to enable negative numbers to be sorted
' alphabetically by switching the characters
'----------------------------------------------------------------

Private Function InvNumber(ByVal Number As String) As String
    Static i As Integer
    For i = 1 To Len(Number)
        Select Case Mid$(Number, i, 1)
        Case "-": Mid$(Number, i, 1) = " "
        Case "0": Mid$(Number, i, 1) = "9"
        Case "1": Mid$(Number, i, 1) = "8"
        Case "2": Mid$(Number, i, 1) = "7"
        Case "3": Mid$(Number, i, 1) = "6"
        Case "4": Mid$(Number, i, 1) = "5"
        Case "5": Mid$(Number, i, 1) = "4"
        Case "6": Mid$(Number, i, 1) = "3"
        Case "7": Mid$(Number, i, 1) = "2"
        Case "8": Mid$(Number, i, 1) = "1"
        Case "9": Mid$(Number, i, 1) = "0"
        End Select
    Next
    InvNumber = Number
End Function

'****************************************************************
'
'----------------------------------------------------------------

