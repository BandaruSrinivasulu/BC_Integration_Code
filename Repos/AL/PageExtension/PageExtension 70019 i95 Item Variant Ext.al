pageextension 70019 "i95 Item Variant Ext" extends "Item Variants"
{
    layout
    {
        addafter(Description)
        {
            field("i95 Created By"; Rec."i95 Created By")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies who created the Item Variant';
                Caption = 'Created By';
                Visible = Showi95Fields;
            }
            field("i95 Created DateTime"; Rec."i95 Created DateTime")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date time of Item Variant created';
                Caption = 'Created DateTime';
                Visible = Showi95Fields;
            }
            field("i95 Creation Source"; Rec."i95 Creation Source")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the source of creation';
                Caption = 'Creation Source';
                Visible = Showi95Fields;
            }
            field("i95 Reference ID"; Rec."i95 Reference ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the Reference Id';
                Caption = 'i95 Reference Id';
                Visible = Showi95Fields;
            }

            field("i95 Last Modified By"; Rec."i95 Last Modified By")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies who last modified the Item Variant';
                Caption = 'Last Modified By';
                Visible = Showi95Fields;
            }
            field("i95 Last Modification DateTime"; Rec."i95 Last Modification DateTime")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date time of last modification';
                Caption = 'Last Modification DateTime';
                Visible = Showi95Fields;
            }
            field("i95 Last Modification Source"; Rec."i95 Last Modification Source")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the source of last modification';
                Caption = 'Last Modification Source';
                Visible = Showi95Fields;
            }
            field("i95 Inventory Sync Status"; Rec."i95 Inventory Sync Status")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the status of i95Dev Inventory sync';
                Caption = 'i95Dev Inventory Sync Status';
                Visible = Showi95Fields;
            }
            field("i95 Stock Last Sync DateTime"; Rec."i95 Stock Last Sync DateTime")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date time of last i95Dev stock sync';
                Caption = 'i95Dev Stock Last Sync DateTime';
                Visible = Showi95Fields;
            }
            field("i95 Stock Last Update DateTime"; Rec."i95 Stock Last Update DateTime")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date time of last stock update ';
                Caption = 'Stock Last Update DateTime';
                Visible = Showi95Fields;
            }
            field("i95 SalesPrice Sync Status"; Rec."i95 SalesPrice Sync Status")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the status of i95Dev Item Variant SalesPrice sync';
                Caption = 'i95Dev SalePrice Sync Status';
                Visible = Showi95Fields;
            }
        }
        modify(Code)
        {
            ShowMandatory = true;
        }
        modify(Description)
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