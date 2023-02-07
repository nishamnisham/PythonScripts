Sub FirstCalcs()
    Dim lastRow As Long
    lastRow = Range("A25").End(xlDown).Row
    For i = 25 To lastRow
        Call CalculateColAtoJ(CStr(i))
    Next i
End Sub

Sub SecondCalcs()
    Dim lastRow As Long
    lastRow = Range("A25").End(xlDown).Row
    For i = 25 To lastRow
        Call CalculateColYtoRest(CStr(i))
    Next i
End Sub

Sub CalculateColAtoJ(rowNumber As Integer)

    Dim Range As Range
    Dim variable1 As Double, variable2 As Double, variable3 As Double
    Dim result As Double
    'Dim rowNumber As Integer
    Dim outputCell As String
    Dim scantling As String
    Dim F_value As Double
    
    ' rowNumber = 2

    ' Get the range of cells A1:A3
    Set Range = ThisWorkbook.Sheets("3-Sect properties").Range("A" & rowNumber & ":X" & rowNumber)

    ' Assign the values of the cells to variables
    spacing = Range.Cells(1, 1).Value
    span = Range.Cells(1, 2).Value
    adjacent = Range.Cells(1, 3).Value
    anom_pos = Range.Cells(1, 4).Value
    id_stiff = Range.Cells(1, 6).Value
    scantling = Range.Cells(1, 7).Value
    h_stiff = Range.Cells(1, 8).Value
    metal_grade = Range.Cells(1, 9).Value
    primary_secondary = Range.Cells(1, 10).Value
    t_plate = Range.Cells(1, 11).Value
    
    a = Range.Cells(1, 22).Value
    b = Range.Cells(1, 23).Value
    c = Range.Cells(1, 24).Value
    
    ' Split the scantling
    split1_a = Split(scantling, " + ")(0)
    split1_b = Split(scantling, " + ")(1)
    split1_c = Split(split1_b, " ")(1)

    t_web_act = Split(split1_a, "x")(1)
    w_flange = Split(split1_b, "x")(0)
    t_flange_act = Split(Split(split1_b, "x")(1), " ")(0)
    h_web1 = Split(split1_a, "x")(0)
    
    
    If InStr(split1_c, "T") > 0 Then
        h_web = (CDbl(h_web1)) - t_flange_act '(CDbl(t_flange_act))
    Else
        h_web = CDbl(h_web1)
    End If
    
    
    ' Calculating f value
    F_value = FValue(CDbl(spacing), CDbl(span))
    
    ' Effective plate width
    eff_width = EffectivePlateFlange(CDbl(spacing), CStr(adjacent), CDbl(F_value), CStr(primary_secondary), CDbl(t_plate))
    
    
    ' --------BEFORE REDUCTION--------- Area, Centeroid, Sectional modulus, Moment of Inertia Calculation  --------------------
    
    ' Total area of the cross-section
    ' The input data types: eff_width As Double, t_plate As Double, h_flange As Double, t_flange_act As Double, t_web_act As Double, h_web As Double
    csArea = AreaTotalCS(CDbl(eff_width), CDbl(t_plate), CDbl(w_flange), CDbl(t_flange_act), CDbl(t_web_act), CDbl(h_web))
    
    ' Area of web alone
    ' See below
    
    ' Area * Area centeroid
    ' The input data types: eff_width As Double, t_plate As Double, h_flange As Double, t_flange_act As Double, t_web_act As Double, h_web As Double
    a_y = AreaCenteroid(CDbl(eff_width), CDbl(t_plate), CDbl(w_flange), CDbl(t_flange_act), CDbl(t_web_act), CDbl(h_web))
    
    ' Area * Area centeroid Squared
    ' The input data types: eff_width As Double, t_plate As Double, h_flange As Double, t_flange_act As Double, t_web_act As Double, h_web As Double
    a_y2 = AreaCenteroid2(CDbl(eff_width), CDbl(t_plate), CDbl(w_flange), CDbl(t_flange_act), CDbl(t_web_act), CDbl(h_web))
    
    ' Total height of the profile
    totalSectionDepth = TotalDepth(CDbl(eff_width), CDbl(t_plate), CDbl(w_flange), CDbl(t_flange_act), CDbl(t_web_act), CDbl(h_web))
    
    
    ' Section Centeroid
    Dim sectionCenteroid As Double
    sectionCenteroid = a_y / csArea
    
    ' Area * Y2 total of the profile
    Dim a_y2_total As Double
    a_y2_total = csArea * (sectionCenteroid) ^ 2
    
    ' I about Neutral axis
    iNA = IAboutNA(CDbl(eff_width), CDbl(t_plate), CDbl(w_flange), CDbl(t_flange_act), CDbl(t_web_act), CDbl(h_web))
    
    'There is a problem with the formula below
    Dim iSection As Double
    iSection = (iNA + a_y2 - a_y2_total)
    
    ' Sectional modulus of the profile
    zSection = (iSection / sectionCenteroid) / 1000
    
    ' Zf
    Dim Zf_ar As Double
    Zf = ((iSection) / (totalSectionDepth - sectionCenteroid) / 1000)
    
    'Area of web actual using the total sectional depth
    aWebAct = (totalSectionDepth * t_web_act) / 100
    
    
    ' ----------------- Printing output --------------------
    
    ' Define the column names where the output will be printed
    out_t_web = "L" & rowNumber
    out_t_flange_act = "M" & rowNumber
    out_Zf = "N" & rowNumber
    out_aWebAct = "O" & rowNumber
    
    
    ' Execute the output
    ThisWorkbook.Sheets("3-Sect properties").Range(out_t_web).Value = t_web_act
    ThisWorkbook.Sheets("3-Sect properties").Range(out_t_flange_act).Value = t_flange_act
    ThisWorkbook.Sheets("3-Sect properties").Range(out_Zf).Value = Zf
    ThisWorkbook.Sheets("3-Sect properties").Range(out_aWebAct).Value = aWebAct
    
