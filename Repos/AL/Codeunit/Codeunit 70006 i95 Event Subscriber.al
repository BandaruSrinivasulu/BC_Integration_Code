Codeunit 70006 "i95 Event Subscriber"
{
    Permissions = tabledata "Sales Shipment Header" = rm, tabledata "Sales Shipment Line" = rm, tabledata "Sales Invoice Header" = rm, tabledata "Sales Invoice Line" = rm, tabledata "Issued Fin. Charge Memo Header" = rm, tabledata "Sales Cr.Memo Header" = rm, tabledata "Sales Cr.Memo Line" = rm;
    ;
    [EventSubscriber(ObjectType::Codeunit, codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', False, False)]
    local procedure OnAfterInitItemLedgEntry(VAR NewItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; VAR ItemLedgEntryNo: Integer)
    begin
        SetInventoryPendingSync(NewItemLedgEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Sales-Post", 'OnRunOnBeforeFinalizePosting', '', false, false)]
    local procedure OnRunOnBeforeFinalizePosting(Var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        Updatei95FieldsOnSalesPosting(SalesShipmentHeader, SalesInvoiceHeader, SalesCrMemoHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Shipment Header - Edit", 'OnBeforeSalesShptHeaderModify', '', false, false)]
    local procedure OnBeforeSalesShptHeaderModify(var SalesShptHeader: Record "Sales Shipment Header"; FromSalesShptHeader: Record "Sales Shipment Header")
    begin
        Updatei95SyncStatus(SalesShptHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Sales-Post", 'OnBeforePostSalesDoc', '', false, false)]
    local procedure OnBeforePostSalesDoc(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean)
    begin
        SalesHeader.SetCalledFromPosting(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforePostLines', '', false, false)]
    local procedure OnBeforePostLines(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    begin
        SalesLine.SetCalledFromPosting(true);
    end;

    local procedure SetInventoryPendingSync(ItemLedgEntry: Record "Item Ledger Entry")
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        i95Setup: Record "i95 Setup";
    begin
        //i95Setup.get();
        // if (i95Setup."i95 Default Warehouse" <> '') and (i95Setup."i95 Default Warehouse" <> ItemLedgEntry."Location Code") then
        //  exit;

        if (ItemLedgEntry."Variant Code" = '') and (Item.get(ItemLedgEntry."Item No.")) then
            Item.Seti95InventoryPendingSync()
        else
            if (ItemLedgEntry."Variant Code" <> '') and (ItemVariant.get(ItemLedgEntry."Item No.", ItemLedgEntry."Variant Code")) then
                ItemVariant.Seti95InventoryPendingSync();
    end;

    local procedure Updatei95FieldsOnSalesPosting(Var SalesShipmentHeader: Record "Sales Shipment Header"; Var SalesInvoiceHeader: Record "Sales Invoice Header"; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        i95EntityMapping: Record "i95 Entity Mapping";
    begin
        if (SalesShipmentHeader."No." <> '') then begin
            SalesShipmentHeader."i95 Created Date Time" := CurrentDateTime();
            i95EntityMapping.Reset();
            IF i95EntityMapping.FindSet() then;
            If i95EntityMapping."Allow Shipment Oubound Sync" = true then
                SalesShipmentHeader."i95 Sync Status" := SalesShipmentHeader."i95 Sync Status"::"Waiting for Sync";
            SalesShipmentHeader.Modify();
        end;

        if (SalesInvoiceHeader."No." <> '') then begin
            SalesInvoiceHeader."i95 Created Date Time" := CurrentDateTime();
            i95EntityMapping.Reset();
            IF i95EntityMapping.FindSet() then;
            If i95EntityMapping."Allow Invoice Oubound Sync" = true then
                SalesInvoiceHeader."i95 Sync Status" := SalesInvoiceHeader."i95 Sync Status"::"Waiting for Sync";
            SalesInvoiceHeader.Modify();
        end;
        if (SalesCrMemoHeader."No." <> '') then begin
            SalesCrMemoHeader."i95 Created Date Time" := CurrentDateTime();
            i95EntityMapping.Reset();
            IF i95EntityMapping.FindSet() then;
            If i95EntityMapping."Allow SalesCreditMemo Ob Sync" = true then
                SalesCrMemoHeader."i95 Sync Status" := SalesCrMemoHeader."i95 Sync Status"::"Waiting for Sync";
            SalesCrMemoHeader.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, 36, 'OnAfterGetNoSeriesCode', '', false, false)]
    local procedure OnAfterGetNoSeriesCode(var SalesHeader: Record "Sales Header"; SalesReceivablesSetup: Record "Sales & Receivables Setup"; var NoSeriesCode: Code[20])
    var
        i95Setup: Record "i95 Setup";
    begin

        IF SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            i95Setup.Get();
            if i95Setup."Order Nos." <> '' then
                NoSeriesCode := i95Setup."Order Nos."
        end;

    end;



    [EventSubscriber(ObjectType::Codeunit, 1535, 'OnRejectApprovalRequest', '', false, false)]
    local procedure OnRejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        SalesHeader: Record "Sales Header";
        i95PushWebService: Codeunit "i95 Push Webservice";
    begin
        SalesHeader.Reset();
        SalesHeader.SetRange("Document Type", ApprovalEntry."Document Type"::Quote);
        SalesHeader.SetRange("No.", ApprovalEntry."Document No.");
        IF SalesHeader.FindFirst() then begin
            i95PushWebService.CreateSyncLogforCancelSalesQuote(SalesHeader);
        end;
        // Message('Open:%1', ReopenvariableG);
    end;

    [EventSubscriber(ObjectType::Codeunit, 83, 'OnAfterSalesQuoteToOrderRun', '', false, false)]
    local procedure OnAfterSalesQuoteToOrderRun(var SalesHeader2: Record "Sales Header")
    begin
        IF SalesHeader2."Quote No." <> '' then begin
            SalesHeader2."i95 Reference ID" := '';
            SalesHeader2."i95 EditOrder Sync Status" := SalesHeader2."i95 EditOrder Sync Status"::" ";
            SalesHeader2.Modify();
        end;

    end;

    local procedure Updatei95SyncStatus(var SalShipmentHdr: Record "Sales Shipment Header")
    begin
        SalShipmentHdr.Updatei95Fields();
    end;

    [EventSubscriber(ObjectType::Codeunit, 395, 'OnAfterIssueFinChargeMemo', '', false, false)]
    procedure OnAfterIssueFinChargeMemo(VAR FinChargeMemoHeader: Record "Finance Charge Memo Header"; IssuedFinChargeMemoNo: Code[20])
    var
        IssuedFinanceChargeHeader: Record "Issued Fin. Charge Memo Header";
        EntityMapping: Record "i95 Entity Mapping";
    begin
        IF EntityMapping.FindSet() then;
        IssuedFinanceChargeHeader.Reset();
        IssuedFinanceChargeHeader.SetRange("No.", IssuedFinChargeMemoNo);
        IF IssuedFinanceChargeHeader.FindFirst() then begin
            IF EntityMapping."Allow Financecharge Ob Sync" = true then
                IssuedFinanceChargeHeader."i95 Sync Status" := IssuedFinanceChargeHeader."i95 Sync Status"::"Waiting for Sync";
            IssuedFinanceChargeHeader.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnAfterValidateEvent', 'Quantity', false, false)]
    procedure OnAfterValidateEvent(Rec: Record "Sales Line"; xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        itemL: Record Item;
        i95EntityMapping: Record "i95 Entity Mapping";
    begin
        IF itemL.get(Rec."No.") then begin
            //itemL.Seti95InventoryPendingSync();

            i95EntityMapping.Reset();
            IF i95EntityMapping.FindSet() then;
            IF i95EntityMapping."Allow Inventory Oubound Sync" = true then
                itemL."i95 Inventory Sync Status" := itemL."i95 Inventory Sync Status"::"Waiting for Sync";
            itemL."i95 Stock Last Update DateTime" := CurrentDateTime();
            itemL.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Table, 5790, 'OnAfterInsertEvent', '', false, false)]
    procedure OnAfterInsertEvent()
    var
        ShipAgentService: Record "Shipping Agent Services";
        ShippingAgent: Record "Shipping Agent";
        i95PushWebService: Codeunit "i95 Push Webservice";
    begin
        Sleep(1000);
        ShipAgentService.Reset();
        IF ShipAgentService.FindSet() then
            repeat
                i95PushWebService.SalesAgentPushData(ShipAgentService);
            until ShipAgentService.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, 5790, 'OnAfterDeleteEvent', '', false, false)]
    procedure OnAfterDeleteEvent()
    var
        ShipAgentService: Record "Shipping Agent Services";
        ShippingAgent: Record "Shipping Agent";
        i95PushWebService: Codeunit "i95 Push Webservice";
    begin
        Sleep(1000);
        ShipAgentService.Reset();
        IF ShipAgentService.FindSet() then
            repeat
                i95PushWebService.SalesAgentPushData(ShipAgentService);
            until ShipAgentService.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, 289, 'OnAfterInsertEvent', '', false, false)]
    procedure PaymentMethodPushData()
    var
        PaymentMethod: Record "Payment Method";
        i95PushWebService: Codeunit "i95 Push Webservice";
    begin
        Sleep(1000);
        PaymentMethod.Reset();
        IF PaymentMethod.FindSet() then
            repeat
                i95PushWebService.PaymentMethodPushData(PaymentMethod);
            until PaymentMethod.Next() = 0;
    end;


    [EventSubscriber(ObjectType::Table, 289, 'OnAfterDeleteEvent', '', false, false)]
    procedure PaymentMethodPushOnAfterDelete()
    var
        PaymentMethod: Record "Payment Method";
        i95PushWebService: Codeunit "i95 Push Webservice";
    begin
        Sleep(1000);
        PaymentMethod.Reset();
        IF PaymentMethod.FindSet() then
            repeat
                i95PushWebService.PaymentMethodPushData(PaymentMethod);
            until PaymentMethod.Next() = 0;
    end;

}