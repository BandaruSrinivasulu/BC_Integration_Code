PageExtension 70006 "i95 Ship-to Address Ext" extends "Ship-to Address"
{
    layout
    {
        modify(General)
        {
            Editable = EditDefaultFromi95;
        }
        addafter(General)
        {
            group(i95)
            {
                Caption = 'i95Dev';
                Visible = Showi95Fields;
                field("i95 Is Default Shipping"; Rec."i95 Is Default Shipping")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies address is default shipping address';
                    Caption = 'Is Default Shipping';
                }
                field("i95 Created By"; Rec."i95 Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who created the Ship to address';
                    Caption = 'Created By';
                }
                field("i95 Created DateTime"; Rec."i95 Created DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date time of creation';
                    Caption = 'Created DateTime';
                }
                field("i95 Creation Source"; Rec."i95 Creation Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source of creation';
                    Caption = 'Creation Source';
                }
                field("i95 Last Modified By"; Rec."i95 Last Modified By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who last modified the ship to address';
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
                    ToolTip = 'Specifies the date time of last sync';
                    Caption = 'Last Sync DateTime';
                }
            }
        }
        modify(Name)
        {
            ShowMandatory = true;
        }
        modify(Address)
        {
            ShowMandatory = true;
        }
        modify("Phone No.")
        {
            ShowMandatory = true;
        }
        modify(City)
        {
            ShowMandatory = true;
        }
        modify("Country/Region Code")
        {
            ShowMandatory = true;
        }
        modify("Post Code")
        {
            ShowMandatory = true;
        }
    }

    var
        [InDataSet]
        Showi95Fields: Boolean;
        EditDefaultFromi95: Boolean;

    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId()) then
            Showi95Fields := UserSetup."i95 Show i95 Data";

        if Rec.Code = 'I95DEFAULT' then
            EditDefaultFromi95 := false
        else
            EditDefaultFromi95 := true;
    end;
}