End Sub

Sub CalculateColYtoRest(rowNumber As Integer)

    Dim Range As Range
    Dim variable1 As Double, variable2 As Double, variable3 As Double
    Dim result As Double
    'Dim rowNumber As Integer
    Dim outputCell As String
    Dim scantling As String
    Dim F_value As Double
    
    ' rowNumber = 2

    ' Get the range of cells A1:A3
    Set Range = ThisWorkbook.Sheets("3-Sect properties").Range("A" & rowNumber & ":X" & rowNumber)

    ' Assign the values of the cells to variables
    ' These values do not change after reduction
    spacing = Range.Cells(1, 1).Value
    span = Range.Cells(1, 2).Value
    adjacent = Range.Cells(1, 3).Value
    anom_pos = Range.Cells(1, 4).Value
    id_stiff = Range.Cells(1, 6).Value
    scantling = Range.Cells(1, 7).Value
    h_stiff = Range.Cells(1, 8).Value
    metal_grade = Range.Cells(1, 9).Value
    primary_secondary = Range.Cells(1, 10).Value
    t_plate = Range.Cells(1, 11).Value
    
    ' Reduced thicknesses
    ' These values HAVE CHANGED after reduction
    t_plate_ar = Range.Cells(1, 22).Value
    t_web_ar = Range.Cells(1, 23).Value
    t_flange_ar = Range.Cells(1, 24).Value
    
    
    ' Split the scantling
    split1_a = Split(scantling, " + ")(0)
    split1_b = Split(scantling, " + ")(1)
    split1_c = Split(split1_b, " ")(1)

    ' Unnecessary parameters but required to see if it is a T section
    ' These values have NOT changed after reduction
    h_web = Split(split1_a, "x")(0)
    t_web_act = Split(split1_a, "x")(1)
    w_flange = Split(split1_b, "x")(0)
    t_flange_act = Split(Split(split1_b, "x")(1), " ")(0)
    h_web1 = Split(split1_a, "x")(0)
    
    If InStr(split1_c, "T") > 0 Then
        h_web_ar = (CDbl(h_web1)) - t_flange_act '(CDbl(t_flange_act))
    Else
        h_web_ar = CDbl(h_web1)
    End If

    
    ' Calculating f value
    F_value = FValue(CDbl(spacing), CDbl(span))
    
    ' Effective plate width
    eff_width = EffectivePlateFlange(CDbl(spacing), CStr(adjacent), CDbl(F_value), CStr(primary_secondary), CDbl(t_plate_ar))
    
    
    ' --------BEFORE REDUCTION--------- Area, Centeroid, Sectional modulus, Moment of Inertia Calculation  --------------------
    
    ' Total area of the cross-section
    ' The input data types: eff_width As Double, t_plate As Double, h_flange As Double, t_flange_act As Double, t_web_act As Double, h_web As Double
    csArea = AreaTotalCS(CDbl(eff_width), CDbl(t_plate_ar), CDbl(w_flange), CDbl(t_flange_act), CDbl(t_web_act), CDbl(h_web_ar))
    
    ' Area of web alone
    ' Dim webArea_act As Double
    ' webArea_act = (h_web * t_web_act) / 100
    
    ' zSection will be read from the table because it has been already calcualted and printed into the table.
    zSection_br = Range.Cells(1, 14).Value  'This value will only be used for ratio
    
   
    
    
    ' --------AFTER REDUCTION--------- Area, Centeroid, Sectional modulus, Moment of Inertia Calculation  -------------------
    
    ' Effective plate width
    eff_width_ar = EffectivePlateFlange(CDbl(spacing), CStr(adjacent), CDbl(F_value), CStr(primary_secondary), CDbl(t_plate_ar))
    
    ' Total area of the cross-section
    ' The input data types: eff_width As Double, t_plate As Double, h_flange As Double, t_flange_act As Double, t_web_act As Double, h_web As Double
    csArea_ar = AreaTotalCS(CDbl(eff_width_ar), CDbl(t_plate_ar), CDbl(w_flange), CDbl(t_flange_ar), CDbl(t_web_ar), CDbl(h_web_ar))
    
    ' Area of web alone
    ' See below
    
    ' Area * Area centeroid
    ' The input data types: eff_width As Double, t_plate As Double, h_flange As Double, t_flange_act As Double, t_web_act As Double, h_web As Double
    a_y_ar = AreaCenteroid(CDbl(eff_width_ar), CDbl(t_plate_ar), CDbl(w_flange), CDbl(t_flange_ar), CDbl(t_web_ar), CDbl(h_web_ar))
    
    ' Area * Area centeroid Squared
    ' The input data types: eff_width As Double, t_plate As Double, h_flange As Double, t_flange_act As Double, t_web_act As Double, h_web As Double
    a_y2_ar = AreaCenteroid2(CDbl(eff_width_ar), CDbl(t_plate_ar), CDbl(w_flange), CDbl(t_flange_ar), CDbl(t_web_ar), CDbl(h_web_ar))
    
    ' Total height of the profile
    totalSectionDepth_ar = TotalDepth(CDbl(eff_width_ar), CDbl(t_plate_ar), CDbl(w_flange), CDbl(t_flange_ar), CDbl(t_web_ar), CDbl(h_web_ar))
    
    
    ' Section Centeroid
    Dim sectionCenteroid_ar As Double
    sectionCenteroid_ar = a_y_ar / csArea_ar
    
    ' Area * Y2 total of the profile
    Dim a_y2_total_ar As Double
    a_y2_total_ar = csArea_ar * (sectionCenteroid_ar) ^ 2
    
    ' I about Neutral axis
    iNA_ar = IAboutNA(CDbl(eff_width), CDbl(t_plate_ar), CDbl(w_flange), CDbl(t_flange_ar), CDbl(t_web_ar), CDbl(h_web_ar))
    
    'There is a problem with the formula below
    Dim iSection_ar As Double
    iSection_ar = (iNA_ar + a_y2_ar - a_y2_total_ar)
    
    ' Sectional modulus of the profile
    zSection_ar = (iSection_ar / sectionCenteroid_ar) / 1000
    
    ' Zf
    Dim Zf_ar As Double
    Zf_ar = ((iSection_ar) / (totalSectionDepth_ar - sectionCenteroid_ar) / 1000)
    
    ' Zp
    Zp_ar = zSection_ar
    
    ' Area of web
    'Area of web actual using the total sectional depth
    aWebAct_ar = (totalSectionDepth_ar * t_web_ar) / 100

    
    ' At
    At_ar = csArea_ar / 100
    
    ' dw - depth of web
    dw_ar = h_web_ar
    
    ' bf - Breadth of flange
    bf_ar = w_flange
    
    ' Span in meters
    S_ar = span / 1000
    
    ' Moment of inertia in centimeters
    Ia_ar = iSection_ar / 10000
    
    ' Percentage of original Z section
    Zsec_per_ar = Zf_ar / zSection_br
    
    ' Percentage of original Web Area
    ' Web area before reduction read from row 15, calculated with sub 1
    webArea_act_br = Range.Cells(1, 15).Value
    ' Web area after reduction comes from the calculateion above
    Aw_per_ar = aWebAct_ar / webArea_act_br
    
    
    
    ' ----------------- Printing output --------------------
    
    ' Define the column names where the output will be printed
    out_Zf_ar = "Y" & rowNumber
    out_Zp_ar = "Z" & rowNumber
    out_aWebAct_ar = "AA" & rowNumber
    out_At_ar = "AB" & rowNumber
    out_dw_ar = "AC" & rowNumber
    out_bf_ar = "AD" & rowNumber
    out_S_ar = "AE" & rowNumber
    out_Ia_ar = "AF" & rowNumber
    out_Zsec_per_ar = "AG" & rowNumber
    out_Aw_per_ar = "AH" & rowNumber
    
    
    
    
    ' Execute the output
    ThisWorkbook.Sheets("3-Sect properties").Range(out_Zf_ar).Value = Zf_ar
    ThisWorkbook.Sheets("3-Sect properties").Range(out_Zp_ar).Value = Zp_ar
    ThisWorkbook.Sheets("3-Sect properties").Range(out_aWebAct_ar).Value = aWebAct_ar
    ThisWorkbook.Sheets("3-Sect properties").Range(out_At_ar).Value = At_ar
    ThisWorkbook.Sheets("3-Sect properties").Range(out_dw_ar).Value = dw_ar
    ThisWorkbook.Sheets("3-Sect properties").Range(out_bf_ar).Value = bf_ar
    ThisWorkbook.Sheets("3-Sect properties").Range(out_S_ar).Value = S_ar
    ThisWorkbook.Sheets("3-Sect properties").Range(out_Ia_ar).Value = Ia_ar
    ThisWorkbook.Sheets("3-Sect properties").Range(out_Zsec_per_ar).Value = Zsec_per_ar
    ThisWorkbook.Sheets("3-Sect properties").Range(out_Aw_per_ar).Value = Aw_per_ar
    
