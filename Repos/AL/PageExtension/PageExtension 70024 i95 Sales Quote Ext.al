pageextension 70024 "i95 Sales Quote Ext" extends "Sales Quote"
{
    layout
    {

        addafter("Foreign Trade")
        {
            group(i95)
            {
                Caption = 'i95Dev';
                Visible = Showi95Fields;
                field("i95 Created By"; Rec."i95 Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specified who created the Sales Order';
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
                    ToolTip = 'Specifies the Source of creation';
                    Caption = 'Creation Source';
                }
                field("i95 Sync Status"; Rec."i95 Sync Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the i95Dev sync status';
                    Caption = 'Sync Status';
                }
                field("i95 Last Modified By"; Rec."i95 Last Modified By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who last modified the sales order';
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
                field("i95 Sync Message"; Rec."i95 Sync Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the error message before Sync';
                    Caption = 'Sync Message';
                }
                field("i95 Order Status"; Rec."i95 Order Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order status';
                    Caption = 'Order Status';
                }
                /*  field("i95 EditOrder Sync Status"; "i95 EditOrder Sync Status")
                  {
                      ApplicationArea = All;
                      ToolTip = 'Specifies the Sync Status for Edit Order';
                      Caption = 'EditOrder Sync Status';
                  }
                  field("i95 EditOrder Updated DateTime"; "i95 EditOrder Updated DateTime")
                  {
                      ApplicationArea = All;
                      ToolTip = 'Specifies the updated datetime of Edit Order';
                      Caption = 'EditOrder Updated DateTime';
                  }
                  field("i95 EditOrd Last SyncDateTime"; "i95 EditOrd Last SyncDateTime")
                  {
                      ApplicationArea = All;
                      ToolTip = 'Specifies the last Sync DateTime of Edit Order';
                      Caption = 'EditOrder Last Sync DateTime';
                  }*/



            }
        }
        modify("Sell-to Customer No.")
        {
            ShowMandatory = true;
        }
        modify("No.")
        {
            ShowMandatory = true;
        }
    }

    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserID()) then
            Showi95Fields := UserSetup."i95 Show i95 Data"
    end;

    trigger OnDeleteRecord(): Boolean
    var
        i95PushWebService: Codeunit "i95 Push Webservice";
        ConfirmDeleteTxt: Label 'Sales Quote already Synced. Do you wish to Cancel Quote %1 ?';
        Salesline: Record "Sales Line";
    begin

        IF (Rec."Document Type" = Rec."Document Type"::Quote) and (Rec."i95 Reference ID" <> '') then
            if Confirm(StrSubstNo(confirmDeleteTxt, Rec."No."), false) then begin
                i95SkipOnDelete := true;
                i95PushWebService.CreateSyncLogforCancelSalesQuote(Rec);
            end;

        i95SkipOnDelete := false;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if (Rec."i95 Reference ID" = '') then begin
            if i95SkipOnDelete then
                exit;

            Rec.CheckIfi95SyncAllowed();

            if Rec."i95 Sync Message" <> '' then begin
                Rec."i95 Sync Status" := Rec."i95 Sync Status"::"InComplete Data";
                Rec.modify();
            end else
                if Rec."i95 Sync Status" > Rec."i95 Sync Status"::"Waiting for Sync" then begin
                    if Rec.i95SalesLineModificationExists() then begin
                        Rec."i95 Sync Status" := Rec."i95 Sync Status"::"Waiting for Sync";
                        Rec.modify();
                    end;
                end else
                    if (Rec."i95 Sync Message" = '') and (Rec."i95 Sync Status" = Rec."i95 Sync Status"::"InComplete Data") then begin
                        i95EntityMapping.Reset();
                        IF i95EntityMapping.FindSet() then;
                        IF i95EntityMapping."Allow SalesQuote Outbound Sync" = true then
                            Rec."i95 Sync Status" := Rec."i95 Sync Status"::"Waiting for Sync";
                        Rec.modify();
                    end;
        end;
    end;

    var
        [InDataSet]
        Showi95Fields: Boolean;
        i95SkipOnDelete: Boolean;
        i95EntityMapping: Record "i95 Entity Mapping";
}