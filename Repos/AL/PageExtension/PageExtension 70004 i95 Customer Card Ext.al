PageExtension 70004 "i95 Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("i95 Customer Type"; Rec."i95 Customer Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the i95Dev Customer Type';
                Caption = 'Customer Type';
                Editable = true;
            }

        }
        addafter(Shipping)
        {
            group(i95)
            {
                Caption = 'i95Dev';
                Visible = Showi95Fields;
                field("i95 Created By"; Rec."i95 Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who created the customer';
                    Caption = 'Created By';
                }
                field("i95 Created DateTime"; Rec."i95 Created DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date time of customer creation';
                    Caption = 'Created DateTime';
                }
                field("i95 Creation Source"; Rec."i95 Creation Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source of creation';
                    Caption = 'Creation Source';
                }
                field("i95 Sync Status"; Rec."i95 Sync Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Sync Status';
                    Caption = 'Sync Status';
                }
                field("i95 Last Modified By"; Rec."i95 Last Modified By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who last modified the customer';
                    Caption = 'Last Modified By';
                }
                field("i95 Last Modification DateTime"; Rec."i95 Last Modification DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date time of last modification';
                    Caption = 'Last Modification DateTime';
                }
                field("i95 Last Modification Source"; Rec."i95 Last Modification Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source of last modification';
                    Caption = 'Last Modification Source';
                }
                field("i95 Last Sync DateTime"; Rec."i95 Last Sync DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date time of last i95Dev sync';
                    Caption = 'Last Sync DateTime';
                }
                field("i95 Reference ID"; Rec."i95 Reference ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the i95Dev Reference ID';
                    Caption = 'Reference ID';
                }

            }
        }
        modify(Name)
        {
            ShowMandatory = true;
        }
        modify("E-Mail")
        {
            ShowMandatory = true;
        }
    }

    var
        [InDataSet]
        Showi95Fields: Boolean;

    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId()) then
            Showi95Fields := UserSetup."i95 Show i95 Data"
    end;
}