End Sub

Function FValue(spacing As Double, span As Double) As Double
    ' Perform the calculations
    FValue = Application.Min(0.3 * (Application.Min(span / spacing, 8)) ^ (2 / 3), 1)
End Function

Function EffectivePlateFlange(spacing As Double, adjacent As String, FValue As Double, primary_secondary As String, t_plate As Double) As Double
    ' Calculates the effective width of the plate
    If adjacent = "Yes" Then
        If primary_secondary = "Primary" Then
            EffectivePlateFlange = spacing * FValue / 2
        Else
            EffectivePlateFlange = Application.Min(40 * t_plate / 2, spacing / 2)
        End If
    Else
        If primary_secondary = "Primary" Then
            EffectivePlateFlange = spacing * FValue
        Else
            EffectivePlateFlange = Application.Min(40 * t_plate, spacing)
        End If
    End If

End Function


Function AreaTotalCS(eff_width As Double, t_plate As Double, w_flange As Double, t_flange_act As Double, t_web_act As Double, h_web As Double) As Double
    ' Calculates the total area of the cross-section
    AreaTotalCS = (eff_width * t_plate) + (w_flange * t_flange_act) + (t_web_act * h_web)
End Function


Function AreaCenteroid(eff_width As Double, t_plate As Double, w_flange As Double, t_flange_act As Double, t_web_act As Double, h_web As Double) As Double
    ' Calculates Area * Y
    ' Reassignment is required.
    ' the height of the flange will be its thickness in this calculation
    y_eff_plate = t_plate / 2
    y_web = t_plate + (h_web / 2)
    y_flange = t_plate + h_web + (t_flange_act / 2)
    
    AreaCenteroid = (eff_width * t_plate * y_eff_plate) + (t_web_act * h_web * y_web) + (t_flange_act * w_flange * y_flange)
