Codeunit 70003 "i95 Process Sync Api"
{
    Permissions = tabledata "Sales Shipment Header" = rm, tabledata "Sales Shipment Line" = rm, tabledata "Sales Invoice Header" = rm, tabledata "Sales Invoice Line" = rm;

    var
        EntityMapping: Record "i95 Entity Mapping";
        i95PushWebService: Codeunit "i95 Push Webservice";
        i95PullWebservice: Codeunit "i95 Pull Webservice";
        CurrentAPIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerID,ReaccureToken;
        i95Devsetup: Record "i95 Setup";
        Datetime1: DateTime;
        TempTime: Text;
        hours1: Integer;
        mins1: Integer;
        Secs1: Integer;
        Day1: Integer;
        Month1: Integer;
        Year1: Integer;
        accesstime: Time;
        AccessDate: Date;
        AccesstokenExpireDateTime: DateTime;
        SchedulerType: Option PushDatas,PullData;

    trigger OnRun()
    begin
        Datetime1 := CurrentDateTime;
        TempTime := format(Datetime1, 0, 9);
        If strlen(TempTime) >= 10 then begin
            Evaluate(accesstime, CopyStr(TempTime, 12, 8));
            Evaluate(Secs1, CopyStr(TempTime, 18, 2));
            Evaluate(mins1, CopyStr(TempTime, 15, 2));
            Evaluate(hours1, CopyStr(TempTime, 12, 2));
            evaluate(Day1, CopyStr(TempTime, 9, 2));
            evaluate(Month1, CopyStr(TempTime, 6, 2));
            evaluate(Year1, CopyStr(TempTime, 1, 4));
            AccessDate := DMY2Date(Day1, Month1, Year1);

            AccesstokenExpireDateTime := CreateDateTime(AccessDate, accesstime);

        end;
        i95Devsetup.Get();
        IF i95Devsetup.accesstokenExpirytime <= AccesstokenExpireDateTime then
            i95PullWebservice.ProcessPullData(CurrentAPIType::ReaccureToken, SchedulerType::PullData);

        i95PullWebservice.ProcessPullData(CurrentAPIType::SchedulerID, SchedulerType::PushDatas);

        EntityMapping.Reset();
        EntityMapping.SetCurrentKey("Primary Key");


        //PushData
        IF EntityMapping.FindSet() then;


        IF EntityMapping."Allow Product Oubound Sync" = true then begin
            IF not (i95Devsetup."i95 Enable ProdAtriButeMapping" = true) then
                ProductPushData()
            else
                ProductPushDatawithMapping();
        end;
        IF EntityMapping."Allow Inventory Oubound Sync" = true then
            InventoryPushData();
        IF EntityMapping."Allow Tier Prices Oubound Sync" = true then
            SalesPricePushData();
        IF EntityMapping."Allow Shipment Oubound Sync" = true then
            SalesShipmentPushData();
        IF EntityMapping."Allow Invoice Oubound Sync" = true then
            SalesInvoicePushData();
        IF EntityMapping."Allow Customer Oubound Sync" = true then
            CustomerPushData();
        IF EntityMapping."Allow CustGroup Outbound Sync" = true then
            CustomerGroupPushData();

        IF EntityMapping."Allow SalesQuote Outbound Sync" = true then
            SalesQuotePushData();

        IF EntityMapping."Allow SalesOrder Oubound Sync" = true then
            SalesOrderPushData();
        IF EntityMapping."Allow CanceQuote Outbound Sync" = true then
            CancelSalesQuotePushData();
        IF EntityMapping."Allow CancelOrder Oubound Sync" = true then
            CancelSalesOrderPushData();
        IF EntityMapping."Allow TaxBusPosG Oubound Sync" = true then
            TaxBusPostingGroupPushData();
        IF EntityMapping."Allow TaxProdPosG Oubound Sync" = true then
            TaxProdPostingGroupPushData();
        IF EntityMapping."Allow PaymentTerm Oubound Sync" = true then
            PaymentTermPushData();
        IF EntityMapping."Allow TaxPossetup Oubound Sync" = true then
            TaxPostingSetupPushData();
        // IF EntityMapping."Allow CustDiscG Oubound Sync" = true then
        //     CustDiscountGroupPushData();
        // IF EntityMapping."Allow ItemDiscG Oubound Sync" = true then
        //     ItemDiscountGroupPushData();
        // IF EntityMapping."Allow DiscPrice Oubound Sync" = true then
        //     DiscountPricePushData();

        IF EntityMapping."Allow ItemVar Oubound Sync" = true then
            ItemVariantPushData();
        // IF EntityMapping."Allow ESalesOrder Oubound Sync" = true then
        //     EditSalesOrderPushData();

        //SalesPersonPushData();
        IF EntityMapping."Allow AcountRecievable Ob Sync" = true then
            AccountRecievablePushData();
        IF EntityMapping."Allow CashReci Outbound Sync" = true then
            PostedCashReciept();
        // IF EntityMapping."Allow SalesReturn Ob Sync" = true then
        //     SalesReturnPushData();
        // IF EntityMapping."Allow SalesCreditMemo Ob Sync" = true then
        //     SalesCreditMemoPushData();

        /*ShippingAgentPushData();
        PaymentMethodPushData();
        ProductFieldsPushData();*/

        // IF EntityMapping."Allow Financecharge Ob Sync" then
        //     FinanceCharge();
        // IF EntityMapping."Allow Warehouse Ob Sync" = true then
        //     WarehouseLocation();


        i95PullWebservice.ProcessPullData(CurrentAPIType::SchedulerID, SchedulerType::PullData);
        //PullData
        IF EntityMapping."Allow Customer Inbound Sync" = true then
            i95PullWebservice.ProcessPullData(CurrentAPIType::Customer, SchedulerType::PullData);
        // i95PullWebservice.ProcessPullData(CurrentAPIType::CustomerGroup);
        IF EntityMapping."Allow SalesOrder Inbound Sync" = true then
            i95PullWebservice.ProcessPullData(CurrentAPIType::SalesOrder, SchedulerType::PullData);
        IF EntityMapping."Allow Product Inbound Sync" = true then
            i95PullWebservice.ProcessPullData(CurrentAPIType::Product, SchedulerType::PullData);

        //IF EntityMapping."Allow SalesQuote Inbound Sync" = true then
        i95PullWebservice.ProcessPullData(CurrentAPIType::SalesQuote, SchedulerType::PullData);

        //IF EntityMapping."Allow SalesReturn Ib Sync" = true then
        //i95PullWebservice.ProcessPullData(CurrentAPIType::SalesReturn, SchedulerType::PullData);


        IF EntityMapping."Allow CashReci Inputbound Sync" = true then
            i95PullWebservice.ProcessPullData(CurrentAPIType::PaymentJournal, SchedulerType::PullData);
        IF EntityMapping."Allow AcountRecievable Ib Sync" = true then
            i95PullWebservice.ProcessPullData(CurrentAPIType::AccountRecievable, SchedulerType::PullData);

        IF i95Devsetup."i95 Enable ProdAtriButeMapping" = true then begin
            i95PullWebservice.ProcessPullData(CurrentAPIType::ProductAttributeMapping, SchedulerType::PullData);
            // ProductPushDatawithMapping();
        end;

        i95Devsetup.Reset();
        IF i95Devsetup.FindSet() then;
        IF i95Devsetup.IsConfigurationUpdated = true then
            i95PullWebservice.ProcessPullData(CurrentAPIType::EntityManagement, SchedulerType::PullData);
    end;

    procedure ProductPushData()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
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
    begin
        Item.SetCurrentKey("i95 Sync Status");
        item.SetRange(item."i95 Sync Status", item."i95 Sync Status"::"Waiting for Sync");

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

                        ItemVariant.Reset();
                        ItemVariant.SetRange(ItemVariant."Item No.", Item1."No.");
                        If ItemVariant.IsEmpty() then
                            i95PushWebService.ProductPushData(Item1)
                        else begin
                            i95PushWebService.ConfigurableProductPushData(Item1);
                            i95PushWebService.ChildProductPushData(Item1);
                        end;

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

                                ItemVariant.Reset();
                                ItemVariant.SetRange(ItemVariant."Item No.", Item1."No.");
                                If ItemVariant.IsEmpty() then
                                    i95PushWebService.ProductPushData(Item1)
                                else begin
                                    i95PushWebService.ConfigurableProductPushData(Item1);
                                    i95PushWebService.ChildProductPushData(Item1);
                                end;
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


        // If Item.findset() then begin
        //     ItemVariant.Reset();
        //     ItemVariant.SetRange(ItemVariant."Item No.", Item."No.");
        //     If ItemVariant.IsEmpty() then
        //         i95PushWebService.ProductPushData(Item)
        //     else begin
        //         i95PushWebService.ConfigurableProductPushData(Item);
        //         i95PushWebService.ChildProductPushData(Item);
        //     end;
        // end;
    end;

    procedure ProductPushDatawithMapping()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
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
    begin
        Item.SetCurrentKey("i95 Sync Status");
        item.SetRange(item."i95 Sync Status", item."i95 Sync Status"::"Waiting for Sync");

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

                        ItemVariant.Reset();
                        ItemVariant.SetRange(ItemVariant."Item No.", Item1."No.");
                        If ItemVariant.IsEmpty() then
                            i95PushWebService.ProductPushDatawithMapping(Item1)
                        else begin
                            i95PushWebService.ConfigurableProductPushData(Item1);
                            i95PushWebService.ChildProductPushData(Item1);
                        end;

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

                                ItemVariant.Reset();
                                ItemVariant.SetRange(ItemVariant."Item No.", Item1."No.");
                                If ItemVariant.IsEmpty() then
                                    i95PushWebService.ProductPushDatawithMapping(Item1)
                                else begin
                                    i95PushWebService.ConfigurableProductPushData(Item1);
                                    i95PushWebService.ChildProductPushData(Item1);
                                end;
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


        // If Item.findset() then begin
        //     ItemVariant.Reset();
        //     ItemVariant.SetRange(ItemVariant."Item No.", Item."No.");
        //     If ItemVariant.IsEmpty() then
        //         i95PushWebService.ProductPushDatawithMapping(Item)
        //     else begin
        //         i95PushWebService.ConfigurableProductPushData(Item);
        //         i95PushWebService.ChildProductPushData(Item);
        //     end;
        // end;
    end;

    procedure InventoryPushData()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
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
    begin
        Item.SetCurrentKey("i95 Inventory Sync Status");
        item.SetRange(item."i95 Inventory Sync Status", item."i95 Inventory Sync Status"::"Waiting for Sync");

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


        // If Item.findset() then
        //     i95PushWebService.InventoryPushData(Item);

        ItemVariant.SetCurrentKey("i95 Inventory Sync Status");
        ItemVariant.SetRange("i95 Inventory Sync Status", ItemVariant."i95 Inventory Sync Status"::"Waiting for Sync");
        if ItemVariant.FindSet() then
            i95PushWebService.VariantInventoryPushData(ItemVariant);
    end;

    procedure CustomerPushData()
    var
        Customer: Record customer;
        index: Integer;
        index1: Integer;
        lstCustomers: List of [Code[20]];
        lstCustomers1: List of [Code[20]];
        isPacketCreated: Boolean;
        result: Boolean;
        packetSize: Integer;
        Customer1: Record Customer;
        custNo: Code[20];
        packetCustNos: Text;
    begin
        Customer.SetCurrentKey("i95 Sync Status");
        Customer.SetRange(Customer."i95 Sync Status", Customer."i95 Sync Status"::"Waiting for Sync");

        #region Packet Entries
        if Customer.FindSet() then begin
            repeat begin
                if Customer."No." <> '' then begin
                    lstCustomers.Add(Customer."No.");
                end;
            end until Customer.Next() = 0;

            i95Devsetup.Get();
            packetSize := i95Devsetup."Pull Data Packet Size";

            Clear(index);
            index := 1;
            if lstCustomers.Count() > 0 then begin
                repeat begin
                    packetCustNos := '';
                    Clear(lstCustomers1);
                    Customer1.Reset();
                    Clear(Customer1);
                    isPacketCreated := lstCustomers.GetRange(index, packetSize, lstCustomers1);
                    if isPacketCreated then begin
                        result := true;
                        foreach custNo in lstCustomers1 do begin
                            packetCustNos := packetCustNos + custNo + '|';
                        end;
                        packetCustNos := packetCustNos.Remove(packetCustNos.LastIndexOf('|'));

                        //Sending the packet to the cloud
                        Customer1.SetFilter("No.", packetCustNos);
                        i95PushWebService.CustomerPushData(Customer1);

                        index := index + packetSize;
                    end else begin
                        Clear(custNo);
                        Clear(packetCustNos);
                        Clear(lstCustomers1);
                        Customer1.Reset();
                        Clear(Customer1);
                        isPacketCreated := lstCustomers.GetRange(index, lstCustomers.Count() mod packetSize, lstCustomers1);
                        if isPacketCreated then begin
                            if lstCustomers1.Count() > 0 then begin
                                result := true;
                                foreach custNo in lstCustomers1 do begin
                                    packetCustNos := packetCustNos + custNo + '|';
                                end;
                                packetCustNos := packetCustNos.Remove(packetCustNos.LastIndexOf('|'));

                                //Sending the packet to the cloud
                                Customer1.SetFilter("No.", packetCustNos);
                                i95PushWebService.CustomerPushData(Customer1);
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


        // If Customer.FindSet() then
        //     i95PushWebService.CustomerPushData(Customer);
    end;

    procedure CustomerGroupPushData()
    var
        CustPriceGroup: Record "Customer Price Group";
    begin
        CustPriceGroup.SetCurrentKey("i95 Sync Status");
        CustPriceGroup.SetRange(CustPriceGroup."i95 Sync Status", CustPriceGroup."i95 Sync Status"::"Waiting for Sync");
        if CustPriceGroup.FindSet() then
            i95PushWebService.CustomerPriceGroupPushData(CustPriceGroup);
    end;

    procedure SalesPricePushData()
    var
        Item: Record Item;
        itemVariant: Record "Item Variant";
        SalePrice: Record "Sales Price";
    // SalePrice: Record "Price List Line";
    begin
        Item.Reset();
        Item.SetCurrentKey(Item."i95 SalesPrice Sync Status");
        Item.SetRange(Item."i95 SalesPrice Sync Status", Item."i95 SalesPrice Sync Status"::"Waiting for Sync");
        if Item.FindSet() then begin
            repeat
                SalePrice.Reset();
                SalePrice.SetRange("Item No.", Item."No.");
                //SalePrice.SetRange("Asset Type", SalePrice."Asset Type"::Item);
                //SalePrice.SetRange("Asset No.", Item."No.");
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
                // SalePrice.SetRange("Asset Type", SalePrice."Asset Type"::Item);
                //SalePrice.SetRange("Asset No.", Item."No.");
                SalePrice.SetRange("Variant Code", Itemvariant.Code);
                IF SalePrice.FindFirst() then
                    i95PushWebService.SalesPriceVariantPushData(itemVariant);
            until itemVariant.Next() = 0;

    end;

    procedure SalesOrderPushData()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Reset();
        SalesHeader.SetCurrentKey("i95 Sync Status");
        SalesHeader.SetRange(SalesHeader."Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange(SalesHeader."i95 Sync Status", SalesHeader."i95 Sync Status"::"Waiting for Sync");
        If SalesHeader.FindSet() then
            i95PushWebService.SalesOrderPushData(SalesHeader);
    end;

    procedure SalesReturnPushData()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Reset();
        SalesHeader.SetCurrentKey("i95 Sync Status");
        SalesHeader.SetRange(SalesHeader."Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange(SalesHeader."i95 Sync Status", SalesHeader."i95 Sync Status"::"Waiting for Sync");
        If SalesHeader.FindSet() then
            i95PushWebService.SalesReturnPushData(SalesHeader);

    end;

    procedure SalesQuotePushData()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.Reset();
        SalesHeader.SetCurrentKey("i95 Sync Status");
        SalesHeader.SetRange(SalesHeader."Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.SetRange(Status, SalesHeader.Status::Released);
        SalesHeader.SetRange(SalesHeader."i95 Sync Status", SalesHeader."i95 Sync Status"::"Waiting for Sync");
        If SalesHeader.FindSet() then
            i95PushWebService.SalesQuotePushData(SalesHeader);
    end;

    procedure SalesShipmentPushData()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        SalesShipmentHeader.SetCurrentKey("i95 Sync Status");
        SalesShipmentHeader.SetRange(SalesShipmentHeader."i95 Sync Status", SalesShipmentHeader."i95 Sync Status"::"Waiting for Sync");
        If SalesShipmentHeader.FindSet() then
            i95PushWebService.SalesShipmentPushData(SalesShipmentHeader);
    end;

    procedure SalesInvoicePushData()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.SetCurrentKey("i95 Sync Status");
        SalesInvoiceHeader.SetRange(SalesInvoiceHeader."i95 Sync Status", SalesInvoiceHeader."i95 Sync Status"::"Waiting for Sync");
        If SalesInvoiceHeader.FindSet() then
            i95PushWebService.SalesInvoicePushData(SalesInvoiceHeader);
    end;

    procedure SalesCreditMemoPushData()
    var
        SalesCreditMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCreditMemoHeader.SetCurrentKey("i95 Sync Status");
        SalesCreditMemoHeader.SetRange(SalesCreditMemoHeader."i95 Sync Status", SalesCreditMemoHeader."i95 Sync Status"::"Waiting for Sync");
        If SalesCreditMemoHeader.FindSet() then
            i95PushWebService.SalesCreditmemoPushData(SalesCreditMemoHeader);
    end;

    procedure CancelSalesOrderPushData()
    var
        i95SyncLogEntry: Record "i95 Sync Log Entry";
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

    procedure CancelSalesQuotePushData()
    var
        i95SyncLogEntry: Record "i95 Sync Log Entry";
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

    procedure TaxBusPostingGroupPushData()
    var
        TaxBusPostingGrp: Record "VAT Business Posting Group";
    begin
        TaxBusPostingGrp.Reset();
        TaxBusPostingGrp.SetCurrentKey("i95 Sync Status");
        TaxBusPostingGrp.SetRange(TaxBusPostingGrp."i95 Sync Status", TaxBusPostingGrp."i95 Sync Status"::"Waiting for Sync");
        If TaxBusPostingGrp.FindSet() then
            i95PushWebService.TaxBusPostingGrpPushData(TaxBusPostingGrp);
    end;

    procedure TaxProdPostingGroupPushData()
    var
        TaxProdPostingGrp: Record "VAT Product Posting Group";
    begin
        TaxProdPostingGrp.Reset();
        TaxProdPostingGrp.SetCurrentKey("i95 Sync Status");
        TaxProdPostingGrp.SetRange(TaxProdPostingGrp."i95 Sync Status", TaxProdPostingGrp."i95 Sync Status"::"Waiting for Sync");
        if TaxProdPostingGrp.FindSet() then
            i95PushWebService.TaxProdPostingGrpPushData(TaxProdPostingGrp);
    end;

    procedure PaymentTermPushData()
    var
        PaymentTerm: Record "Payment Terms";
    begin
        PaymentTerm.Reset();
        PaymentTerm.SetCurrentKey("i95 Sync Status");
        PaymentTerm.SetRange(PaymentTerm."i95 Sync Status", PaymentTerm."i95 Sync Status"::"Waiting for Sync");
        if PaymentTerm.FindSet() then
            i95PushWebService.PaymentTermPushData(PaymentTerm);
    end;

    procedure SalesPersonPushData()
    var
        SalesPerson: Record "Salesperson/Purchaser";
    begin
        SalesPerson.Reset();
        SalesPerson.SetCurrentKey("i95 Sync Status");
        SalesPerson.SetRange(SalesPerson."i95 Sync Status", SalesPerson."i95 Sync Status"::"Waiting for Sync");
        if SalesPerson.FindSet() then
            i95PushWebService.SalesPersonPushData(SalesPerson);
    end;

    procedure TaxPostingSetupPushData()
    var
        TaxPostingSetup: Record "VAT Posting Setup";
    begin
        TaxPostingSetup.Reset();
        TaxPostingSetup.SetCurrentKey(TaxPostingSetup."i95 Sync Status");
        TaxPostingSetup.SetRange(TaxPostingSetup."i95 Sync Status", TaxPostingSetup."i95 Sync Status"::"Waiting for Sync");
        if TaxPostingSetup.FindSet() then
            i95PushWebService.TaxPostingSetupPushData(TaxPostingSetup);
    end;

    procedure CustDiscountGroupPushData()
    var
        CustDiscountGroup: Record "Customer Discount Group";
    begin
        CustDiscountGroup.Reset();
        CustDiscountGroup.SetCurrentKey(CustDiscountGroup."i95 Sync Status");
        CustDiscountGroup.SetRange(CustDiscountGroup."i95 Sync Status", CustDiscountGroup."i95 Sync Status"::"Waiting for Sync");
        if CustDiscountGroup.FindSet() then
            i95PushWebService.CustomerDiscGroupPushData(CustDiscountGroup);
    end;

    procedure ItemDiscountGroupPushData()
    var
        ItemDiscountGroup: Record "Item Discount Group";
    begin
        ItemDiscountGroup.Reset();
        ItemDiscountGroup.SetCurrentKey(ItemDiscountGroup."i95 Sync Status");
        ItemDiscountGroup.SetRange(ItemDiscountGroup."i95 Sync Status", ItemDiscountGroup."i95 Sync Status"::"Waiting for Sync");
        if ItemDiscountGroup.FindSet() then
            i95PushWebService.ItemDiscGroupPushData(ItemDiscountGroup);
    end;

    procedure DiscountPricePushData()
    var
        Item: Record item;
        ItemDiscGroup: Record "Item Discount Group";
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

    procedure ItemVariantPushData()
    var
        Item: Record item;
    begin
        Item.SetCurrentKey(Item."i95 ItemVariant Sync Status");
        Item.SetRange(item."i95 ItemVariant Sync Status", item."i95 ItemVariant Sync Status"::"Waiting for Sync");
        If Item.Findset() then
            i95PushWebService.ConfigurableProductPushData(Item);

        item.Reset();
        Item.SetCurrentKey(Item."i95 Child Variant Sync Status");
        Item.SetRange(item."i95 Child Variant Sync Status", Item."i95 Child Variant Sync Status"::"Waiting for Sync");
        If Item.Findset() then
            i95PushWebService.ChildProductPushData(Item);
    end;

    procedure EditSalesOrderPushData()
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.SetCurrentKey("i95 EditOrder Sync Status");
        SalesHeader.SetRange(SalesHeader."Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange(SalesHeader."i95 EditOrder Sync Status", SalesHeader."i95 EditOrder Sync Status"::"Waiting for Sync");
        If SalesHeader.FindSet() then
            i95PushWebService.EditSalesOrderPushData(SalesHeader);
    end;

    procedure ShippingAgentPushData()
    var
        ShipAgentService: Record "Shipping Agent Services";
        ShippingAgent: Record "Shipping Agent";
    begin

        ShipAgentService.Reset();
        IF ShipAgentService.FindSet() then
            repeat
                i95PushWebService.SalesAgentPushData(ShipAgentService);
            until ShipAgentService.Next() = 0;


    end;

    procedure PaymentMethodPushData()
    var
        PaymentMethod: Record "Payment Method";
    begin

        PaymentMethod.Reset();
        IF PaymentMethod.FindSet() then
            repeat
                i95PushWebService.PaymentMethodPushData(PaymentMethod);
            until PaymentMethod.Next() = 0;
    end;

    procedure AccountRecievablePushData()
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustomerLedgerEntry.Reset();
        CustomerLedgerEntry.SetCurrentKey("i95 Sync Status");
        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Invoice);
        CustomerLedgerEntry.SetRange("Payment Method Code", 'CREDLMT');
        CustomerLedgerEntry.SetRange(CustomerLedgerEntry."i95 Sync Status", CustomerLedgerEntry."i95 Sync Status"::"Waiting for Sync");
        IF CustomerLedgerEntry.FindSet() then
            i95PushWebService.AccountRecievablePushData(CustomerLedgerEntry);
    end;


    procedure PostedCashReciept()
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvoiceHeaderL: Record "Sales Invoice Header";
    begin
        CustomerLedgerEntry.Reset();
        CustomerLedgerEntry.SetCurrentKey("i95 Sync Status");
        CustomerLedgerEntry.SetRange("Document Type", CustomerLedgerEntry."Document Type"::Payment);
        CustomerLedgerEntry.SetRange(CustomerLedgerEntry."i95 Sync Status", CustomerLedgerEntry."i95 Sync Status"::"Waiting for Sync");
        IF CustomerLedgerEntry.FindSet() then
            repeat
                SalesInvoiceHeaderL.Reset();
                SalesInvoiceHeaderL.SetRange("No.", CustomerLedgerEntry."Document No.");
                SalesInvoiceHeaderL.SetRange("Payment Method Code", 'CREDLMT');
                IF SalesInvoiceHeaderL.FindFirst() then begin
                    i95PushWebService.PostedCashRecieptPushData(CustomerLedgerEntry);
                end;
            until CustomerLedgerEntry.Next() = 0;

    end;

    procedure FinanceCharge()
    var
        IssuedFinanceCharge: Record "Issued Fin. Charge Memo Header";
    begin
        IssuedFinanceCharge.Reset();
        IssuedFinanceCharge.SetCurrentKey("i95 Sync Status");
        IssuedFinanceCharge.SetRange(IssuedFinanceCharge."i95 Sync Status", IssuedFinanceCharge."i95 Sync Status"::"Waiting for Sync");
        IF IssuedFinanceCharge.FindSet() then
            i95PushWebService.FinanceChargePushData(IssuedFinanceCharge);

    end;

    procedure WarehouseLocation()
    var
        Location: Record Location;
    begin
        Location.Reset();
        Location.SetCurrentKey("i95 Sync Status");
        Location.SetRange("i95 Sync Status", Location."i95 Sync Status"::"Waiting for Sync");
        IF Location.FindSet() then
            i95PushWebService.WarehouseLocationPushData(Location);
    end;
}