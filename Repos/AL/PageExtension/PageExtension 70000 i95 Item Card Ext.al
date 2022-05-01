PageExtension 70000 "i95 Item Card Ext" extends "Item Card"
{
    layout
    {

        addlast(content)
        {
            group(i95)
            {
                Caption = 'i95Dev';
                Visible = Showi95Fields;
                field("i95 Created By"; Rec."i95 Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who Created the item ';
                    Caption = 'Created By';
                }
                field("i95 Created DateTime"; Rec."i95 Created DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Created Date Time';
                    Caption = 'Created DateTime';
                }
                field("i95 Creation Source"; Rec."i95 Creation Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Source of creation';
                    Caption = 'Creation Source';
                }
                field("i95 Last Modified By"; Rec."i95 Last Modified By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who modified the item';
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
                field("i95 Sync Status"; Rec."i95 Sync Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the i95Dev Sync Status';
                    Caption = 'i95Dev Sync Status';
                }
                field("i95 Last Sync DateTime"; Rec."i95 Last Sync DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date time of last sync';
                    Caption = 'Last Sync DateTime';
                }
                field("i95 Reference ID"; Rec."i95 Reference ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the i95Dev Reference ID';
                    Caption = 'Reference ID';
                }
                field("i95 Inventory Sync Status"; Rec."i95 Inventory Sync Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of i95Dev Inventory sync';
                    Caption = 'i95Dev Inventory Sync Status';
                }
                field("i95 Stock Last Sync DateTime"; Rec."i95 Stock Last Sync DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date time of last i95Dev stock sync';
                    Caption = 'i95Dev Stock Last Sync DateTime';
                }
                field("i95 Stock Last Update DateTime"; Rec."i95 Stock Last Update DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date time of last stock update ';
                    Caption = 'Stock Last Update DateTime';
                }
                field("i95 SalesPrice Sync Status"; Rec."i95 SalesPrice Sync Status")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the status of sales price sync';
                    Caption = 'SalesPrice Sync Status';
                }
                field("i95 SalesPrice Last Sync DateTime"; Rec."i95 SP Last SyncDateTime")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the date time of last i95Dev sync';
                    Caption = 'SalesPrice Last Sync DateTime';
                }
                field("i95 SalesPrice Last Updated DateTime"; Rec."i95 SP Last Updated DateTime")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the date time of Sales Price Last Updated';
                    Caption = 'SalesPrice Last Updated DateTime';
                }
                field("i95 DiscountPrice Sync Status"; Rec."i95 DiscountPrice Sync Status")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the status of Discount Price Sync';
                    Caption = 'DiscountPrice Sync Status';
                }
                field("i95 DP Last SyncDateTime"; Rec."i95 DiscPrice LastSyncDateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date time of last Discount Price i95Dev Sync';
                    Caption = 'DiscountPrice Last Sync DateTime';
                }
                field("i95 DP Last Updated DateTime"; Rec."i95 DiscPrice Updated DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date time of Discount Price Last Updated';
                    Caption = 'DiscountPrice Last Updated DateTime';
                }
                field("i95 Config Variant Sync Status"; Rec."i95 ItemVariant Sync Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of Config Item Variant Sync';
                    Caption = 'Config Item Variant Sync Status';
                    Visible = Showi95Fields;
                }
                field("i95 Config Last SyncDateTime"; Rec."i95 Variant Last SyncDateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date time of last Config Item Variant Sync';
                    Caption = 'Config ItemVariant Last Sync DateTime';
                    Visible = Showi95Fields;
                }
                field("i95 Config Updated DateTime"; Rec."i95 Variant Updated DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the datetime of Config Item Variant Last Updated';
                    Caption = 'Config ItemVariant Last Updated DateTime';
                    Visible = Showi95Fields;
                }
                field("i95 Child Variant Sync Status"; Rec."i95 Child Variant Sync Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Speciifes the status of Child Item Variant Sync';
                    Caption = 'Child Item Variant Sync Status';
                    Visible = Showi95Fields;
                }
                field("i95 Child Last SyncDateTime"; Rec."i95 Child Last SyncDateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date time of last Child Item Variant Sync';
                    Caption = 'Child ItemVariant Last Sync DateTime';
                    Visible = Showi95Fields;
                }
                field("i95 Child Updated DateTime"; Rec."i95 Child Updated DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the datetime of Child Item Variant Last Updated';
                    Caption = 'Child ItemVariant Last Updated DateTime';
                    Visible = Showi95Fields;
                }
            }
        }
        modify(Description)
        {
            ShowMandatory = true;
        }
        modify("Base Unit of Measure")
        {
            ShowMandatory = true;
        }
        modify("Gen. Prod. Posting Group")
        {
            ShowMandatory = true;
        }
        modify("Inventory Posting Group")
        {
            ShowMandatory = true;
        }
        modify("Tax Group Code")
        {
            ShowMandatory = true;
        }
    }

    var
        [InDataSet]
        Showi95Fields: Boolean;

    trigger OnOpenPage();
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId()) then
            Showi95Fields := UserSetup."i95 Show i95 Data";
    end;
}