page 70004 "i95 Test API Call"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'i95Dev Test API Call';
    layout
    {
        area(Content)
        {

        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            group("PushData")
            {
                action("Process SalesInvoice PushData API")
                {
                    Image = SalesInvoice;
                    Caption = 'Sales Invoice';
                    ToolTip = 'Process SalesInvoice PushData API';
                    ApplicationArea = All;

                    trigger OnAction();
                    var
                        SalesInvoiceHeader: Record "Sales Invoice Header";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        SalesInvoiceHeader.reset();
                        SalesInvoiceHeader.SetCurrentKey(SalesInvoiceHeader."i95 Sync Status");
                        SalesInvoiceHeader.SetRange("i95 Sync Status", SalesInvoiceHeader."i95 Sync Status"::"Waiting for Sync");
                        If SalesInvoiceHeader.FindSet() then
                            i95PushWebservice.SalesInvoicePushData(SalesInvoiceHeader);
                    end;
                }
                action("Process SalesShipment PushData API")
                {
                    Image = SalesShipment;
                    Caption = 'Sales Shipment';
                    ToolTip = 'Process SalesShipment PushData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        SalesShipmentHeader: Record "Sales Shipment Header";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        SalesShipmentHeader.Reset();
                        SalesShipmentHeader.SetCurrentKey(SalesShipmentHeader."i95 Sync Status");
                        SalesShipmentHeader.SetRange("i95 Sync Status", SalesShipmentHeader."i95 Sync Status"::"Waiting for Sync");
                        if SalesShipmentHeader.Findset() then
                            i95PushWebservice.SalesShipmentPushData(SalesShipmentHeader);
                    end;
                }
                action("Process Inventory PushData API")
                {
                    Image = Inventory;
                    Caption = 'Inventory';
                    ToolTip = 'Process Inventory PushData API';
                    ApplicationArea = All;
                    trigger OnAction();
                    var
                        Item: Record Item;
                        ItemVariant: Record "Item Variant";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                        index: Integer;
                        index1: Integer;
                        lstItems: List of [Code[20]];
                        lstItems1: List of [Code[20]];
                        isPacketCreated: Boolean;
                        result: Boolean;
                        packetSize: Integer;
                        Item1: Record Item;
                        itemNo: Code[20];
                        packetItemNos: Text;
                        i95Devsetup: Record "i95 Setup";
                    begin
                        Item.SetCurrentKey(Item."i95 Inventory Sync Status");
                        Item.SetRange(Item."i95 Inventory Sync Status", item."i95 Inventory Sync Status"::"Waiting for Sync");

                        #region Packet Entries
                        if item.FindSet() then begin
                            repeat begin
                                if item."No." <> '' then begin
                                    lstItems.Add(item."No.");
                                end;
                            end until item.Next() = 0;

                            i95Devsetup.Get();
                            packetSize := i95Devsetup."Pull Data Packet Size";

                            Clear(index);
                            index := 1;
                            if lstItems.Count() > 0 then begin
                                repeat begin
                                    packetItemNos := '';
                                    Clear(lstItems1);
                                    Item1.Reset();
                                    Clear(Item1);
                                    isPacketCreated := lstItems.GetRange(index, packetSize, lstItems1);
                                    if isPacketCreated then begin
                                        result := true;
                                        foreach itemno in lstItems1 do begin
                                            packetItemNos := packetItemNos + itemNo + '|';
                                        end;
                                        packetItemNos := packetItemNos.Remove(packetItemNos.LastIndexOf('|'));

                                        //Sending the packet to the cloud
                                        Item1.SetFilter("No.", packetItemNos);
                                        i95PushWebService.InventoryPushData(Item1);

                                        index := index + packetSize;
                                    end else begin
                                        Clear(itemNo);
                                        Clear(packetItemNos);
                                        Clear(lstItems1);
                                        Item1.Reset();
                                        Clear(Item1);
                                        isPacketCreated := lstItems.GetRange(index, lstItems.Count() mod packetSize, lstItems1);
                                        if isPacketCreated then begin
                                            if lstItems1.Count() > 0 then begin
                                                result := true;
                                                foreach itemno in lstItems1 do begin
                                                    packetItemNos := packetItemNos + itemNo + '|';
                                                end;
                                                packetItemNos := packetItemNos.Remove(packetItemNos.LastIndexOf('|'));

                                                //Sending the packet to the cloud
                                                Item1.SetFilter("No.", packetItemNos);
                                                i95PushWebService.InventoryPushData(Item1);
                                            end;

                                        end else begin
                                            result := false;
                                        end;
                                        index := index + packetSize;
                                    end;
                                end until result = false;
                            end;
                        end;

                        #endregion


                        // If Item.Findset() then
                        //     i95PushWebservice.InventoryPushData(Item);

                        ItemVariant.SetCurrentKey("i95 Inventory Sync Status");
                        ItemVariant.SetRange("i95 Inventory Sync Status", ItemVariant."i95 Inventory Sync Status"::"Waiting for Sync");
                        if ItemVariant.FindSet() then
                            i95PushWebService.VariantInventoryPushData(ItemVariant);
                    end;
                }
                action("Process Sales Price PushData API")
                {
                    Image = SalesPrices;
                    Caption = 'Sales Price';
                    ToolTip = 'Process Sales Price PushData API';
                    ApplicationArea = All;
                    trigger OnAction();
                    var
                        Item: Record Item;
                        Itemvariant: Record "Item Variant";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                        SalePrice: Record "Sales Price";
                    //SalePrice: Record "Price List Line";
                    begin
                        Item.Reset();
                        Item.SetCurrentKey(Item."i95 SalesPrice Sync Status");
                        Item.SetRange(Item."i95 SalesPrice Sync Status", Item."i95 SalesPrice Sync Status"::"Waiting for Sync");
                        if Item.FindSet() then begin
                            repeat
                                SalePrice.Reset();
                                SalePrice.SetRange("Item No.", Item."No.");
                                //SalePrice.SetRange("Asset Type", SalePrice."Asset Type"::Item);
                                // SalePrice.SetRange("Asset No.", Item."No.");
                                SalePrice.SetFilter("Variant Code", '=%1', '');
                                IF SalePrice.FindFirst() then
                                    i95PushWebservice.SalesPricePushData(Item);
                            until item.Next() = 0;
                        end;

                        Itemvariant.Reset();
                        itemVariant.SetCurrentKey(itemVariant."i95 SalesPrice Sync Status");
                        Itemvariant.SetRange(Itemvariant."i95 SalesPrice Sync Status", Itemvariant."i95 SalesPrice Sync Status"::"Waiting for Sync");
                        IF itemVariant.FindSet() then
                            repeat
                                SalePrice.Reset();
                                SalePrice.SetRange("Item No.", Itemvariant."Item No.");
                                //SalePrice.SetRange("Asset Type", SalePrice."Asset Type"::Item);
                                //SalePrice.SetRange("Asset No.", Itemvariant."Item No.");
                                SalePrice.SetRange("Variant Code", Itemvariant.Code);
                                IF SalePrice.FindFirst() then
                                    i95PushWebService.SalesPriceVariantPushData(itemVariant);
                            until itemVariant.Next() = 0;

                    end;
                }
                action("Process Product PushData API")
                {
                    Image = Item;
                    Caption = 'Product';
                    ToolTip = 'Process Product PushData API';
                    ApplicationArea = All;
                    trigger OnAction();
                    var
                        Item: Record Item;
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                        EntityMapping: Record "i95 Entity Mapping";
                    begin
                        Item.SetCurrentKey(Item."i95 Sync Status");
                        Item.SetRange("i95 Sync Status", item."i95 Sync Status"::"Waiting for Sync");
                        If Item.Findset() then
                            i95PushWebservice.ProductPushData(Item);
                    end;
                }
                action(CustomerPushDataTest)
                {
                    Image = Customer;
                    Caption = 'Customer';
                    ToolTip = 'Process Customer PushData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        Customer: Record customer;
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        Customer.SetCurrentKey(Customer."i95 Sync Status");
                        Customer.SetRange("i95 Sync Status", Customer."i95 Sync Status"::"Waiting for Sync");
                        If Customer.FindSet() then
                            i95PushWebservice.CustomerPushData(customer);
                    end;
                }

                action(CustomerGrpPushDataTest)
                {
                    Image = CustomerGroup;
                    Caption = 'Customer Price Group';
                    ToolTip = 'Process Customer Price Group PushData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        CustPriceGrp: Record "Customer Price Group";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        CustPriceGrp.SetCurrentKey(CustPriceGrp."i95 Sync Status");
                        CustPriceGrp.SetRange("i95 Sync Status", CustPriceGrp."i95 Sync Status"::"Waiting for Sync");
                        If CustPriceGrp.FindSet() then
                            i95PushWebservice.CustomerPriceGroupPushData(CustPriceGrp);
                    end;
                }
                action(SalesOrderPushDataTest)
                {
                    Image = Order;
                    Caption = 'Sales Order';
                    ToolTip = 'Process Sales Order PushData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        SalHdr: Record "Sales Header";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        SalHdr.Reset();
                        SalHdr.SetCurrentKey(SalHdr."i95 Sync Status");
                        SalHdr.SetRange("Document Type", SalHdr."Document Type"::Order);
                        SalHdr.SetRange("i95 Sync Status", SalHdr."i95 Sync Status"::"Waiting for Sync");
                        If SalHdr.FindSet() then
                            i95PushWebservice.SalesOrderPushData(SalHdr);
                    end;
                }
                action(SalesQuotePushDataTest)
                {
                    Image = Order;
                    Caption = 'Sales Quote';
                    ToolTip = 'Process Sales Quote PushData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        SalHdr: Record "Sales Header";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        SalHdr.Reset();
                        SalHdr.SetCurrentKey(SalHdr."i95 Sync Status");
                        SalHdr.SetRange("Document Type", SalHdr."Document Type"::Quote);
                        SalHdr.SetRange(Status, SalHdr.Status::Released);
                        SalHdr.SetRange("i95 Sync Status", SalHdr."i95 Sync Status"::"Waiting for Sync");
                        If SalHdr.FindSet() then
                            i95PushWebservice.SalesQuotePushData(SalHdr);

                    end;
                }
                action(SalesReturnOrderPushDataTest)
                {
                    Image = Order;
                    Caption = 'Sales Return Order';
                    ToolTip = 'Process Sales Return Order PushData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        SalHdr: Record "Sales Header";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        SalHdr.Reset();
                        SalHdr.SetCurrentKey(SalHdr."i95 Sync Status");
                        SalHdr.SetRange("Document Type", SalHdr."Document Type"::"Return Order");
                        SalHdr.SetRange("i95 Sync Status", SalHdr."i95 Sync Status"::"Waiting for Sync");
                        If SalHdr.FindSet() then
                            i95PushWebservice.SalesReturnPushData(SalHdr);

                    end;
                }
                action("SalesCreditMemoAPI")
                {
                    Image = SalesShipment;
                    Caption = 'Sales Credit Memo';
                    ToolTip = 'Process Sales Credit Memo PushData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        SalesCreditMemoHeader: Record "Sales Cr.Memo Header";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        SalesCreditMemoHeader.Reset();
                        SalesCreditMemoHeader.SetCurrentKey("i95 Sync Status");
                        //  SalesCreditMemoHeader.SetRange("Document Type", SalesCreditMemoHeader."Document Type"::Payment);
                        SalesCreditMemoHeader.SetRange(SalesCreditMemoHeader."i95 Sync Status", SalesCreditMemoHeader."i95 Sync Status"::"Waiting for Sync");
                        IF SalesCreditMemoHeader.FindSet() then
                            i95PushWebservice.SalesCreditmemoPushData(SalesCreditMemoHeader);


                    end;
                }
                action(CancelSalesOrderPushDataTest)
                {
                    Image = Cancel;
                    Caption = 'Cancel Sales Order';
                    ToolTip = 'Process Cancelled Sales Order PushData API';
                    ApplicationArea = All;
                    trigger OnAction();
                    var
                        i95SyncLogEntry: Record "i95 Sync Log Entry";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        i95SyncLogEntry.Reset();
                        i95SyncLogEntry.SetCurrentKey(i95SyncLogEntry."Sync Source", i95SyncLogEntry."API Type", i95SyncLogEntry."Sync Status");
                        i95SyncLogEntry.SetRange(i95SyncLogEntry."Sync Source", i95SyncLogEntry."Sync Source"::"Business Central");
                        i95SyncLogEntry.SetRange(i95SyncLogEntry."API Type", i95SyncLogEntry."API Type"::CancelOrder);
                        i95SyncLogEntry.SetRange(i95SyncLogEntry."Sync Status", i95SyncLogEntry."Sync Status"::"Waiting for Sync");
                        if i95SyncLogEntry.FindSet() then
                            repeat
                                i95PushWebService.CancelSalesOrderPushData(i95SyncLogEntry);
                            until i95SyncLogEntry.Next() = 0;
                    end;
                }
                action(CancelQuotePushDataTest)
                {
                    Image = Cancel;
                    Caption = 'Cancel Quote';
                    ToolTip = 'Process Cancelled Sales Quote PushData API';
                    ApplicationArea = All;
                    trigger OnAction();
                    var
                        i95SyncLogEntry: Record "i95 Sync Log Entry";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        i95SyncLogEntry.Reset();
                        i95SyncLogEntry.SetCurrentKey(i95SyncLogEntry."Sync Source", i95SyncLogEntry."API Type", i95SyncLogEntry."Sync Status");
                        i95SyncLogEntry.SetRange(i95SyncLogEntry."Sync Source", i95SyncLogEntry."Sync Source"::"Business Central");
                        i95SyncLogEntry.SetRange(i95SyncLogEntry."API Type", i95SyncLogEntry."API Type"::CancelQuote);
                        i95SyncLogEntry.SetRange(i95SyncLogEntry."Sync Status", i95SyncLogEntry."Sync Status"::"Waiting for Sync");
                        if i95SyncLogEntry.FindSet() then
                            repeat
                                i95PushWebService.CancelSalesQuotePushData(i95SyncLogEntry);
                            until i95SyncLogEntry.Next() = 0;

                    end;
                }


                action(TaxBusPostingGrpPushDataTest)
                {
                    Image = TaxDetail;
                    Caption = 'Tax Business Posting Group';
                    ToolTip = 'Process Tax Business Posting Group PushData API';
                    ApplicationArea = All;
                    trigger OnAction();
                    var
                        TaxBusPostingGrp: Record "VAT Business Posting Group";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        TaxBusPostingGrp.Reset();
                        TaxBusPostingGrp.SetCurrentKey("i95 Sync Status");
                        TaxBusPostingGrp.SetRange(TaxBusPostingGrp."i95 Sync Status", TaxBusPostingGrp."i95 Sync Status"::"Waiting for Sync");
                        If TaxBusPostingGrp.FindSet() then
                            i95PushWebService.TaxBusPostingGrpPushData(TaxBusPostingGrp);
                    end;
                }
                action(TaxProdPostingGrpPushDataTest)
                {
                    Image = TaxPayment;
                    Caption = 'Tax Product Posting Group';
                    ToolTip = 'Process Tax Product Posting Group PushData API';
                    ApplicationArea = All;
                    trigger OnAction();
                    var
                        TaxProdPostingGrp: Record "VAT Product Posting Group";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        TaxProdPostingGrp.Reset();
                        TaxProdPostingGrp.SetCurrentKey("i95 Sync Status");
                        TaxProdPostingGrp.SetRange(TaxProdPostingGrp."i95 Sync Status", TaxProdPostingGrp."i95 Sync Status"::"Waiting for Sync");
                        If TaxProdPostingGrp.FindSet() then
                            i95PushWebService.TaxProdPostingGrpPushData(TaxProdPostingGrp);
                    end;
                }

                action(PaymentTermPushDataTest)
                {
                    Image = PaymentPeriod;
                    Caption = 'Payment Term';
                    ToolTip = 'Process Payment Term PushData API';
                    ApplicationArea = All;
                    trigger OnAction();
                    var
                        PaymentTerms: Record "Payment Terms";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        PaymentTerms.Reset();
                        PaymentTerms.SetCurrentKey("i95 Sync Status");
                        PaymentTerms.SetRange(PaymentTerms."i95 Sync Status", PaymentTerms."i95 Sync Status"::"Waiting for Sync");
                        If PaymentTerms.FindSet() then
                            i95PushWebService.PaymentTermPushData(PaymentTerms);
                    end;
                }

                action(TaxPostingSetupPushDataTest)
                {
                    Image = TaxSetup;
                    Caption = 'Tax Posting Setup';
                    ToolTip = ' Process Tax Posting Setup PushData API';
                    ApplicationArea = All;
                    trigger OnAction();
                    var
                        TaxPostingSetup: Record "VAT Posting Setup";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        TaxPostingSetup.Reset();
                        TaxPostingSetup.SetCurrentKey(TaxPostingSetup."i95 Sync Status");
                        TaxPostingSetup.SetRange(TaxPostingSetup."i95 Sync Status", TaxPostingSetup."i95 Sync Status"::"Waiting for Sync");
                        if TaxPostingSetup.FindSet() then
                            i95PushWebService.TaxPostingSetupPushData(TaxPostingSetup);
                    end;
                }
                action(CustDiscountGroupPushDataTest)
                {
                    Image = Discount;
                    Caption = 'Customer Discount Group';
                    ToolTip = 'Process Customer Discount Group PushData API';
                    ApplicationArea = All;
                    trigger OnAction();
                    var
                        CustDiscountGroup: Record "Customer Discount Group";
                        i95PushWebService: Codeunit "i95 Push Webservice";
                    begin
                        CustDiscountGroup.Reset();
                        CustDiscountGroup.SetCurrentKey(CustDiscountGroup."i95 Sync Status");
                        CustDiscountGroup.SetRange(CustDiscountGroup."i95 Sync Status", CustDiscountGroup."i95 Sync Status"::"Waiting for Sync");
                        if CustDiscountGroup.FindSet() then
                            i95PushWebService.CustomerDiscGroupPushData(CustDiscountGroup);
                    end;
                }
                action(ItemDiscountGroupPushDataTest)
                {
                    Image = ItemCosts;
                    Caption = 'Item Discount Group';
                    ToolTip = 'Process Item Discount Group PushData API';
                    ApplicationArea = All;
                    trigger OnAction();
                    var
                        ItemDiscountGroup: Record "Item Discount Group";
                        i95PushWebService: Codeunit "i95 Push Webservice";
                    begin
                        ItemDiscountGroup.Reset();
                        ItemDiscountGroup.SetCurrentKey(ItemDiscountGroup."i95 Sync Status");
                        ItemDiscountGroup.SetRange(ItemDiscountGroup."i95 Sync Status", ItemDiscountGroup."i95 Sync Status"::"Waiting for Sync");
                        if ItemDiscountGroup.FindSet() then
                            i95PushWebService.ItemDiscGroupPushData(ItemDiscountGroup);
                    end;
                }
                action(DiscountPricePushDataTest)
                {
                    Image = SalesLineDisc;
                    Caption = 'Discount Price';
                    ToolTip = 'Process Discount Price PushData API';
                    ApplicationArea = All;
                    trigger OnAction();
                    var
                        Item: Record item;
                        ItemDiscGroup: Record "Item Discount Group";
                        i95PushWebService: Codeunit "i95 Push Webservice";
                    begin
                        Item.SetCurrentKey("i95 DiscountPrice Sync Status");
                        Item.SetRange(Item."i95 DiscountPrice Sync Status", Item."i95 DiscountPrice Sync Status"::"Waiting for Sync");
                        If Item.FindSet() then
                            i95PushWebService.DiscountPricePushData(Item);

                        ItemDiscGroup.SetCurrentKey("i95 DiscountPrice Sync Status");
                        ItemDiscGroup.SetRange(ItemDiscGroup."i95 DiscountPrice Sync Status", ItemDiscGroup."i95 DiscountPrice Sync Status"::"Waiting for Sync");
                        if ItemDiscGroup.FindSet() then
                            i95PushWebService.DiscountPriceByItemDiscGrpPushData(ItemDiscGroup);
                    end;
                }
                action(ItemVariantPushDataTest)
                {
                    Image = ItemVariant;
                    Caption = 'Item Variant';
                    ToolTip = 'Process Item Variant PushData API';
                    ApplicationArea = All;
                    trigger OnAction();
                    var
                        Item: Record item;
                        i95PushWebService: Codeunit "i95 Push Webservice";
                    begin
                        Item.SetCurrentKey(Item."i95 ItemVariant Sync Status");
                        Item.SetRange(item."i95 ItemVariant Sync Status", item."i95 ItemVariant Sync Status"::"Waiting for Sync");
                        If Item.Findset() then
                            i95PushWebService.ConfigurableProductPushData(Item);

                        item.Reset();
                        Item.SetCurrentKey(Item."i95 Child Variant Sync Status");
                        Item.SetRange(item."i95 Child Variant Sync Status", item."i95 Child Variant Sync Status"::"Waiting for Sync");
                        If Item.Findset() then
                            i95PushWebService.ChildProductPushData(Item);
                    end;
                }
                action(EditSalesOrderPushDataTest)
                {
                    Image = EditJournal;
                    Caption = 'Edit Sales Order';
                    ToolTip = 'Process Edit Sales Order Pushdata API';
                    ApplicationArea = All;
                    trigger OnAction();
                    var
                        SalesHeader: Record "Sales Header";
                        i95PushWebService: Codeunit "i95 Push Webservice";
                    begin
                        SalesHeader.SetCurrentKey("i95 EditOrder Sync Status");
                        SalesHeader.SetRange(SalesHeader."Document Type", SalesHeader."Document Type"::Order);
                        SalesHeader.SetRange(SalesHeader."i95 EditOrder Sync Status", SalesHeader."i95 EditOrder Sync Status"::"Waiting for Sync");
                        If SalesHeader.FindSet() then
                            i95PushWebService.EditSalesOrderPushData(SalesHeader);
                    end;
                }
                action("Process AccountRecievable PushData API")
                {
                    Image = SalesShipment;
                    Caption = 'Account Recievable';
                    ToolTip = 'Process AccountRecievable PushData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        CustomerLedgerEntry: Record "Cust. Ledger Entry";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        CustomerLedgerEntry.Reset();
                        CustomerLedgerEntry.SetCurrentKey("i95 Sync Status");
                        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Invoice);
                        CustomerLedgerEntry.SetRange(CustomerLedgerEntry."i95 Sync Status", CustomerLedgerEntry."i95 Sync Status"::"Waiting for Sync");
                        IF CustomerLedgerEntry.FindSet() then
                            i95PushWebService.AccountRecievablePushData(CustomerLedgerEntry);
                    end;
                }
                action("Process CashReciept PushData API")
                {
                    Image = SalesShipment;
                    Caption = 'Cash Reciept';
                    ToolTip = 'Process CashReciept PushData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        CustomerLedgerEntry: Record "Cust. Ledger Entry";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        CustomerLedgerEntry.Reset();
                        CustomerLedgerEntry.SetCurrentKey("i95 Sync Status");
                        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Payment);
                        CustomerLedgerEntry.SetRange(CustomerLedgerEntry."i95 Sync Status", CustomerLedgerEntry."i95 Sync Status"::"Waiting for Sync");
                        IF CustomerLedgerEntry.FindSet() then
                            i95PushWebservice.PostedCashRecieptPushData(CustomerLedgerEntry);

                    end;
                }
                action("Process FinanceCharge API")
                {
                    Caption = 'Finance Charge';
                    ToolTip = 'Process FinanceCharge PushData API';
                    ApplicationArea = all;
                    trigger OnAction();

                    var
                        IssuedFinanceCharge: Record "Issued Fin. Charge Memo Header";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        IssuedFinanceCharge.Reset();
                        IssuedFinanceCharge.SetCurrentKey("i95 Sync Status");
                        IssuedFinanceCharge.SetRange(IssuedFinanceCharge."i95 Sync Status", IssuedFinanceCharge."i95 Sync Status"::"Waiting for Sync");
                        IF IssuedFinanceCharge.FindSet() then
                            i95PushWebService.FinanceChargePushData(IssuedFinanceCharge);

                    end;
                }
                action(SalesPersonPushData)
                {
                    Image = Warehouse;
                    Caption = 'Sales Person';
                    ToolTip = 'Process Sales Person PushData API';
                    ApplicationArea = All;
                    trigger OnAction();
                    var
                        SalesPerson: Record "Salesperson/Purchaser";
                        i95PushWebservice: Codeunit "i95 Push Webservice";
                    begin
                        SalesPerson.Reset();
                        SalesPerson.SetCurrentKey("i95 Sync Status");
                        SalesPerson.SetRange(SalesPerson."i95 Sync Status", SalesPerson."i95 Sync Status"::"Waiting for Sync");
                        If SalesPerson.FindSet() then
                            i95PushWebService.SalesPersonPushData(SalesPerson);
                    end;
                }

                action(LocationPushData)
                {
                    Image = SalesPerson;
                    Caption = 'location';
                    ToolTip = 'Process Location PushData API';
                    ApplicationArea = All;
                    trigger OnAction();
                    var
                        Location: Record Location;
                        i95PushWebService: Codeunit "i95 Push Webservice";
                    begin
                        Location.Reset();
                        Location.SetCurrentKey("i95 Sync Status");
                        Location.SetRange("i95 Sync Status", Location."i95 Sync Status"::"Waiting for Sync");
                        IF Location.FindSet() then
                            i95PushWebService.WarehouseLocationPushData(Location);
                    end;
                }
                action(ProductwithMappingPushData)
                {
                    Image = Action;
                    Caption = 'Product with Mapping Attribute';
                    ToolTip = 'Product With Mapping Attribute PushData API';
                    ApplicationArea = All;
                    trigger OnAction();
                    var
                        Item: Record Item;
                        ItemVariant: Record "Item Variant";
                        i95PushWebService: Codeunit "i95 Push Webservice";
                    begin
                        Item.SetCurrentKey("i95 Sync Status");
                        item.SetRange(item."i95 Sync Status", item."i95 Sync Status"::"Waiting for Sync");
                        If Item.findset() then begin
                            ItemVariant.Reset();
                            ItemVariant.SetRange(ItemVariant."Item No.", Item."No.");
                            If ItemVariant.IsEmpty() then
                                i95PushWebService.ProductPushDatawithMapping(Item)
                            else begin
                                i95PushWebService.ConfigurableProductPushData(Item);
                                i95PushWebService.ChildProductPushData(Item);
                            end;
                        end;
                    end;
                }


            }
            group("PullData")
            {
                action(CustomerPullDataTest)
                {
                    Image = Customer;
                    Caption = 'Customer';
                    ToolTip = 'Process Customer PullData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        i95PullWebservice: Codeunit "i95 Pull Webservice";
                    begin
                        i95PullWebservice.ProcessPullData(CurrentAPIType::Customer, SchedulerType::PullData);
                    end;
                }
                action(CustomerGroupPullDataTest)
                {
                    Image = CustomerGroup;
                    Caption = 'Customer Price Group';
                    ToolTip = 'Process Customer Price Group PullData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        i95PullWebservice: Codeunit "i95 Pull Webservice";
                    begin
                        i95PullWebservice.ProcessPullData(CurrentAPIType::CustomerGroup, SchedulerType::PullData);
                    end;
                }
                action(SalesOrderPullDataTest)
                {
                    Image = Order;
                    Caption = 'Sales Order';
                    ToolTip = 'Process SalesOrder PullData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        i95PullWebservice: Codeunit "i95 Pull Webservice";
                    begin
                        i95PullWebservice.ProcessPullData(CurrentAPIType::SalesOrder, SchedulerType::PullData);
                    end;
                }
                action(ProductPullDataTest)
                {
                    Image = Item;
                    Caption = 'Product';
                    ToolTip = 'Process Product PullData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        i95PullWebservice: Codeunit "i95 Pull Webservice";
                    begin
                        i95PullWebservice.ProcessPullData(CurrentAPIType::Product, SchedulerType::PullData);
                    end;
                }
                action(SalesQuotePullDataTest)
                {
                    Image = Order;
                    Caption = 'Sales Quote';
                    ToolTip = 'Process SalesQuote PullData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        i95PullWebservice: Codeunit "i95 Pull Webservice";
                    begin
                        i95PullWebservice.ProcessPullData(CurrentAPIType::SalesQuote, SchedulerType::PullData);
                    end;
                }
                action(ProductattributemappingPull)
                {

                    Caption = 'Product Attribute Mapping ';
                    ToolTip = 'Product Attribute Mapping PullData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        i95PullWebservice: Codeunit "i95 Pull Webservice";
                    begin
                        i95PullWebservice.ProcessPullData(CurrentAPIType::ProductAttributeMapping, SchedulerType::PullData);
                    end;
                }

                action(SchedulerIDPullDataTest)
                {
                    Image = Order;
                    Caption = 'Scheduler ID';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        i95PullWebservice: Codeunit "i95 Pull Webservice";
                    begin
                        i95PullWebservice.ProcessPullData(CurrentAPIType::SchedulerID, SchedulerType::PullData);
                    end;
                }
                action(EntityMappingpull)
                {

                    Caption = 'Entity mapping';
                    ToolTip = 'Process Entity Mapping PullData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        i95PullWebservice: Codeunit "i95 Pull Webservice";
                    begin
                        i95PullWebservice.ProcessPullData(CurrentAPIType::EntityManagement, SchedulerType::PullData);
                    end;
                }
                action(PaymentJournalinfoPull)
                {

                    Caption = 'Payment Journal ';
                    ToolTip = 'Payment PullData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        i95PullWebservice: Codeunit "i95 Pull Webservice";
                    begin
                        i95PullWebservice.ProcessPullData(CurrentAPIType::PaymentJournal, SchedulerType::PullData);
                    end;
                }
                action(AccountRecievableinfoPull)
                {

                    Caption = 'Account Recievable info ';
                    ToolTip = 'Account Recievable PullData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        i95PullWebservice: Codeunit "i95 Pull Webservice";
                    begin
                        i95PullWebservice.ProcessPullData(CurrentAPIType::AccountRecievable, SchedulerType::PullData);
                    end;
                }
                action(SalesReturnorderPull)
                {

                    Caption = 'Sales Return order pull ';
                    ToolTip = 'Sales Return order PullData API';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        i95PullWebservice: Codeunit "i95 Pull Webservice";
                    begin
                        i95PullWebservice.ProcessPullData(CurrentAPIType::SalesReturn, SchedulerType::PullData);
                    end;
                }
                action(RecuureTokenPull)
                {
                    Image = Order;
                    Caption = 'Reccure token';
                    ApplicationArea = all;
                    trigger OnAction();
                    var
                        i95PullWebservice: Codeunit "i95 Pull Webservice";
                        i95Devsetup: Record "i95 Setup";
                    begin

                        i95PullWebservice.ProcessPullData(CurrentAPIType::ReaccureToken, SchedulerType::PullData);
                    end;
                }

            }
        }
    }
    var
        CurrentAPIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerID,ReaccureToken;
        SchedulerType: Option PushData,PullData;
}