End Function


Function AreaCenteroid2(eff_width As Double, t_plate As Double, w_flange As Double, t_flange_act As Double, t_web_act As Double, h_web As Double) As Double
    ' Calculates Area * Y
    ' Reassignment is required.
    ' the height of the flange will be its thickness in this calculation
    y_eff_plate = t_plate / 2
    y_web = t_plate + (h_web / 2)
    y_flange = t_plate + h_web + (t_flange_act / 2)
    
    AreaCenteroid2 = (eff_width * t_plate * (y_eff_plate) ^ 2) + (t_web_act * h_web * (y_web) ^ 2) + (t_flange_act * w_flange * (y_flange) ^ 2)
    
End Function


Function TotalDepth(eff_width As Double, t_plate As Double, w_flange As Double, t_flange_act As Double, t_web_act As Double, h_web As Double) As Double
    ' Calculates Total depth of the profile
    
    TotalDepth = t_plate + h_web + t_flange_act
    
End Function


Function IAboutNA(eff_width As Double, t_plate As Double, w_flange As Double, t_flange_act As Double, t_web_act As Double, h_web As Double) As Double
    ' Calculates moment of inertia about its own centroid
    
    IAboutNA = (eff_width * (t_plate) ^ 3) / 12 + (t_web_act * (h_web) ^ 3) / 12 + (w_flange * (t_flange_act) ^ 3) / 12
End Function


Function ReductionValue(category As String)
    If category = "b" Then
        ReductionValue = 1
    ElseIf category = "c" Then
        ReductionValue = 3
    ElseIf category = "d" Then
        ReductionValue = 3
    ElseIf category = "e" Then
        ReductionValue = 4
    End If
End Function

