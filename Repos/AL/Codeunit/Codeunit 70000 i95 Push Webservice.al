codeunit 70000 "i95 Push Webservice"
{
    Permissions = tabledata "Sales Shipment Header" = rm, tabledata "Sales Shipment Line" = rm, tabledata "Sales Invoice Header" = rm, tabledata "Sales Invoice Line" = rm, tabledata "Issued Fin. Charge Memo Header" = rm, tabledata "Sales Cr.Memo Header" = rm, tabledata "Sales Cr.Memo Line" = rm;

    procedure ProductPushData(Var Item: Record Item)
    var
        BodyContent: text;
    begin
        Clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.Get();
        Checki95SetupData();

        CalledByItemVariant := False;

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::Product, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::Product, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            if Item."No." <> '' then begin
                //CountL += 1;
                CreateBodyContent.ProductPushData(Item, BodyContent);
                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::Product, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, Item."No.", Item.Description, '', item.RecordId(), Database::Item);
                //IF CountL = i95Setup."Pull Data Packet Size" then
                //break;
            end;

        until Item.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        SyncLogEntry.SetSourceRecordID(Item.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::Product, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::Product);
    end;

    procedure ProductPushDatawithMapping(Var Item: Record Item)
    var
        BodyContent: text;
    begin
        Clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);

        i95Setup.Get();
        Checki95SetupData();

        CalledByItemVariant := False;

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::Product, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::Product, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            if Item."No." <> '' then begin
                CreateBodyContent.ProductPushDatawithMapping(Item, BodyContent);
                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::Product, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, Item."No.", Item.Description, '', item.RecordId(), Database::Item);
            end;
        until Item.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        SyncLogEntry.SetSourceRecordID(Item.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::Product, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::Product);
    end;

    procedure InventoryPushData(var Item: Record Item)
    var
        BodyContent: text;
        InventoryString: Text[30];
        QtyOnsalesorder: Decimal;
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(InventoryString);
        Clear(CountL);

        i95Setup.get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::Inventory, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::Inventory, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            if Item."No." <> '' then begin
                //CountL += 1;
                if i95Setup."i95 Default Warehouse" <> '' then
                    Item.SetFilter(item."Location Filter", '%1', i95Setup."i95 Default Warehouse");
                Item.CalcFields(Item.Inventory);

                IF not (I95Setup."i95 Enable MSI" = true) then begin
                    Item.CalcFields(Item."Qty. on Sales Order");
                    InventoryString := format(Item.Inventory - Item."Qty. on Sales Order");
                end else begin
                    InventoryString := format(Item.Inventory);
                end;

                InventoryString := DelChr(InventoryString, '=', ',');
                CreateBodyContent.InventoryPushData(Item, InventoryString, BodyContent);
                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::Inventory, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, Item."No.", Item.Description, '', item.RecordId(), Database::Item);
                //IF CountL = i95Setup."Pull Data Packet Size" then
                //break;
            end;
        until Item.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);


        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        SyncLogEntry.SetSourceRecordID(Item.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::Inventory, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::Inventory);
    end;

    procedure CustomerPushData(var Customer: Record Customer)
    var
        ShipToAddress: Record "Ship-to Address";
        BodyContent: Text;
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);


        i95Setup.get();
        Checki95SetupData();
        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::Customer, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::Customer, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            If not ShipToAddress.get(Customer."No.", 'I95DEFAULT') then
                Customer.Createi95DefaultShiptoAddress();

            // CreateBodyContent.CustomerPushData(Customer, BodyContent);
            CreateBodyContent.CompanyPushData(Customer, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::Customer, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, Customer."No.", Customer.Name, '', Customer.RecordId(), Database::customer);
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until Customer.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        SyncLogEntry.SetSourceRecordID(Customer.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::Customer, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::Customer);

    end;

    procedure CustomerPriceGroupPushData(var CustPriceGroup: Record "Customer Price Group")
    var
        BodyContent: Text;
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::CustomerGroup, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::CustomerGroup, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            CreateBodyContent.CustomerPriceGroupPushData(CustPriceGroup, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::CustomerGroup, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, CustPriceGroup.Code, CustPriceGroup.Description, '', CustPriceGroup.RecordId(), Database::"Customer Price Group");
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until CustPriceGroup.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        SyncLogEntry.SetSourceRecordID(CustPriceGroup.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::CustomerGroup, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::CustomerGroup);
    end;

    procedure SalesPricePushData(var Item: Record Item)
    var
        BodyContent: Text;
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::TierPrices, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::TierPrices, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            CreateBodyContent.SalesPricePushData(Item, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::TierPrices, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, Item."No.", Item.Description, '', Item.RecordId(), Database::item);
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until Item.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        SyncLogEntry.SetSourceRecordID(Item.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::TierPrices, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::TierPrices);
    end;

    procedure SalesPriceVariantPushData(var ItemVariant: Record "Item Variant")
    var
        BodyContent: Text;
    // Item: Record Item;


    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CalledByItemVariant);


        i95Setup.get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::TierPrices, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::TierPrices, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        // repeat
        CreateBodyContent.SalesPriceVariantPushData(ItemVariant, BodyContent);
        DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::TierPrices, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, ItemVariant.Code, ItemVariant.Description, '', ItemVariant.RecordId(), Database::"Item Variant");
        // until ItemVariant.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        SyncLogEntry.SetSourceRecordID(ItemVariant.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::TierPrices, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;
        CalledByItemVariant := true;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::TierPrices);
    end;

    procedure TaxBusPostingGrpPushData(Var TaxBusPostingGrp: Record "VAT Business Posting Group")
    var
        BodyContent: Text;
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::TaxBusPostingGroup, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::TaxBusPostingGroup, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            CreateBodyContent.TaxBusPostingGroupPushData(TaxBusPostingGrp, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::TaxBusPostingGroup, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, TaxBusPostingGrp.Code, TaxBusPostingGrp.Description, '', TaxBusPostingGrp.RecordId(), Database::"VAT Business Posting Group");
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until TaxBusPostingGrp.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        SyncLogEntry.SetSourceRecordID(TaxBusPostingGrp.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::TaxBusPostingGroup, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;
        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::TaxBusPostingGroup);
    end;

    procedure TaxProdPostingGrpPushData(Var TaxProdPostingGrp: Record "VAT Product Posting Group")
    var
        BodyContent: Text;
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::TaxProductPostingGroup, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::TaxProductPostingGroup, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            CreateBodyContent.TaxProdPostingGroupPushData(TaxProdPostingGrp, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::TaxProductPostingGroup, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, TaxProdPostingGrp.Code, TaxProdPostingGrp.Description, '', TaxProdPostingGrp.RecordId(), Database::"VAT Product Posting Group");
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until TaxProdPostingGrp.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        SyncLogEntry.SetSourceRecordID(TaxProdPostingGrp.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::TaxProductPostingGroup, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::TaxProductPostingGroup);
    end;

    procedure TaxPostingSetupPushData(Var TaxPostingSetup: Record "VAT Posting Setup")
    var
        BodyContent: Text;
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::TaxPostingSetup, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::TaxPostingSetup, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            CreateBodyContent.TaxPostingSetupPushData(TaxPostingSetup, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::TaxPostingSetup, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, TaxPostingSetup."VAT Bus. Posting Group", TaxPostingSetup."VAT Prod. Posting Group", format(TaxPostingSetup."VAT %"), TaxPostingSetup.RecordId(), Database::"VAT Posting Setup");
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until TaxPostingSetup.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        SyncLogEntry.SetSourceRecordID(TaxPostingSetup.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::TaxPostingSetup, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::TaxPostingSetup);
    end;

    procedure PaymentTermPushData(Var PaymentTerms: Record "Payment Terms")
    var
        BodyContent: Text;
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::PaymentTerm, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::PaymentTerm, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            CreateBodyContent.PaymentTermsPushData(PaymentTerms, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::PaymentTerm, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, PaymentTerms.Code, PaymentTerms.Description, '', PaymentTerms.RecordId(), Database::"Payment Terms");
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until PaymentTerms.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        SyncLogEntry.SetSourceRecordID(PaymentTerms.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::PaymentTerm, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::PaymentTerm);
    end;

    procedure CustomerDiscGroupPushData(var CustDiscGroup: Record "Customer Discount Group")
    var
        BodyContent: Text;
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::CustomerDiscountGroup, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::CustomerDiscountGroup, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            CreateBodyContent.CustomerDiscountGroupPushData(CustDiscGroup, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::CustomerDiscountGroup, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, CustDiscGroup.Code, CustDiscGroup.Description, '', CustDiscGroup.RecordId(), Database::"Customer Discount Group");
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until CustDiscGroup.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        SyncLogEntry.SetSourceRecordID(CustDiscGroup.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::CustomerDiscountGroup, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::CustomerDiscountGroup);
    end;

    procedure ItemDiscGroupPushData(var ItemDiscGroup: Record "Item Discount Group")
    var
        BodyContent: Text;
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::ItemDiscountGroup, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::ItemDiscountGroup, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            CreateBodyContent.ItemDiscountGroupPushData(ItemDiscGroup, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::ItemDiscountGroup, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, ItemDiscGroup.Code, ItemDiscGroup.Description, '', ItemDiscGroup.RecordId(), Database::"Item Discount Group");
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until ItemDiscGroup.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        SyncLogEntry.SetSourceRecordID(ItemDiscGroup.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::ItemDiscountGroup, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::ItemDiscountGroup);
    end;

    procedure SalesOrderPushData(var SalesHeader: Record "Sales Header")
    var
        ShippingAgentMapping: Record "i95 Shipping Agent Mapping";
        PaymentMethodsMapping: Record "i95 Payment Methods Mapping";
        BodyContent: Text;
        BodyContentExist: Boolean;
        IsShipAgentErrorExists: Boolean;
        IsPaymentMethodErrorExists: Boolean;
        ShippingAgentCode: Text[30];
        EcommerceShipAgentCode: Code[50];
        EcommerceShipAgentDescription: text[50];
        EcommercePaymentMethodCode: Code[50];
        SyncLogInserted: Boolean;
        ShipAgentErrorTxt: Label 'Shipping Agent Code cannot be blank for Sales Order %1.';
        ShipAgentMappingErrorTxt: Label 'Shipping Agent Mapping does not exist for %1 in Sales Order %2.';
        PaymentMethodErrorTxt: Label 'Payment Method Code cannot be blank for Sales Order %1.';
        PaymentMethodMappingErrorTxt: Label 'Payment Method Mapping does not exist for %1 in Sales Order %2.';
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.get();
        Checki95SetupData();

        repeat
            CountL += 1;
            //if IsNotSyncedSalesOrder(SalesHeader) then begin
            //if not SyncLogInserted then begin//New Change
            SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::SalesOrder, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
            APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::SalesOrder, SchedulerType::PushData, SyncSource::"Business Central");

            //  SyncLogInserted := true;//New Change
            CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
            // end;//New Change

            Clear(EcommerceShipAgentCode);
            Clear(EcommerceShipAgentDescription);
            Clear(ShippingAgentCode);
            Clear(EcommercePaymentMethodCode);
            clear(IsShipAgentErrorExists);
            clear(IsPaymentMethodErrorExists);

            /* If SalesHeader."Shipping Agent Code" <> '' then begin
                 ShippingAgentMapping.Reset();
                 ShippingAgentMapping.SetRange(ShippingAgentMapping."BC Shipping Agent Code", SalesHeader."Shipping Agent Code");
                 If SalesHeader."Shipping Agent Service Code" <> '' then
                     ShippingAgentMapping.setrange(ShippingAgentMapping."BC Shipping Agent Service Code", SalesHeader."Shipping Agent Service Code");
                 If ShippingAgentMapping.FindFirst() then begin
                     EcommerceShipAgentCode := ShippingAgentMapping."E-Com Shipping Method Code";
                     EcommerceShipAgentDescription := ShippingAgentMapping."E-Com Shipping Description";
                     If ShippingAgentMapping."BC Shipping Agent Service Code" <> '' then
                         ShippingAgentCode := ShippingAgentMapping."BC Shipping Agent Code" + '-' + ShippingAgentMapping."BC Shipping Agent Service Code"
                     else
                         ShippingAgentCode := ShippingAgentMapping."BC Shipping Agent Code";
                 end else
                     IsShipAgentErrorExists := true;
             end else
                 IsShipAgentErrorExists := true;*/

            IF SalesHeader."Shipping Agent Code" <> '' then begin//New changes without mapping
                IF SalesHeader."Shipping Agent Service Code" <> '' then
                    EcommerceShipAgentCode := SalesHeader."Shipping Agent Code" + '-' + SalesHeader."Shipping Agent Service Code";
                EcommerceShipAgentDescription := format(SalesHeader."Shipping Agent Service Code" + '-' + SalesHeader."Shipping Agent Service Code");

                IF SalesHeader."Shipping Agent Service Code" <> '' then
                    ShippingAgentCode := SalesHeader."Shipping Agent Code" + '-' + SalesHeader."Shipping Agent Service Code"
                else
                    ShippingAgentCode := SalesHeader."Shipping Agent Code";
            end else
                IsShipAgentErrorExists := true;

            /* If SalesHeader."Payment Method Code" <> '' then begin
                 PaymentMethodsMapping.Reset();
                 PaymentMethodsMapping.SetRange(PaymentMethodsMapping."BC Payment Method Code", SalesHeader."Payment Method Code");
                 PaymentMethodsMapping.SetRange(PaymentMethodsMapping."BC to Ecommerce Default", true);
                 If PaymentMethodsMapping.FindFirst() then
                     EcommercePaymentMethodCode := PaymentMethodsMapping."E-Commerce Payment Method Code"
                 else begin
                     PaymentMethodsMapping.SetRange(PaymentMethodsMapping."BC to Ecommerce Default");
                     If paymentMethodsMapping.FindFirst() then
                         EcommercePaymentMethodCode := PaymentMethodsMapping."E-Commerce Payment Method Code"
                     else
                         IsPaymentMethodErrorExists := true;
                 end;
             end else
                 IsPaymentMethodErrorExists := true;*/

            IF SalesHeader."Payment Method Code" <> '' then begin//New Changes without mapping
                EcommercePaymentMethodCode := SalesHeader."Payment Method Code"
            end else
                IsPaymentMethodErrorExists := true;


            if (IsShipAgentErrorExists or IsPaymentMethodErrorExists) then begin
                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::SalesOrder, SyncStatus::"No Response", LogStatus::Cancelled, SyncSource::"Business Central", SyncLogEntryNo, SalesHeader."No.", SalesHeader."Sell-to Customer No.", '', SalesHeader.RecordId(), Database::"Sales Header");
                if SalesHeader."Shipping Agent Code" = '' then
                    DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(ShipAgentErrorTxt, SalesHeader."No."))
                else
                    if IsShipAgentErrorExists then
                        DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(ShipAgentMappingErrorTxt, SalesHeader."Shipping Agent Code", SalesHeader."No."))
                    else
                        if SalesHeader."Payment Method Code" = '' then
                            DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(PaymentMethodErrorTxt, SalesHeader."No."))
                        else
                            DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(PaymentMethodMappingErrorTxt, SalesHeader."Payment Method Code", SalesHeader."No."));
            end;

            If (not IsShipAgentErrorExists) and (not IsPaymentMethodErrorExists) and (SalesHeader."i95 Sync Message" = '') then begin
                CreateBodyContent.SalesOrderPushData(salesHeader, BodyContent, EcommerceShipAgentCode, EcommercePaymentMethodCode, EcommerceShipAgentDescription, ShippingAgentCode);
                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::SalesOrder, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, SalesHeader."No.", SalesHeader."Sell-to Customer No.", '', SalesHeader.RecordId(), Database::"Sales Header");
                BodyContentExist := true;
            end;
            // end;
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until SalesHeader.Next() = 0;

        //  if SyncLogInserted then begin//New Change
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        SyncLogEntry.SetSourceRecordID(SalesHeader.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::SalesOrder, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        if BodyContentExist then
            ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::SalesOrder);
        //end;
    end;

    procedure SalesQuotePushData(var SalesHeader: Record "Sales Header")
    var
        ShippingAgentMapping: Record "i95 Shipping Agent Mapping";
        PaymentMethodsMapping: Record "i95 Payment Methods Mapping";
        BodyContent: Text;
        BodyContentExist: Boolean;
        IsShipAgentErrorExists: Boolean;
        IsPaymentMethodErrorExists: Boolean;
        ShippingAgentCode: Text[30];
        EcommerceShipAgentCode: Code[50];
        EcommerceShipAgentDescription: text[50];
        EcommercePaymentMethodCode: Code[50];
        SyncLogInserted: Boolean;
        ShipAgentErrorTxt: Label 'Shipping Agent Code cannot be blank for Sales Quote %1.';
        ShipAgentMappingErrorTxt: Label 'Shipping Agent Mapping does not exist for %1 in Sales Quote %2.';
        PaymentMethodErrorTxt: Label 'Payment Method Code cannot be blank for Sales Quote %1.';
        PaymentMethodMappingErrorTxt: Label 'Payment Method Mapping does not exist for %1 in Sales Quote %2.';
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.get();
        Checki95SetupData();

        repeat
            CountL += 1;
            //if IsNotSyncedSalesOrder(SalesHeader) then begin
            //if not SyncLogInserted then begin//New Change
            SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::SalesQuote, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
            APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::SalesQuote, SchedulerType::PushData, SyncSource::"Business Central");

            //  SyncLogInserted := true;//New Change
            CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
            // end;//New Change

            Clear(EcommerceShipAgentCode);
            Clear(EcommerceShipAgentDescription);
            Clear(ShippingAgentCode);
            Clear(EcommercePaymentMethodCode);
            clear(IsShipAgentErrorExists);
            clear(IsPaymentMethodErrorExists);

            /* If SalesHeader."Shipping Agent Code" <> '' then begin
                 ShippingAgentMapping.Reset();
                 ShippingAgentMapping.SetRange(ShippingAgentMapping."BC Shipping Agent Code", SalesHeader."Shipping Agent Code");
                 If SalesHeader."Shipping Agent Service Code" <> '' then
                     ShippingAgentMapping.setrange(ShippingAgentMapping."BC Shipping Agent Service Code", SalesHeader."Shipping Agent Service Code");
                 If ShippingAgentMapping.FindFirst() then begin
                     EcommerceShipAgentCode := ShippingAgentMapping."E-Com Shipping Method Code";
                     EcommerceShipAgentDescription := ShippingAgentMapping."E-Com Shipping Description";
                     If ShippingAgentMapping."BC Shipping Agent Service Code" <> '' then
                         ShippingAgentCode := ShippingAgentMapping."BC Shipping Agent Code" + '-' + ShippingAgentMapping."BC Shipping Agent Service Code"
                     else
                         ShippingAgentCode := ShippingAgentMapping."BC Shipping Agent Code";
                 end else
                     IsShipAgentErrorExists := true;
             end else
                 IsShipAgentErrorExists := true;*/

            /* IF SalesHeader."Shipping Agent Code" <> '' then begin//New changes without mapping
                 IF SalesHeader."Shipping Agent Service Code" <> '' then
                     EcommerceShipAgentCode := SalesHeader."Shipping Agent Code" + '-' + SalesHeader."Shipping Agent Service Code";
                 EcommerceShipAgentDescription := format(SalesHeader."Shipping Agent Service Code" + '-' + SalesHeader."Shipping Agent Service Code");

                 IF SalesHeader."Shipping Agent Service Code" <> '' then
                     ShippingAgentCode := SalesHeader."Shipping Agent Code" + '-' + SalesHeader."Shipping Agent Service Code"
                 else
                     ShippingAgentCode := SalesHeader."Shipping Agent Code";
             end else
                 IsShipAgentErrorExists := true;*///Sales Quote Changes

            /* If SalesHeader."Payment Method Code" <> '' then begin
                 PaymentMethodsMapping.Reset();
                 PaymentMethodsMapping.SetRange(PaymentMethodsMapping."BC Payment Method Code", SalesHeader."Payment Method Code");
                 PaymentMethodsMapping.SetRange(PaymentMethodsMapping."BC to Ecommerce Default", true);
                 If PaymentMethodsMapping.FindFirst() then
                     EcommercePaymentMethodCode := PaymentMethodsMapping."E-Commerce Payment Method Code"
                 else begin
                     PaymentMethodsMapping.SetRange(PaymentMethodsMapping."BC to Ecommerce Default");
                     If paymentMethodsMapping.FindFirst() then
                         EcommercePaymentMethodCode := PaymentMethodsMapping."E-Commerce Payment Method Code"
                     else
                         IsPaymentMethodErrorExists := true;
                 end;
             end else
                 IsPaymentMethodErrorExists := true;*/

            /*  IF SalesHeader."Payment Method Code" <> '' then begin//New Changes without mapping
                  EcommercePaymentMethodCode := SalesHeader."Payment Method Code"
              end else
                  IsPaymentMethodErrorExists := true;*///Sales Quote Changes


            if (IsShipAgentErrorExists or IsPaymentMethodErrorExists) then begin
                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::SalesQuote, SyncStatus::"No Response", LogStatus::Cancelled, SyncSource::"Business Central", SyncLogEntryNo, SalesHeader."No.", SalesHeader."Sell-to Customer No.", '', SalesHeader.RecordId(), Database::"Sales Header");
                if SalesHeader."Shipping Agent Code" = '' then
                    DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(ShipAgentErrorTxt, SalesHeader."No."))
                else
                    if IsShipAgentErrorExists then
                        DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(ShipAgentMappingErrorTxt, SalesHeader."Shipping Agent Code", SalesHeader."No."))
                    else
                        if SalesHeader."Payment Method Code" = '' then
                            DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(PaymentMethodErrorTxt, SalesHeader."No."))
                        else
                            DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(PaymentMethodMappingErrorTxt, SalesHeader."Payment Method Code", SalesHeader."No."));
            end;
            IF (SalesHeader."i95 Sync Message" = '') then begin
                //  If (not IsShipAgentErrorExists) and (not IsPaymentMethodErrorExists) and (SalesHeader."i95 Sync Message" = '') then begin
                CreateBodyContent.SalesQuotePushData(salesHeader, BodyContent, EcommerceShipAgentCode, EcommercePaymentMethodCode, EcommerceShipAgentDescription, ShippingAgentCode);
                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::SalesQuote, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, SalesHeader."No.", SalesHeader."Sell-to Customer No.", '', SalesHeader.RecordId(), Database::"Sales Header");
                BodyContentExist := true;
            end;
            // end;
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until SalesHeader.Next() = 0;

        //  if SyncLogInserted then begin//New Change
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        SyncLogEntry.SetSourceRecordID(SalesHeader.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::SalesQuote, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        if BodyContentExist then
            ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::SalesQuote);
        //end;
    end;

    procedure SalesReturnPushData(var SalesHeader: Record "Sales Header")
    var
        ShippingAgentMapping: Record "i95 Shipping Agent Mapping";
        PaymentMethodsMapping: Record "i95 Payment Methods Mapping";
        BodyContent: Text;
        BodyContentExist: Boolean;
        IsShipAgentErrorExists: Boolean;
        IsPaymentMethodErrorExists: Boolean;
        ShippingAgentCode: Text[30];
        EcommerceShipAgentCode: Code[50];
        EcommerceShipAgentDescription: text[50];
        EcommercePaymentMethodCode: Code[50];
        SyncLogInserted: Boolean;
        ShipAgentErrorTxt: Label 'Shipping Agent Code cannot be blank for Sales return Order %1.';
        ShipAgentMappingErrorTxt: Label 'Shipping Agent Mapping does not exist for %1 in Sales return Order %2.';
        PaymentMethodErrorTxt: Label 'Payment Method Code cannot be blank for Sales return Order %1.';
        PaymentMethodMappingErrorTxt: Label 'Payment Method Mapping does not exist for %1 in Sales return Order %2.';
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);

        i95Setup.get();
        Checki95SetupData();

        repeat
            //if IsNotSyncedSalesOrder(SalesHeader) then begin
            //if not SyncLogInserted then begin//New Change
            SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::SalesReturn, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
            APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::SalesReturn, SchedulerType::PushData, SyncSource::"Business Central");

            //  SyncLogInserted := true;//New Change
            CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
            // end;//New Change

            Clear(EcommerceShipAgentCode);
            Clear(EcommerceShipAgentDescription);
            Clear(ShippingAgentCode);
            Clear(EcommercePaymentMethodCode);
            clear(IsShipAgentErrorExists);
            clear(IsPaymentMethodErrorExists);

            /* If SalesHeader."Shipping Agent Code" <> '' then begin
                 ShippingAgentMapping.Reset();
                 ShippingAgentMapping.SetRange(ShippingAgentMapping."BC Shipping Agent Code", SalesHeader."Shipping Agent Code");
                 If SalesHeader."Shipping Agent Service Code" <> '' then
                     ShippingAgentMapping.setrange(ShippingAgentMapping."BC Shipping Agent Service Code", SalesHeader."Shipping Agent Service Code");
                 If ShippingAgentMapping.FindFirst() then begin
                     EcommerceShipAgentCode := ShippingAgentMapping."E-Com Shipping Method Code";
                     EcommerceShipAgentDescription := ShippingAgentMapping."E-Com Shipping Description";
                     If ShippingAgentMapping."BC Shipping Agent Service Code" <> '' then
                         ShippingAgentCode := ShippingAgentMapping."BC Shipping Agent Code" + '-' + ShippingAgentMapping."BC Shipping Agent Service Code"
                     else
                         ShippingAgentCode := ShippingAgentMapping."BC Shipping Agent Code";
                 end else
                     IsShipAgentErrorExists := true;
             end else
                 IsShipAgentErrorExists := true;*/

            IF SalesHeader."Shipping Agent Code" <> '' then begin//New changes without mapping
                IF SalesHeader."Shipping Agent Service Code" <> '' then
                    EcommerceShipAgentCode := SalesHeader."Shipping Agent Code" + '-' + SalesHeader."Shipping Agent Service Code";
                EcommerceShipAgentDescription := format(SalesHeader."Shipping Agent Service Code" + '-' + SalesHeader."Shipping Agent Service Code");

                IF SalesHeader."Shipping Agent Service Code" <> '' then
                    ShippingAgentCode := SalesHeader."Shipping Agent Code" + '-' + SalesHeader."Shipping Agent Service Code"
                else
                    ShippingAgentCode := SalesHeader."Shipping Agent Code";
            end else
                IsShipAgentErrorExists := true;

            /* If SalesHeader."Payment Method Code" <> '' then begin
                 PaymentMethodsMapping.Reset();
                 PaymentMethodsMapping.SetRange(PaymentMethodsMapping."BC Payment Method Code", SalesHeader."Payment Method Code");
                 PaymentMethodsMapping.SetRange(PaymentMethodsMapping."BC to Ecommerce Default", true);
                 If PaymentMethodsMapping.FindFirst() then
                     EcommercePaymentMethodCode := PaymentMethodsMapping."E-Commerce Payment Method Code"
                 else begin
                     PaymentMethodsMapping.SetRange(PaymentMethodsMapping."BC to Ecommerce Default");
                     If paymentMethodsMapping.FindFirst() then
                         EcommercePaymentMethodCode := PaymentMethodsMapping."E-Commerce Payment Method Code"
                     else
                         IsPaymentMethodErrorExists := true;
                 end;
             end else
                 IsPaymentMethodErrorExists := true;*/

            IF SalesHeader."Payment Method Code" <> '' then begin//New Changes without mapping
                EcommercePaymentMethodCode := SalesHeader."Payment Method Code"
            end else
                IsPaymentMethodErrorExists := true;


            if (IsShipAgentErrorExists or IsPaymentMethodErrorExists) then begin
                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::SalesReturn, SyncStatus::"No Response", LogStatus::Cancelled, SyncSource::"Business Central", SyncLogEntryNo, SalesHeader."No.", SalesHeader."Sell-to Customer No.", '', SalesHeader.RecordId(), Database::"Sales Header");
                if SalesHeader."Shipping Agent Code" = '' then
                    DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(ShipAgentErrorTxt, SalesHeader."No."))
                else
                    if IsShipAgentErrorExists then
                        DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(ShipAgentMappingErrorTxt, SalesHeader."Shipping Agent Code", SalesHeader."No."))
                    else
                        if SalesHeader."Payment Method Code" = '' then
                            DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(PaymentMethodErrorTxt, SalesHeader."No."))
                        else
                            DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(PaymentMethodMappingErrorTxt, SalesHeader."Payment Method Code", SalesHeader."No."));
            end;

            If (not IsShipAgentErrorExists) and (not IsPaymentMethodErrorExists) and (SalesHeader."i95 Sync Message" = '') then begin
                CreateBodyContent.SalesReturnOrderPushData(salesHeader, BodyContent, EcommerceShipAgentCode, EcommercePaymentMethodCode, EcommerceShipAgentDescription, ShippingAgentCode);
                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::SalesReturn, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, SalesHeader."No.", SalesHeader."Sell-to Customer No.", '', SalesHeader.RecordId(), Database::"Sales Header");
                BodyContentExist := true;
            end;
        // end;
        until SalesHeader.Next() = 0;

        //  if SyncLogInserted then begin//New Change
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        SyncLogEntry.SetSourceRecordID(SalesHeader.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::SalesReturn, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        if BodyContentExist then
            ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::SalesReturn);
        //end;
    end;

    procedure SalesShipmentPushData(var SalesShipmentHeader: Record "Sales Shipment Header")
    var
        ShippingAgentMapping: Record "i95 Shipping Agent Mapping";
        BodyContent: Text;
        BodyContentExist: Boolean;
        IsShipAgentErrorExists: Boolean;
        ShippingAgentCode: Text[30];
        EcommerceShippingCode: Code[50];
        EcommerceShippingDescription: text[50];
        ShipAgentErrorTxt: Label 'Shipping Agent Code cannot be blank for Sales Shipment %1.';
        ShipAgentMappingErrorTxt: Label 'Shipping Agent Mapping does not exist for %1 in Sales Shipment %2.';
    begin
        Clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.Get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::Shipment, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::Shipment, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            Clear(ShippingAgentCode);
            Clear(EcommerceShippingCode);
            Clear(EcommerceShippingDescription);
            Clear(IsShipAgentErrorExists);
            CountL += 1;

            /* If SalesShipmentHeader."Shipping Agent Code" <> '' then begin
                 ShippingAgentMapping.Reset();
                 ShippingAgentMapping.SetRange(ShippingAgentMapping."BC Shipping Agent Code", SalesShipmentHeader."Shipping Agent Code");
                 If SalesShipmentHeader."Shipping Agent Service Code" <> '' then
                     ShippingAgentMapping.setrange(ShippingAgentMapping."BC Shipping Agent Service Code", SalesShipmentHeader."Shipping Agent Service Code");
                 If ShippingAgentMapping.FindFirst() then begin
                     EcommerceShippingCode := ShippingAgentMapping."E-Com Shipping Method Code";
                     EcommerceShippingDescription := ShippingAgentMapping."E-Com Shipping Description";
                     If ShippingAgentMapping."BC Shipping Agent Service Code" <> '' then
                         ShippingAgentCode := ShippingAgentMapping."BC Shipping Agent Code" + '-' + ShippingAgentMapping."BC Shipping Agent Service Code"
                     else
                         ShippingAgentCode := ShippingAgentMapping."BC Shipping Agent Code";
                 end else
                     IsShipAgentErrorExists := true;
             end else
                 IsShipAgentErrorExists := true;*/

            IF SalesShipmentHeader."Shipping Agent Code" <> '' then begin//New changes without mapping
                IF SalesShipmentHeader."Shipping Agent Service Code" <> '' then
                    EcommerceShippingCode := SalesShipmentHeader."Shipping Agent Code" + '-' + SalesShipmentHeader."Shipping Agent Service Code";
                EcommerceShippingDescription := format(SalesShipmentHeader."Shipping Agent Service Code" + '-' + SalesShipmentHeader."Shipping Agent Service Code");

                IF SalesShipmentHeader."Shipping Agent Service Code" <> '' then
                    ShippingAgentCode := SalesShipmentHeader."Shipping Agent Code" + '-' + SalesShipmentHeader."Shipping Agent Service Code"
                else
                    ShippingAgentCode := SalesShipmentHeader."Shipping Agent Code";
            end else
                IsShipAgentErrorExists := true;

            if IsShipAgentErrorExists then begin
                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::Shipment, SyncStatus::"No Response", LogStatus::Cancelled, SyncSource::"Business Central", SyncLogEntryNo, SalesShipmentHeader."No.", SalesShipmentHeader."Sell-to Customer No.", '', SalesShipmentHeader.RecordId(), Database::"Sales Shipment Header");
                If SalesShipmentHeader."Shipping Agent Code" = '' then
                    DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(ShipAgentErrorTxt, SalesShipmentHeader."No."))
                else
                    DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(ShipAgentMappingErrorTxt, SalesShipmentHeader."Shipping Agent Code", SalesShipmentHeader."No."))
            end;

            If (not IsShipAgentErrorExists) and (SalesShipmentHeader."i95 Sync Message" = '') then begin
                CreateBodyContent.SalesShipmentPushData(SalesShipmentHeader, BodyContent, EcommerceShippingCode, EcommerceShippingDescription, ShippingAgentCode);
                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::Shipment, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, SalesShipmentHeader."No.", SalesShipmentHeader."Sell-to Customer No.", '', SalesShipmentHeader.RecordId(), Database::"Sales Shipment Header");
                BodyContentExist := true;
            end;
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until SalesShipmentHeader.Next() = 0;

        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        SyncLogEntry.SetSourceRecordID(SalesShipmentHeader.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::Shipment, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        if BodyContentExist then
            ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::Shipment);
    end;

    procedure SalesInvoicePushData(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        BodyContent: text;
    begin
        Clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.Get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::Invoice, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::Invoice, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            CreateBodyContent.SalesInvoicePushData(SalesInvoiceHeader, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::Invoice, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, SalesInvoiceHeader."No.", SalesInvoiceHeader."Sell-to Customer No.", '', SalesInvoiceHeader.RecordId(), Database::"Sales Invoice Header");
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until SalesInvoiceHeader.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        SyncLogEntry.SetSourceRecordID(SalesInvoiceHeader.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::Invoice, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::Invoice);
    end;

    procedure SalesCreditmemoPushData(var SalesCreditMemoHeader: Record "Sales Cr.Memo Header")
    var
        BodyContent: text;
    begin
        Clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);

        i95Setup.Get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::SalesCreditMemo, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::SalesCreditMemo, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CreateBodyContent.SalesCreditMemoPushData(SalesCreditMemoHeader, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::SalesCreditMemo, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, SalesCreditMemoHeader."No.", SalesCreditMemoHeader."Sell-to Customer No.", '', SalesCreditMemoHeader.RecordId(), Database::"Sales Cr.Memo Header");
        until SalesCreditMemoHeader.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        SyncLogEntry.SetSourceRecordID(SalesCreditMemoHeader.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::SalesCreditMemo, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::SalesCreditMemo);
    end;

    procedure CancelSalesOrderPushData(var i95SyncLogEntry: Record "i95 Sync Log Entry")
    var
        DetSyncLogEntry: Record "i95 Detailed Sync Log Entry";
        BodyContent: Text;
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);


        i95Setup.get();
        Checki95SetupData();

        SyncLogEntryNo := i95SyncLogEntry."Entry No";
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::CancelOrder, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        // repeat
        DetSyncLogEntry.Reset();
        DetSyncLogEntry.SetCurrentKey("API Type", "Sync Log Entry No", "Sync Status");
        DetailedSyncLogEntry.SetRange("API Type", APIType::CancelOrder);
        DetSyncLogEntry.SetRange(DetSyncLogEntry."Sync Log Entry No", i95SyncLogEntry."Entry No");
        DetailedSyncLogEntry.SetRange("Sync Status", DetailedSyncLogEntry."Sync Status"::"Waiting for Sync");
        If DetSyncLogEntry.FindFirst() then
            CreateBodyContent.CancelOrderPushData(DetSyncLogEntry, BodyContent);
        //until i95SyncLogEntry.Next() = 0;

        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::CancelOrder, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::CancelOrder);
    end;

    procedure CancelSalesQuotePushData(var i95SyncLogEntry: Record "i95 Sync Log Entry")
    var
        DetSyncLogEntry: Record "i95 Detailed Sync Log Entry";
        BodyContent: Text;
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);

        i95Setup.get();
        Checki95SetupData();

        SyncLogEntryNo := i95SyncLogEntry."Entry No";
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::CancelQuote, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        // repeat
        DetSyncLogEntry.Reset();
        DetSyncLogEntry.SetCurrentKey("API Type", "Sync Log Entry No", "Sync Status");
        DetailedSyncLogEntry.SetRange("API Type", APIType::CancelQuote);
        DetSyncLogEntry.SetRange(DetSyncLogEntry."Sync Log Entry No", i95SyncLogEntry."Entry No");
        DetailedSyncLogEntry.SetRange("Sync Status", DetailedSyncLogEntry."Sync Status"::"Waiting for Sync");
        If DetSyncLogEntry.FindFirst() then
            CreateBodyContent.CancelQuotePushData(DetSyncLogEntry, BodyContent);
        //until i95SyncLogEntry.Next() = 0;

        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::CancelQuote, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::CancelQuote);
    end;


    procedure DiscountPricePushData(var Item: Record Item)
    var
        BodyContent: Text;
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::DiscountPrice, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::DiscountPrice, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            CreateBodyContent.DiscountPricePushData(Item, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::DiscountPrice, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, Item."No.", Item.Description, '', Item.RecordId(), Database::item);
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until Item.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        SyncLogEntry.SetSourceRecordID(Item.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::DiscountPrice, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::DiscountPrice);
    end;

    procedure DiscountPriceByItemDiscGrpPushData(var ItemDiscGrp: Record "Item Discount Group")
    var
        BodyContent: Text;
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.get();
        clear(CalledByItemDiscountUpdate);
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::DiscountPrice, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::DiscountPrice, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            CreateBodyContent.DiscountPriceItemDiscGrpPushData(ItemDiscGrp, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::DiscountPrice, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, ItemDiscGrp.Code, ItemDiscGrp.Description, '', ItemDiscGrp.RecordId(), database::"Item Discount Group");
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until ItemDiscGrp.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        SyncLogEntry.SetSourceRecordID(ItemDiscGrp.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::DiscountPrice, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        CalledByItemDiscountUpdate := true;
        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::DiscountPrice);
    end;

    procedure ConfigurableProductPushData(Var Item: Record Item)
    var
        BodyContent: text;
    begin
        Clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);
        i95Setup.Get();
        Checki95SetupData();


        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::ConfigurableProduct, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::ConfigurableProduct, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            CreateBodyContent.ConfigurableProductPushData(Item, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::ConfigurableProduct, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, Item."No.", Item.Description, '', item.RecordId(), Database::Item);
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until Item.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        SyncLogEntry.SetSourceRecordID(Item.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::ConfigurableProduct, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::ConfigurableProduct);
    end;

    procedure ChildProductPushData(Var Item: Record Item)
    var
        ItemVariant: Record "Item Variant";
        BodyContent: text;
    begin
        Clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.Get();
        Checki95SetupData();

        CalledByItemVariant := true;

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::Product, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::Product, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            ItemVariant.Reset();
            ItemVariant.SetRange("Item No.", Item."No.");
            if ItemVariant.FindSet() then
                repeat
                    CreateBodyContent.ChildProductPushData(ItemVariant, BodyContent);
                    DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::Product, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central",
                                                            SyncLogEntryNo, ItemVariant."Item No.", ItemVariant.Code, ItemVariant.Description, ItemVariant.RecordId(), Database::"Item Variant");
                until ItemVariant.Next() = 0;
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until Item.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        SyncLogEntry.SetSourceRecordID(Item.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::Product, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::Product);
    end;

    procedure EditSalesOrderPushData(var SalesHeader: Record "Sales Header")
    var
        ShippingAgentMapping: Record "i95 Shipping Agent Mapping";
        PaymentMethodsMapping: Record "i95 Payment Methods Mapping";
        BodyContent: Text;
        BodyContentExist: Boolean;
        IsShipAgentErrorExists: Boolean;
        IsPaymentMethodErrorExists: Boolean;
        ShippingAgentCode: Text[30];
        EcommerceShipAgentCode: Code[50];
        EcommerceShipAgentDescription: text[50];
        EcommercePaymentMethodCode: Code[50];
        SyncLogInserted: Boolean;
        ShipAgentErrorTxt: Label 'Shipping Agent Code cannot be blank for Sales Order %1.';
        ShipAgentMappingErrorTxt: Label 'Shipping Agent Mapping does not exist for %1 in Sales Order %2.';
        PaymentMethodErrorTxt: Label 'Payment Method Code cannot be blank for Sales Order %1.';
        PaymentMethodMappingErrorTxt: Label 'Payment Method Mapping does not exist for %1 in Sales Order %2.';
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.get();
        Checki95SetupData();

        repeat
            CountL += 1;
            if SalesHeader."i95 Reference ID" <> '' then begin
                if not SyncLogInserted then begin
                    SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::EditOrder, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
                    APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::EditOrder, SchedulerType::PushData, SyncSource::"Business Central");

                    SyncLogInserted := true;
                    CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
                end;

                Clear(EcommerceShipAgentCode);
                Clear(EcommerceShipAgentDescription);
                Clear(ShippingAgentCode);
                Clear(EcommercePaymentMethodCode);
                clear(IsShipAgentErrorExists);
                clear(IsPaymentMethodErrorExists);

                /*  If SalesHeader."Shipping Agent Code" <> '' then begin
                      ShippingAgentMapping.Reset();
                      ShippingAgentMapping.SetRange(ShippingAgentMapping."BC Shipping Agent Code", SalesHeader."Shipping Agent Code");
                      If SalesHeader."Shipping Agent Service Code" <> '' then
                          ShippingAgentMapping.setrange(ShippingAgentMapping."BC Shipping Agent Service Code", SalesHeader."Shipping Agent Service Code");
                      If ShippingAgentMapping.FindFirst() then begin
                          EcommerceShipAgentCode := ShippingAgentMapping."E-Com Shipping Method Code";
                          EcommerceShipAgentDescription := ShippingAgentMapping."E-Com Shipping Description";
                          If ShippingAgentMapping."BC Shipping Agent Service Code" <> '' then
                              ShippingAgentCode := ShippingAgentMapping."BC Shipping Agent Code" + '-' + ShippingAgentMapping."BC Shipping Agent Service Code"
                          else
                              ShippingAgentCode := ShippingAgentMapping."BC Shipping Agent Code";
                      end else
                          IsShipAgentErrorExists := true;
                  end else
                      IsShipAgentErrorExists := true;*/

                IF SalesHeader."Shipping Agent Code" <> '' then begin//New changes without mapping
                    IF SalesHeader."Shipping Agent Service Code" <> '' then
                        EcommerceShipAgentCode := SalesHeader."Shipping Agent Code" + '-' + SalesHeader."Shipping Agent Service Code";
                    EcommerceShipAgentDescription := format(SalesHeader."Shipping Agent Service Code" + '-' + SalesHeader."Shipping Agent Service Code");

                    IF SalesHeader."Shipping Agent Service Code" <> '' then
                        ShippingAgentCode := SalesHeader."Shipping Agent Code" + '-' + SalesHeader."Shipping Agent Service Code"
                    else
                        ShippingAgentCode := SalesHeader."Shipping Agent Code";
                end else
                    IsShipAgentErrorExists := true;


                /* If SalesHeader."Payment Method Code" <> '' then begin
                     PaymentMethodsMapping.Reset();
                     PaymentMethodsMapping.SetRange(PaymentMethodsMapping."BC Payment Method Code", SalesHeader."Payment Method Code");
                     PaymentMethodsMapping.SetRange(PaymentMethodsMapping."BC to Ecommerce Default", true);
                     If PaymentMethodsMapping.FindFirst() then
                         EcommercePaymentMethodCode := PaymentMethodsMapping."E-Commerce Payment Method Code"
                     else begin
                         PaymentMethodsMapping.SetRange(PaymentMethodsMapping."BC to Ecommerce Default");
                         If paymentMethodsMapping.FindFirst() then
                             EcommercePaymentMethodCode := PaymentMethodsMapping."E-Commerce Payment Method Code"
                         else
                             IsPaymentMethodErrorExists := true;
                     end;
                 end else
                     IsPaymentMethodErrorExists := true;*/

                IF SalesHeader."Payment Method Code" <> '' then begin//New Changes without mapping
                    EcommercePaymentMethodCode := SalesHeader."Payment Method Code"
                end else
                    IsPaymentMethodErrorExists := true;


                if (IsShipAgentErrorExists or IsPaymentMethodErrorExists) then begin
                    DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::EditOrder, SyncStatus::"No Response", LogStatus::Cancelled, SyncSource::"Business Central", SyncLogEntryNo, SalesHeader."No.", SalesHeader."Sell-to Customer No.", '', SalesHeader.RecordId(), Database::"Sales Header");
                    if SalesHeader."Shipping Agent Code" = '' then
                        DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(ShipAgentErrorTxt, SalesHeader."No."))
                    else
                        if IsShipAgentErrorExists then
                            DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(ShipAgentMappingErrorTxt, SalesHeader."Shipping Agent Code", SalesHeader."No."))
                        else
                            if SalesHeader."Payment Method Code" = '' then
                                DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(PaymentMethodErrorTxt, SalesHeader."No."))
                            else
                                DetailedSyncLogEntry.UpdateErrorMessage(StrSubstNo(PaymentMethodMappingErrorTxt, SalesHeader."Payment Method Code", SalesHeader."No."));
                end;

                If (not IsShipAgentErrorExists) and (not IsPaymentMethodErrorExists) and (SalesHeader."i95 Sync Message" = '') then begin
                    CreateBodyContent.EditSalesOrderPushData(salesHeader, BodyContent, EcommerceShipAgentCode, EcommercePaymentMethodCode, EcommerceShipAgentDescription, ShippingAgentCode);
                    DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::EditOrder, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, SalesHeader."No.", SalesHeader."Sell-to Customer No.", '', SalesHeader.RecordId(), Database::"Sales Header");
                    BodyContentExist := true;
                end;
            end;
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until SalesHeader.Next() = 0;

        if SyncLogInserted then begin

            CreateBodyContent.AddContextFooter(BodyContent);

            SyncLogEntry.reset();
            if SyncLogEntry.get(SyncLogEntryNo) then;

            APILogEntry.reset();
            if APILogEntry.get(APILogEntryNo) then;

            SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
            APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

            SyncLogEntry.SetSourceRecordID(SalesHeader.RecordId());
            commit();

            i95WebserviceExecuteCU.GetAPIUrl(APIType::EditOrder, SchedulerType::PushData);
            i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

            if TestMode then begin
                i95WebserviceExecuteCU.SetTestMode(true);
                i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
            end;

            if BodyContentExist then
                ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::EditOrder);
        end;
    end;

    procedure SalesAgentPushData(Var ShippingAgentService: Record "Shipping Agent Services")
    var
        BodyContent: text;
    begin
        Clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.Get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::ShippingAgent, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::ShippingAgent, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            CreateBodyContent.ShippingAgentPushData(ShippingAgentService, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::ShippingAgent, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, ShippingAgentService."Shipping Agent Code", ShippingAgentService.Description, '', ShippingAgentService.RecordId(), Database::"Shipping Agent Services");
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until ShippingAgentService.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        SyncLogEntry.SetSourceRecordID(ShippingAgentService.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::ShippingAgent, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Sync Complete", LogStatus::Completed, APIType::ShippingAgent);
    end;

    procedure ProductAttributesPushData(Var Item: Record Item)
    var
        BodyContent: text;
    begin
        Clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);

        i95Setup.Get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::ProductAttributeMapping, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::ProductAttributeMapping, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        CreateBodyContent.ProductAttributePushData(Item, BodyContent);
        DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::ProductAttributeMapping, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, item."No.", Item.Description, '', item.RecordId(), Database::Item);

        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        SyncLogEntry.SetSourceRecordID(Item.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::ProductAttributeMapping, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Sync Complete", LogStatus::Completed, APIType::ProductAttributeMapping);
    end;

    procedure PaymentMethodPushData(Var PaymentMethod: Record "Payment Method")
    var
        BodyContent: text;
    begin
        Clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.Get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::PaymentMethod, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::PaymentMethod, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            CreateBodyContent.PaymentMethodPushData(PaymentMethod, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::PaymentMethod, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, PaymentMethod.Code, PaymentMethod.Description, '', PaymentMethod.RecordId(), Database::"Payment Method");
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until PaymentMethod.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        SyncLogEntry.SetSourceRecordID(PaymentMethod.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::PaymentMethod, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Sync Complete", LogStatus::Completed, APIType::PaymentMethod);
    end;

    procedure AccountRecievablePushData(Var CustomerLedgerEntry: Record "Cust. Ledger Entry")
    var
        BodyContent: text;
    begin

        Clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.Get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::AccountRecievable, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::AccountRecievable, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            CreateBodyContent.AccountRecievablePushData(CustomerLedgerEntry, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::AccountRecievable, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, format(CustomerLedgerEntry."Entry No."), CustomerLedgerEntry.Description, '', CustomerLedgerEntry.RecordId(), Database::"Cust. Ledger Entry");
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until CustomerLedgerEntry.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        SyncLogEntry.SetSourceRecordID(CustomerLedgerEntry.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::AccountRecievable, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::AccountRecievable);
    end;

    procedure PostedCashRecieptPushData(Var CustomerLedgerEntry: Record "Cust. Ledger Entry")
    var
        BodyContent: text;
    begin

        Clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.Get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::PaymentJournal, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::PaymentJournal, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        // repeat
        CountL += 1;
        CreateBodyContent.PostedCashReceiptPushData(CustomerLedgerEntry, BodyContent);
        DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::PaymentJournal, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, format(CustomerLedgerEntry."Entry No."), CustomerLedgerEntry.Description, '', CustomerLedgerEntry.RecordId(), Database::"Cust. Ledger Entry");
        /*   IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until CustomerLedgerEntry.Next() = 0;*/
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        SyncLogEntry.SetSourceRecordID(CustomerLedgerEntry.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::PaymentJournal, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::PaymentJournal);
    end;

    procedure FinanceChargePushData(Var IssuedFinanceCharge: Record "Issued Fin. Charge Memo Header")
    var
        BodyContent: text;
    begin

        Clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(CountL);

        i95Setup.Get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::financeCharge, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::financeCharge, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CountL += 1;
            CreateBodyContent.FinancechargePushData(IssuedFinanceCharge, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::financeCharge, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, format(IssuedFinanceCharge."No."), IssuedFinanceCharge."Customer No.", IssuedFinanceCharge.Name, IssuedFinanceCharge.RecordId(), Database::"Issued Fin. Charge Memo Header");
            IF CountL = i95Setup."Pull Data Packet Size" then
                break;
        until IssuedFinanceCharge.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        SyncLogEntry.SetSourceRecordID(IssuedFinanceCharge.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::financeCharge, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::financeCharge);
    end;

    procedure SalesPersonPushData(var SalesPerson: Record "Salesperson/Purchaser")
    var

        BodyContent: Text;
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);

        i95Setup.get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::SalesPerson, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::SalesPerson, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CreateBodyContent.SalesPersonPushData(SalesPerson, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::SalesPerson, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, SalesPerson.Code, SalesPerson.Name, '', SalesPerson.RecordId(), Database::"Salesperson/Purchaser");
        until SalesPerson.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        SyncLogEntry.SetSourceRecordID(SalesPerson.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::SalesPerson, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::SalesPerson);

    end;

    procedure WarehouseLocationPushData(Var Location: Record Location)
    var
        BodyContent: text;
    begin

        Clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);

        i95Setup.Get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::Warehouse, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::Warehouse, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            CreateBodyContent.WarehouseLocationPushData(Location, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::Warehouse, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, format(Location.Code), Location.Name, '', Location.RecordId(), Database::Location);
        until Location.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");

        SyncLogEntry.SetSourceRecordID(Location.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::Warehouse, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::Warehouse);
    end;


    procedure ProcessPullResponse(CurrentAPIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,ReaccureToken)
    var
        ItemVariant: Record "Item Variant";
        ItemDiscGrp: Record "Item Discount Group";
        BodyContent: Text;
    begin
        Clear(ResultDataBlank);
        clear(CalledByItemDiscountUpdate);
        clear(CalledByItemVariant);

        i95Setup.get();
        Checki95SetupData();

        i95WebserviceExecuteCU.GetAPIUrl(CurrentAPIType, SchedulerType::PullResponse);
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, CurrentAPIType, SchedulerType::PullResponse, SyncSource::"Business Central");

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        SetPullResponseDefaults(CurrentAPIType);

        CreateBodyContent.AddContextHeader(BodyContent, 'PullResponse');
        DetailedSyncLogEntry.Reset();
        DetailedSyncLogEntry.SetCurrentKey("API Type", "Sync Log Entry No", "Sync Status");
        DetailedSyncLogEntry.SetRange("API Type", CurrentAPIType);
        DetailedSyncLogEntry.SetRange("Sync Log Entry No", SyncLogEntry."Entry No");
        DetailedSyncLogEntry.SetRange("Sync Status", DetailedSyncLogEntry."Sync Status"::"Waiting for Response");
        if DetailedSyncLogEntry.FindSet() then
            repeat
                CreateBodyContent.PullResponse(DetailedSyncLogEntry."Message ID", BodyContent);
            Until DetailedSyncLogEntry.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Response Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        commit();
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        if (CurrentAPIType = CurrentAPIType::Product) or (CurrentAPIType = CurrentAPIType::Inventory) then
            If (Database::"Item Variant" = DetailedSyncLogEntry."Table ID") and (ItemVariant.get(DetailedSyncLogEntry."Source Record ID")) then
                CalledByItemVariant := true;

        IF CurrentAPIType = CurrentAPIType::TierPrices then
            IF Database::"Item Variant" = DetailedSyncLogEntry."Table ID" then
                CalledByItemVariant := true;

        if CurrentAPIType = CurrentAPIType::DiscountPrice then
            If (Database::"Item Discount Group" = DetailedSyncLogEntry."Table ID") and (ItemDiscGrp.get(DetailedSyncLogEntry."Source Record ID")) then
                CalledByItemDiscountUpdate := true;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Acknowledgement", LogStatus::"In Progress", CurrentAPIType);
    end;

    procedure ProcessPullResponseAcknowledgment(CurrentAPIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,ReaccureToken)
    var
        ItemVariant: Record "Item Variant";
        ItemDiscGrp: Record "Item Discount Group";
        BodyContent: Text;
    begin
        Clear(ResultDataBlank);
        clear(CalledByItemDiscountUpdate);
        Clear(CalledByItemVariant);

        i95Setup.get();
        Checki95SetupData();

        i95WebserviceExecuteCU.GetAPIUrl(CurrentAPIType, SchedulerType::PullResponseAck);
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, CurrentAPIType, SchedulerType::PullResponseAck, SyncSource::"Business Central");

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        SetPullResponseAcknowldgmentDefaults(CurrentAPIType);

        CreateBodyContent.AddContextHeader(BodyContent, 'PullResponseAck');
        DetailedSyncLogEntry.Reset();
        DetailedSyncLogEntry.SetCurrentKey("API Type", "Sync Log Entry No", "Sync Status");
        DetailedSyncLogEntry.SetRange("API Type", CurrentAPIType);
        DetailedSyncLogEntry.SetRange("Sync Log Entry No", SyncLogEntry."Entry No");
        DetailedSyncLogEntry.SetRange("Sync Status", DetailedSyncLogEntry."Sync Status"::"Waiting for Acknowledgement");
        if DetailedSyncLogEntry.FindSet() then
            repeat
                CreateBodyContent.PullResponseAcknowledge(DetailedSyncLogEntry, BodyContent);
            Until DetailedSyncLogEntry.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Acknowledgement Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        commit();
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        if (CurrentAPIType = CurrentAPIType::Product) or (CurrentAPIType = CurrentAPIType::Inventory) then
            If (Database::"Item Variant" = DetailedSyncLogEntry."Table ID") and (ItemVariant.get(DetailedSyncLogEntry."Source Record ID")) then
                CalledByItemVariant := true;

        IF CurrentAPIType = CurrentAPIType::TierPrices then
            IF Database::"Item Variant" = DetailedSyncLogEntry."Table ID" then
                CalledByItemVariant := true;

        if CurrentAPIType = CurrentAPIType::DiscountPrice then
            If (Database::"Item Discount Group" = DetailedSyncLogEntry."Table ID") and (ItemDiscGrp.get(DetailedSyncLogEntry."Source Record ID")) then
                CalledByItemDiscountUpdate := true;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Sync Complete", LogStatus::Completed, CurrentAPIType);
    end;


    procedure SetPullResponseDefaults(CurrentAPIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,ReaccureToken)
    var
        APILogEntryL: Record "i95 API Call Log Entry";
        SchedulerID: Integer;
        SyncCounterL: Integer;
    begin
        i95Setup.Get();
        if i95Setup."Schedular ID" = '' then
            SchedulerID := 0
        else
            Evaluate(SchedulerID, i95Setup."Schedular ID");
        SyncCounterL := 1;
        APILogEntryL.Reset();
        APILogEntryL.SetRange("Sync Log Entry No", SyncLogEntryNo);
        APILogEntryL.SetRange("Scheduler Type", APILogEntryL."Scheduler Type"::PullResponse);
        if APILogEntryL.FindFirst() then
            SyncCounterL := APILogEntryL.Count();

        case CurrentAPIType of
            CurrentAPIType::Product:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 1, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::Inventory:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 2, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::TierPrices:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 5, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::SalesOrder:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 7, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::Customer:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 6, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::CustomerGroup:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 4, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::Shipment:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 8, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::Invoice:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 9, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::CancelOrder:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 24, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::TaxBusPostingGroup:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 40, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::TaxProductPostingGroup:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 41, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::TaxPostingSetup:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 42, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::CustomerDiscountGroup:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 16, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::ItemDiscountGroup:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 17, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::DiscountPrice:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 0, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::ConfigurableProduct:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 0, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::EditOrder:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 0, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::CancelQuote:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 37, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::PaymentTerm:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 43, 2, SyncCounterL, SchedulerID);
            CurrentAPIType::SalesPerson:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 45, 2, SyncCounterL, SchedulerID);
        end;
    end;

    procedure SetPullResponseAcknowldgmentDefaults(CurrentAPIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,ReaccureToken)
    var
        APILogEntryL: Record "i95 API Call Log Entry";
        SchedulerID: Integer;
        SyncCounterL: Integer;
    begin
        i95Setup.Get();
        if i95Setup."Schedular ID" = '' then
            SchedulerID := 0
        else
            Evaluate(SchedulerID, i95Setup."Schedular ID");
        SyncCounterL := 1;
        APILogEntryL.Reset();
        APILogEntryL.SetRange("Sync Log Entry No", SyncLogEntryNo);
        APILogEntryL.SetRange("Scheduler Type", APILogEntryL."Scheduler Type"::PullResponseACK);
        if APILogEntryL.FindFirst() then
            SyncCounterL := APILogEntryL.Count();

        case CurrentAPIType of
            CurrentAPIType::Product:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 1, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::Inventory:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 2, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::TierPrices:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 5, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::SalesOrder:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 7, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::Customer:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 6, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::CustomerGroup:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 4, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::Shipment:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 8, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::Invoice:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 9, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::CancelOrder:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 24, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::TaxBusPostingGroup:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 40, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::TaxProductPostingGroup:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 41, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::TaxPostingSetup:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 42, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::CustomerDiscountGroup:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 16, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::ItemDiscountGroup:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 17, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::DiscountPrice:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 0, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::ConfigurableProduct:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 0, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::EditOrder:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 0, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::PaymentTerm:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 0, 6, SyncCounterL, SchedulerID);
            CurrentAPIType::SalesPerson:
                CreateBodyContent.SetDefaultValues(SyncLogEntryNo, 0, 6, SyncCounterL, SchedulerID);

        end;
    end;

    Procedure ExecuteAPIAndUpdateLogs(CurrentSyncStatus: Integer;
                                    CurrentLogStatus: Option " ",New,"In Progress",Completed,Error;
                                    CurrentAPIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerID,ReaccureToken)
    var
        SourceRecordID: RecordId;
        ErrorFound: Boolean;
        ErrorText: Text[300];
        SyncLogStatus: Integer;
    begin
        if i95WebserviceExecuteCU.run() then begin
            Clear(ErrorFound);
            Clear(ErrorText);
            HttpReasonCode := i95WebserviceExecuteCU.GetResponseStatusCode();
            SyncLogEntry."Error Message" := Copystr(Text70328075Txt, 1, 300);
            SyncLogStatus := SyncLogEntry."Sync Status";

            If SyncLogEntry."Log Status" <> SyncLogEntry."Log Status"::Error then
                IF not ((SyncLogEntry."API Type" = SyncLogEntry."API Type"::ShippingAgent) or (SyncLogEntry."API Type" = SyncLogEntry."API Type"::PaymentMethod) or (SyncLogEntry."API Type" = SyncLogEntry."API Type"::ProductAttributeMapping)) then
                    SyncLogEntry.UpdateSyncLogEntry(SyncLogEntry."Sync Status", LogStatus::"In Progress", HttpReasonCode, i95WebserviceExecuteCU.GetAPIResponseResultText(),
                                       i95WebserviceExecuteCU.GetAPIResponseMessageText(), SyncLogEntry."Message ID", SyncLogEntry."i95 Source ID",
                                       SyncLogEntry."Status ID"::"Request Inprocess", SyncSource::"Business Central")
                else
                    IF (SyncLogEntry."API Type" = SyncLogEntry."API Type"::ShippingAgent) or (SyncLogEntry."API Type" = SyncLogEntry."API Type"::PaymentMethod) or (SyncLogEntry."API Type" = SyncLogEntry."API Type"::ProductAttributeMapping) then
                        SyncLogEntry.UpdateSyncLogEntry(SyncLogEntry."Sync Status", LogStatus::Completed, HttpReasonCode, i95WebserviceExecuteCU.GetAPIResponseResultText(),
                                              i95WebserviceExecuteCU.GetAPIResponseMessageText(), SyncLogEntry."Message ID", SyncLogEntry."i95 Source ID",
                                              SyncLogEntry."Status ID"::"Request Inprocess", SyncSource::"Business Central");

            APILogEntry.UpdateAPILogEntry(HttpReasonCode, copystr(Text70328075Txt, 1, 300));

            TargetId := i95WebserviceExecuteCU.GetTargetId();
            MessageID := i95WebserviceExecuteCU.GetResultMessageID();
            SourceID := i95WebserviceExecuteCU.GetSourceID();
            StatusID := i95WebserviceExecuteCU.GetStatusID();
            ResponseResultText := i95WebserviceExecuteCU.GetAPIResponseResultText();
            ResponseMessageText := i95WebserviceExecuteCU.GetAPIResponseMessageText();


            case SyncLogEntry."Sync Status" of
                SyncLogEntry."Sync Status"::"Waiting for Sync":
                    SyncLogEntry.WriteToBlobField(i95WebserviceExecuteCU.GetWebServiceResponseJson(), CalledByAPI::"i95 Sync Result");
                SyncLogEntry."Sync Status"::"Waiting for Response":
                    SyncLogEntry.WriteToBlobField(i95WebserviceExecuteCU.GetWebServiceResponseJson(), CalledByAPI::"i95 Response Result");
                SyncLogEntry."Sync Status"::"Waiting for Acknowledgement":
                    SyncLogEntry.WriteToBlobField(i95WebserviceExecuteCU.GetWebServiceResponseJson(), CalledByAPI::"i95 Acknowledgement Result");
            end;

            APILogEntry.WriteToBlobField(i95WebserviceExecuteCU.GetWebServiceResponseJson(), BlobToUpdate::"i95 API Result");

            If (SourceId <> '') or (StatusId <> 0) or (MessageId <> 0) or (TargetId <> '') then begin
                If (ResponseResultText <> 'false') then begin
                    If SyncLogEntry."Log Status" <> SyncLogEntry."Log Status"::Error then begin
                        SyncLogEntry."Error Message" := '';
                        SyncLogEntry.UpdateSyncLogEntry(CurrentSyncStatus, CurrentLogStatus, HttpReasonCode,
                                                        ResponseResultText, ResponseMessageText,
                                                        MessageID, SourceID, StatusID, SyncSource::"Business Central");
                    end;
                    ResultDataJsonArray := i95WebserviceExecuteCU.GetResultDataJsonArray();

                    foreach ResultDataJsonToken in ResultDataJsonArray do begin
                        ResultDataJsonObject := ResultDataJsonToken.AsObject();

                        // Inputdata := i95WebserviceExecuteCU.ProcessJsonTokenasText('InputData', ResultDataJsonObject);

                        I95Setup.Get();
                        IF (I95Setup."i95 Enable Company" = true) and (SyncLogStatus = 1) then begin
                            IF ResultDataJsonObject.Contains('inputData') then begin

                                IF ResultDataJsonObject.Get('inputData', InputDataJsonToken) then
                                    // Inputdata := InputDataJsonToken.AsValue();
                                    IF InputDataJsonToken.IsObject then
                                        InputDataJsonObject := InputDataJsonToken.AsObject();
                            end;

                            // foreach InputDataJsonToken in InputDataJsonArray do begin

                            IF InputDataJsonObject.Contains('contactInfo') then begin
                                InputDataJsonObject.Get('contactInfo', ContactDataJsonToken);
                                IF ContactDataJsonToken.IsObject then
                                    ContactDataJsonObject := ContactDataJsonToken.AsObject();
                                ContactSourceID := i95WebserviceExecuteCU.ProcessJsonTokenasCode('sourceId', ContactDataJsonObject);
                                ContactTargetID := i95WebserviceExecuteCU.ProcessJsonTokenasCode('targetId', ContactDataJsonObject);

                                Contact.Reset();
                                Contact.SetRange("No.", ContactTargetID);
                                IF Contact.FindFirst() then begin
                                    Contact."i95 Reference ID" := ContactSourceID;
                                    Contact."i95 Synced" := false;
                                    Contact.Modify(false);
                                end;
                                //  end;
                            end;
                            // end;
                            // end;

                        end;

                        If (CurrentAPIType <> CurrentAPIType::CancelOrder) and (CurrentAPIType <> CurrentAPIType::CancelQuote) then
                            GetSourceRecordID(SourceRecordID, i95WebserviceExecuteCU.ProcessJsonTokenasCode('targetId', ResultDataJsonObject), CurrentAPIType)
                        else
                            SourceRecordID := SyncLogEntry."Source Record ID";

                        If (i95WebserviceExecuteCU.ProcessJsonTokenasText('result', ResultDataJsonObject) = 'false') then begin
                            DetailedSyncLogEntry.Reset();
                            DetailedSyncLogEntry.SetCurrentKey("Sync Log Entry No");
                            DetailedSyncLogEntry.SetRange("Sync Log Entry No", SyncLogEntryNo);
                            DetailedSyncLogEntry.SetRange("Source Record ID", SourceRecordID);
                            if DetailedSyncLogEntry.FindSet() then begin
                                DetailedSyncLogEntry.UpdateSyncLogEntry(DetailedSyncLogEntry."Sync Status", DetailedSyncLogEntry."Log Status"::Error, HttpReasonCode,
                                i95WebserviceExecuteCU.ProcessJsonTokenasText('result', ResultDataJsonObject), i95WebserviceExecuteCU.ProcessJsonTokenasText('message', ResultDataJsonObject),
                                i95WebserviceExecuteCU.ProcessJsonTokenasCode('sourceId', ResultDataJsonObject),
                                i95WebserviceExecuteCU.ProcessJsontokenasInteger('messageId', ResultDataJsonObject),
                                i95WebserviceExecuteCU.ProcessJsonTokenasText('message', ResultDataJsonObject),
                                i95WebserviceExecuteCU.ProcessJsonTokenasInteger('statusId', ResultDataJsonObject),
                                i95WebserviceExecuteCU.ProcessJsonTokenasCode('targetId', ResultDataJsonObject), SyncSource::"Business Central");
                                DetailedSyncLogEntry.UpdateErrorMessage(copystr(i95WebserviceExecuteCU.ProcessJsonTokenasText('message', ResultDataJsonObject), 1, 300));
                                ErrorFound := true;
                                ErrorText := copystr(i95WebserviceExecuteCU.ProcessJsonTokenasText('message', ResultDataJsonObject), 1, 300);
                            end;
                        end else begin
                            DetailedSyncLogEntry.Reset();
                            DetailedSyncLogEntry.SetCurrentKey("Sync Log Entry No");
                            DetailedSyncLogEntry.SetRange("Sync Log Entry No", SyncLogEntryNo);
                            DetailedSyncLogEntry.SetRange("Source Record ID", SourceRecordID);
                            if DetailedSyncLogEntry.FindSet() then begin
                                DetailedSyncLogEntry.UpdateSyncLogEntry(CurrentSyncStatus, CurrentLogStatus, HttpReasonCode,
                                i95WebserviceExecuteCU.ProcessJsonTokenasText('result', ResultDataJsonObject), i95WebserviceExecuteCU.ProcessJsonTokenasText('message', ResultDataJsonObject),
                                i95WebserviceExecuteCU.ProcessJsonTokenasCode('sourceId', ResultDataJsonObject),
                                i95WebserviceExecuteCU.ProcessJsontokenasInteger('messageId', ResultDataJsonObject),
                                i95WebserviceExecuteCU.ProcessJsonTokenasText('message', ResultDataJsonObject),
                                i95WebserviceExecuteCU.ProcessJsonTokenasInteger('statusId', ResultDataJsonObject),
                                i95WebserviceExecuteCU.ProcessJsonTokenasCode('targetId', ResultDataJsonObject), SyncSource::"Business Central");

                                If (CurrentAPIType <> CurrentAPIType::CancelOrder) and (CurrentAPIType <> CurrentAPIType::CancelQuote) then
                                    UpdateSourceRecord(SourceRecordID, i95WebserviceExecuteCU.ProcessJsonTokenasCode('sourceId', ResultDataJsonObject), CurrentAPIType, CurrentSyncStatus)
                            end;
                        end;
                        APILogEntry.UpdateAPILogEntry(HttpReasonCode, '');
                    end;
                    If ErrorFound then begin
                        SyncLogEntry."Sync Status" := SyncLogStatus;
                        SyncLogEntry."Log Status" := SyncLogEntry."Log Status"::Error;
                        SyncLogEntry."Error Message" := ErrorText;
                        SyncLogEntry.modify();
                    end else begin
                        SyncLogEntry.CalcFields("No. Of Errors");
                        if SyncLogEntry."No. Of Errors" = 0 then begin
                            SyncLogEntry."Sync Status" := CurrentSyncStatus;
                            SyncLogEntry."Log Status" := CurrentLogStatus;
                            SyncLogEntry."Error Message" := '';
                            SyncLogEntry.modify();
                        end;
                    end;
                end else
                    If (ResponseResultText = 'false') then begin
                        SyncLogEntry."Sync Status" := SyncLogEntry."Sync Status";
                        SyncLogEntry."Log Status" := SyncLogEntry."Log Status"::Error;
                        SyncLogEntry."Error Message" := copystr(ResponseMessageText, 1, 300);
                        SyncLogEntry.modify();
                        APILogEntry.UpdateAPILogEntry(HttpReasonCode, i95WebserviceExecuteCU.GetAPIResponseMessageText());
                    end;

            end else
                If (ResponseResultText = 'false') then begin
                    SyncLogEntry."Sync Status" := SyncLogEntry."Sync Status"::"No Response";
                    SyncLogEntry."Log Status" := SyncLogEntry."Log Status"::Cancelled;
                    SyncLogEntry."Error Message" := '';
                    SyncLogEntry.modify();
                    APILogEntry.UpdateAPILogEntry(HttpReasonCode, i95WebserviceExecuteCU.GetAPIResponseMessageText());
                end;
        end else begin
            HttpReasonCode := i95WebserviceExecuteCU.GetResponseStatusCode();
            SyncLogEntry.UpdateSyncLogEntry(SyncLogEntry."Sync Status", LogStatus::Error, HttpReasonCode, i95WebserviceExecuteCU.GetAPIResponseResultText(), i95WebserviceExecuteCU.GetAPIResponseMessageText(), MessageID, SourceID, SyncLogEntry."Status ID"::Error, SyncSource::"Business Central");
            SyncLogEntry."Error Message" := copystr(GetLastErrorText(), 1, 300);
            SyncLogEntry.Modify();

            APILogEntry.UpdateAPILogEntry(HttpReasonCode, copystr(GetLastErrorText(), 1, 300));
        end;
    end;

    procedure GetSourceRecordID(Var SourceRecordID: RecordId; CurrentTargetID: Code[20]; CurrentAPIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerID,ReaccureToken)
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        CustomerGroup: Record "Customer Price Group";
        SalesShipment: Record "Sales Shipment Header";
        SalesInvoice: Record "Sales Invoice Header";
        TaxBusPostingGrp: Record "VAT Business Posting Group";
        TaxProdPostingGrp: Record "VAT Product Posting Group";
        PaymentTerms: Record "Payment Terms";
        TaxPostingSetup: Record "VAT Posting Setup";
        CustDiscountGroup: Record "Customer Discount Group";
        ItemDiscountGroup: Record "Item Discount Group";
        CustomerledgerEntry: Record "Cust. Ledger Entry";
        IssuesFinanceChargeMemo: Record "Issued Fin. Charge Memo Header";
        SalesPerson: Record "Salesperson/Purchaser";
        ItemCode: Code[20];
        VariantCode: Code[10];
        SalesCreditMemoHeader: Record "Sales Cr.Memo Header";
        Location: Record Location;

    begin
        case CurrentAPIType of
            CurrentAPIType::Product:
                if CalledByItemVariant then begin
                    i95Setup.get();
                    ItemCode := copystr(CopyStr(CurrentTargetID, 1, StrPos(CurrentTargetID, i95Setup."i95 Item Variant Seperator") - 1), 1, 20);
                    VariantCode := copystr(CopyStr(CurrentTargetID, StrPos(CurrentTargetID, i95Setup."i95 Item Variant Seperator") + 1), 1, 10);
                    IF ItemVariant.get(ItemCode, VariantCode) then begin
                        SourceRecordID := ItemVariant.RecordId();
                    end;
                end else begin
                    IF item.Get(CurrentTargetID) then begin
                        SourceRecordID := Item.RecordId();
                    end;
                end;
            CurrentAPIType::Inventory:
                if CalledByItemVariant then begin
                    i95Setup.get();
                    ItemCode := copystr(CopyStr(CurrentTargetID, 1, StrPos(CurrentTargetID, i95Setup."i95 Item Variant Seperator") - 1), 1, 20);
                    VariantCode := copystr(CopyStr(CurrentTargetID, StrPos(CurrentTargetID, i95Setup."i95 Item Variant Seperator") + 1), 1, 10);
                    IF ItemVariant.get(ItemCode, VariantCode) then begin
                        SourceRecordID := ItemVariant.RecordId();
                    end;
                end else begin
                    IF item.Get(CurrentTargetID) then begin
                        SourceRecordID := Item.RecordId();
                    end;
                end;

            CurrentAPIType::TierPrices,
                CurrentaPIType::ConfigurableProduct:
                begin
                    if CalledByItemVariant then begin
                        i95Setup.get();
                        ItemCode := copystr(CopyStr(CurrentTargetID, 1, StrPos(CurrentTargetID, i95Setup."i95 Item Variant Seperator") - 1), 1, 20);
                        VariantCode := copystr(CopyStr(CurrentTargetID, StrPos(CurrentTargetID, i95Setup."i95 Item Variant Seperator") + 1), 1, 10);
                        IF ItemVariant.get(ItemCode, VariantCode) then begin
                            SourceRecordID := ItemVariant.RecordId();
                        end;
                    end else begin
                        IF item.Get(CurrentTargetID) then begin
                            SourceRecordID := Item.RecordId();
                        end;
                    end;
                end;
            CurrentAPIType::SalesOrder,
        currentAPIType::EditOrder:
                begin
                    IF SalesHeader.get(SalesHeader."Document Type"::Order, CurrentTargetID) then begin
                        SourceRecordID := SalesHeader.RecordId();
                    end;
                end;
            CurrentAPIType::Customer:
                begin
                    IF Customer.get(CurrentTargetID) then begin
                        SourceRecordID := Customer.RecordId();
                    end;
                end;
            CurrentAPIType::CustomerGroup:
                begin
                    IF CustomerGroup.Get(CurrentTargetID) then begin
                        SourceRecordID := CustomerGroup.RecordId();
                    end;
                end;
            CurrentAPIType::Shipment:
                begin
                    IF SalesShipment.Get(CurrentTargetID) then begin
                        SourceRecordID := SalesShipment.RecordId();
                    end;
                end;
            CurrentAPIType::Invoice:
                begin
                    IF SalesInvoice.get(CurrentTargetID) then begin
                        SourceRecordID := SalesInvoice.RecordId();
                    end;
                end;
            CurrentAPIType::TaxBusPostingGroup:
                begin
                    IF TaxBusPostingGrp.get(CurrentTargetID) then begin
                        SourceRecordID := TaxBusPostingGrp.RecordId();
                    end;
                end;
            CurrentAPIType::TaxProductPostingGroup:
                begin
                    IF TaxProdPostingGrp.get(CurrentTargetID) then begin
                        SourceRecordID := TaxProdPostingGrp.RecordId();
                    end;
                end;
            CurrentAPIType::PaymentTerm:
                begin
                    IF PaymentTerms.get(CurrentTargetID) then begin
                        SourceRecordID := PaymentTerms.RecordId();
                    end;
                end;
            CurrentAPIType::SalesPerson:
                begin
                    IF SalesPerson.get(CurrentTargetID) then begin
                        SourceRecordID := SalesPerson.RecordId();
                    end;
                end;
            CurrentAPIType::TaxPostingSetup:
                begin
                    IF TaxPostingSetup.Get(CurrentTargetID, i95WebserviceExecuteCU.ProcessJsonTokenasCode('reference', ResultDataJsonObject)) then begin
                        SourceRecordID := TaxPostingSetup.RecordId();
                    end;
                end;
            CurrentAPIType::CustomerDiscountGroup:
                begin
                    IF CustDiscountGroup.get(CurrentTargetID) then begin
                        SourceRecordID := CustDiscountGroup.RecordId();
                    end;
                end;
            CurrentAPIType::ItemDiscountGroup:
                begin
                    IF ItemDiscountGroup.Get(CurrentTargetID) then begin
                        SourceRecordID := ItemDiscountGroup.RecordId();
                    end;
                end;
            CurrentAPIType::DiscountPrice:
                begin
                    if (not CalledByItemDiscountUpdate) and (item.Get(CurrentTargetID)) then
                        SourceRecordID := Item.RecordId()
                    else
                        if CalledByItemDiscountUpdate and (ItemDiscountGroup.Get(CurrentTargetID)) then
                            SourceRecordID := ItemDiscountGroup.RecordId();

                end;
            CurrentAPIType::SalesQuote:
                begin
                    IF SalesHeader.get(SalesHeader."Document Type"::Quote, CurrentTargetID) then begin
                        SourceRecordID := SalesHeader.RecordId();
                    end;
                end;
            CurrentAPIType::AccountRecievable, currentAPIType::PaymentJournal:
                begin
                    IF CustomerledgerEntry.Get(CurrentTargetID) then begin
                        SourceRecordID := CustomerledgerEntry.RecordId();
                    end;
                end;
            CurrentAPIType::financeCharge:
                begin
                    IF IssuesFinanceChargeMemo.Get(CurrentTargetID) then begin
                        SourceRecordID := IssuesFinanceChargeMemo.RecordId();
                    end;
                end;
            CurrentAPIType::SalesReturn:
                begin
                    IF SalesHeader.get(SalesHeader."Document Type"::"Return Order", CurrentTargetID) then begin
                        SourceRecordID := SalesHeader.RecordId();
                    end;
                end;
            CurrentAPIType::SalesCreditMemo:
                begin
                    IF SalesCreditMemoHeader.get(CurrentTargetID) then begin
                        SourceRecordID := SalesCreditMemoHeader.RecordId();
                    end;
                end;
            CurrentAPIType::Warehouse:
                begin
                    IF Location.Get(CurrentTargetID) then begin
                        SourceRecordID := Location.RecordId();
                    end;
                end;
        end;

    end;

    procedure UpdateSourceRecord(SourceRecordID: RecordId; i95SourceCode: Code[20]; CurrentAPIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerID,ReaccureToken;
                                  CurrentSyncStatus: Integer)
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        CustomerPriceGroup: Record "Customer Price Group";
        ShipToAddress: Record "Ship-to Address";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        TaxBusPostingGrp: Record "VAT Business Posting Group";
        TaxProdPostingGrp: Record "VAT Product Posting Group";
        PaymentTerms: Record "Payment Terms";
        TaxPostingSetup: Record "VAT Posting Setup";
        CustDiscountGroup: Record "Customer Discount Group";
        ItemDiscountGroup: Record "Item Discount Group";
        ItemVariant: Record "Item Variant";
        SalesPerson: Record "Salesperson/Purchaser";
        SourceRecordIDCode: Code[50];
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        IssuesFinanceChargeMemo: Record "Issued Fin. Charge Memo Header";
        SalesCreditMemoheader: Record "Sales Cr.Memo Header";
        Location: Record Location;
    begin
        case CurrentAPIType of
            CurrentAPIType::Product:
                if CalledByItemVariant then begin
                    IF ItemVariant.Get(SourceRecordID) then begin
                        ItemVariant.UpdateReferenceId(i95SourceCode);
                        Item.get(ItemVariant."Item No.");
                        item.Updatei95ChildItemVariantSyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1);
                    end;
                end else begin
                    IF item.Get(SourceRecordID) then begin
                        Item.Seti95APIUpdateCall(true);
                        Item.Updatei95SyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::Inventory:
                if CalledByItemVariant then begin
                    IF ItemVariant.Get(SourceRecordID) then begin
                        ItemVariant.Updatei95InventorySyncStatus(CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end else begin
                    IF item.Get(SourceRecordID) then begin
                        Item.Seti95APIUpdateCall(true);
                        Item.Updatei95InventorySyncStatus(CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::Customer:
                begin
                    IF Customer.Get(SourceRecordID) then begin
                        Customer.Seti95APIUpdateCall(true);
                        Customer.Updatei95SyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1, i95SourceCode);
                        ShipToAddress.Updatei95SyncStatus(SyncSource::"Business Central", Customer."No.");
                    end;
                end;
            CurrentAPIType::CustomerGroup:
                begin
                    IF CustomerPriceGroup.Get(SourceRecordID) then begin
                        CustomerPriceGroup.Seti95APIUpdateCall(true);
                        CustomerPriceGroup.Updatei95SyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::TierPrices:
                begin
                    IF item.Get(SourceRecordID) then begin
                        Item.Seti95APIUpdateCall(true);
                        Item.Updatei95SalesPriceSyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1);
                    end;

                    IF ItemVariant.Get(SourceRecordID) then begin
                        ItemVariant.Seti95APIUpdateCall(true);
                        ItemVariant.Updatei95SalesPriceSyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1);
                    end;
                end;
            CurrentAPIType::SalesOrder, CurrentAPIType::SalesQuote, CurrentAPIType::SalesReturn:
                begin
                    IF SalesHeader.Get(SourceRecordID) then begin
                        SalesHeader.Seti95PullRequestAPICall(true);
                        SalesHeader.Updatei95SyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::Shipment:
                begin
                    IF SalesShipmentHeader.Get(SourceRecordID) then begin
                        //SalesShipmentHeader.Updatei95SyncStatus(CurrentSyncStatus + 1, i95SourceCode);
                        SalesShipmentHeader."i95 Last Sync DateTime" := CurrentDateTime();
                        SalesShipmentHeader."i95 Sync Status" := CurrentSyncStatus + 1;
                        if i95SourceCode <> '' then
                            SalesShipmentHeader."i95 Reference ID" := i95SourceCode;
                        SalesShipmentHeader.Modify();
                    end;
                end;
            CurrentAPIType::Invoice:
                begin
                    IF SalesInvoiceHeader.get(SourceRecordID) then begin
                        //SalesInvoiceHeader.Updatei95SyncStatus(CurrentSyncStatus + 1, i95SourceCode);
                        SalesInvoiceHeader."i95 Last Sync DateTime" := CurrentDateTime();
                        SalesInvoiceHeader."i95 Sync Status" := CurrentSyncStatus + 1;

                        if i95SourceCode <> '' then
                            SalesInvoiceHeader."i95 Reference ID" := i95SourceCode;

                        SalesInvoiceHeader.Modify();
                    end;
                end;
            CurrentAPIType::TaxBusPostingGroup:
                begin
                    IF TaxBusPostingGrp.get(SourceRecordID) then begin
                        TaxBusPostingGrp.Updatei95SyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::TaxProductPostingGroup:
                begin
                    IF TaxProdPostingGrp.get(SourceRecordID) then begin
                        TaxProdPostingGrp.Updatei95SyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::PaymentTerm:
                begin
                    IF PaymentTerms.get(SourceRecordID) then begin
                        PaymentTerms.Updatei95SyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::SalesPerson:
                begin
                    IF SalesPerson.get(SourceRecordID) then begin
                        SalesPerson.Updatei95SyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::TaxPostingSetup:
                begin
                    IF TaxPostingSetup.get(SourceRecordID) then begin
                        TaxPostingSetup.Updatei95SyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::CustomerDiscountGroup:
                begin
                    IF CustDiscountGroup.get(SourceRecordID) then begin
                        CustDiscountGroup.Updatei95SyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::ItemDiscountGroup:
                begin
                    IF ItemDiscountGroup.Get(SourceRecordID) then begin
                        ItemDiscountGroup.Updatei95SyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::DiscountPrice:
                If not CalledByItemDiscountUpdate then begin
                    IF item.Get(SourceRecordID) then begin
                        Item.Seti95APIUpdateCall(true);
                        Item.Updatei95DiscountPriceSyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1);
                    end;
                end else begin
                    IF ItemDiscountGroup.Get(SourceRecordID) then begin
                        ItemDiscountGroup.Updatei95DiscountPriceSyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1);
                    end;
                end;
            CurrentAPIType::EditOrder:
                begin
                    IF SalesHeader.Get(SourceRecordID) then begin
                        SalesHeader.Seti95PullRequestAPICall(true);
                        SalesHeader.Updatei95SyncStatusforEditOrder(SyncSource::"Business Central", CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::ConfigurableProduct:
                begin
                    IF item.Get(SourceRecordID) then begin
                        Item.Seti95APIUpdateCall(true);
                        Item.Updatei95ItemVariantSyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::AccountRecievable, currentAPIType::PaymentJournal:
                begin
                    IF CustomerLedgerEntry.Get(SourceRecordID) then begin
                        CustomerLedgerEntry.Updatei95SyncStatus(CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::financeCharge:
                begin
                    IF IssuesFinanceChargeMemo.Get(SourceRecordID) then begin
                        // IssuesFinanceChargeMemo.Updatei95SyncStatus(CurrentSyncStatus + 1, i95SourceCode);
                        IssuesFinanceChargeMemo."i95 Last Sync DateTime" := CurrentDateTime();
                        IssuesFinanceChargeMemo."i95 Sync Status" := CurrentSyncStatus + 1;
                        if i95SourceCode <> '' then
                            IssuesFinanceChargeMemo."i95 Reference ID" := i95SourceCode;
                        IssuesFinanceChargeMemo.Modify();
                    end;
                end;
            CurrentAPIType::SalesCreditMemo:
                begin
                    IF SalesCreditMemoheader.get(SourceRecordID) then begin
                        SalesCreditMemoheader."i95 Last Sync DateTime" := CurrentDateTime();
                        SalesCreditMemoheader."i95 Sync Status" := CurrentSyncStatus + 1;
                        if i95SourceCode <> '' then
                            SalesCreditMemoheader."i95 Reference ID" := i95SourceCode;
                        SalesCreditMemoheader.Modify();
                    end;
                end;
            CurrentAPIType::Warehouse:
                begin
                    IF Location.get(SourceRecordID) then begin
                        Location.Updatei95SyncStatus(SyncSource::"Business Central", CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;

        end;
    end;

    procedure SetSynclogEntryNo(EntryNo: Integer);
    begin
        SyncLogEntryNo := EntryNo;
    end;

    procedure Checki95SetupData()
    begin
        i95Setup.TestField("Base Url");
        i95Setup.TestField("Client ID");
        i95Setup.testfield("Subscription Key");
        i95Setup.TestField("Endpoint Code");
        i95Setup.TestField(Authorization);
    end;

    procedure SetTestMode(TestModeFlag: Boolean)
    begin
        TestMode := TestModeFlag;
    end;

    procedure SetMockResponseText(MockResponseText: Text)
    begin
        TestModeResponseTxt := MockResponseText;
    end;

    procedure IsNotSyncedSalesOrder(SalesHeader: Record "Sales Header"): Boolean
    var
        DetSyncLogEntry: Record "i95 Detailed Sync Log Entry";
    begin
        DetSyncLogEntry.Reset();
        DetSyncLogEntry.SetCurrentKey(DetSyncLogEntry."Source Record ID");
        DetSyncLogEntry.SetRange(DetSyncLogEntry."Source Record ID", SalesHeader.RecordId());
        exit(DetSyncLogEntry.IsEmpty());
    end;

    procedure CreateSyncLogforCancelSalesOrder(SalesHeader: Record "Sales Header")
    var
        i95SyncLogEntry: Record "i95 Sync Log Entry";
        SyncLogEntNo: Integer;
    begin
        i95SyncLogEntry.Reset();
        If i95SyncLogEntry.FindLast() then
            SyncLogEntNo := i95SyncLogEntry."Entry No"
        else
            SyncLogEntNo := 0;

        i95SyncLogEntry.init();
        i95SyncLogEntry."Entry No" := SyncLogEntNo + 1;
        i95SyncLogEntry."Sync DateTime" := CurrentDateTime();
        i95SyncLogEntry."API Type" := i95SyncLogEntry."API Type"::CancelOrder;
        i95SyncLogEntry."Sync Status" := i95SyncLogEntry."Sync Status"::"Waiting for Sync";
        i95SyncLogEntry."Log Status" := i95SyncLogEntry."Log Status"::New;
        i95SyncLogEntry."Sync Source" := i95SyncLogEntry."Sync Source"::"Business Central";
        i95SyncLogEntry."Source Record ID" := SalesHeader.RecordId();
        i95SyncLogEntry.Insert();

        DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::CancelOrder, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", i95SyncLogEntry."Entry No", SalesHeader."No.", SalesHeader."Sell-to Customer No.", format(SalesHeader."i95 Last Modification DateTime"), SalesHeader.RecordId(), Database::"Sales Header");
    end;

    procedure CreateSyncLogforCancelSalesQuote(SalesHeader: Record "Sales Header")
    var
        i95SyncLogEntry: Record "i95 Sync Log Entry";
        SyncLogEntNo: Integer;
    begin
        i95SyncLogEntry.Reset();
        If i95SyncLogEntry.FindLast() then
            SyncLogEntNo := i95SyncLogEntry."Entry No"
        else
            SyncLogEntNo := 0;

        i95SyncLogEntry.init();
        i95SyncLogEntry."Entry No" := SyncLogEntNo + 1;
        i95SyncLogEntry."Sync DateTime" := CurrentDateTime();
        i95SyncLogEntry."API Type" := i95SyncLogEntry."API Type"::CancelQuote;
        i95SyncLogEntry."Sync Status" := i95SyncLogEntry."Sync Status"::"Waiting for Sync";
        i95SyncLogEntry."Log Status" := i95SyncLogEntry."Log Status"::New;
        i95SyncLogEntry."Sync Source" := i95SyncLogEntry."Sync Source"::"Business Central";
        i95SyncLogEntry."Source Record ID" := SalesHeader.RecordId();
        i95SyncLogEntry.Insert();

        DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::CancelQuote, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", i95SyncLogEntry."Entry No", SalesHeader."No.", SalesHeader."Sell-to Customer No.", SalesHeader."Sell-to Contact No.", SalesHeader.RecordId(), Database::"Sales Header");
    end;



    procedure VariantInventoryPushData(var ItemVariant: Record "Item Variant")
    var
        Item: Record item;
        BodyContent: text;
        InventoryString: Text[30];
    begin
        clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        Clear(ResultDataBlank);
        Clear(InventoryString);
        Clear(CalledByItemVariant);

        i95Setup.get();
        Checki95SetupData();

        SyncLogEntryNo := SyncLogEntry.InsertSyncLogEntry(APIType::Inventory, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central");
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, APIType::Inventory, SchedulerType::PushData, SyncSource::"Business Central");

        CreateBodyContent.AddContextHeader(BodyContent, 'PushData');
        repeat
            Item.Get(ItemVariant."Item No.");
            if i95Setup."i95 Default Warehouse" <> '' then
                Item.SetFilter(item."Location Filter", '%1', i95Setup."i95 Default Warehouse");
            Item.SetFilter(Item."Variant Filter", '%1', ItemVariant.Code);

            Item.CalcFields(Item.Inventory);

            Item.CalcFields(Item."Qty. on Sales Order");
            InventoryString := format(Item.Inventory - Item."Qty. on Sales Order");

            //InventoryString := format(Item.Inventory);
            InventoryString := DelChr(InventoryString, '=', ',');

            CreateBodyContent.VariantInventoryPushData(ItemVariant, InventoryString, BodyContent);
            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::Inventory, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::"Business Central", SyncLogEntryNo, ItemVariant.Code, ItemVariant."Item No.", '', ItemVariant.RecordId(), Database::"Item Variant");
        until ItemVariant.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        SyncLogEntry.reset();
        if SyncLogEntry.get(SyncLogEntryNo) then;

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        SyncLogEntry.SetSourceRecordID(ItemVariant.RecordId());
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(APIType::Inventory, SchedulerType::PushData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        CalledByItemVariant := true;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Response", LogStatus::"In Progress", APIType::Inventory);
    end;

    var
        I95Setup: Record "i95 Setup";
        SyncLogEntry: Record "i95 Sync Log Entry";
        APILogEntry: Record "i95 API Call Log Entry";
        DetailedSyncLogEntry: Record "i95 Detailed Sync Log Entry";
        i95WebserviceExecuteCU: Codeunit "i95 Webservice Execute";
        CreateBodyContent: Codeunit "i95 Create Body Content";
        MessageID: Integer;
        SourceID: Code[20];
        StatusID: Integer;
        SyncLogEntryNo: Integer;
        TestModeResponseTxt: Text;
        HttpReasonCode: Text;
        APILogEntryNo: Integer;
        ResultDataJsonArray: JsonArray;
        ResultDataJsonObject: JsonObject;
        ResultDataJsonToken: JsonToken;
        APIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerID,ReaccureToken;
        SyncStatus: Option "Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete","No Response";
        LogStatus: Option " ",New,"In Progress",Completed,Error,Cancelled;
        CalledByAPI: Option "i95 Sync Request","i95 Sync Result","i95 Response Request","i95 Response Result","i95 Acknowledgement Request","i95 Acknowledgement Result";
        BlobToUpdate: Option "i95 API Request","i95 API Result";
        SyncSource: Option "","Business Central",i95;
        SchedulerType: Option " ",PushData,PullResponse,PullResponseAck,PullData,PushResponse;
        TargetId: code[20];
        ResultDataBlank: Boolean;
        TestMode: Boolean;
        CalledByItemDiscountUpdate: Boolean;
        CalledByItemVariant: Boolean;
        Text70328075Txt: Label 'Result Data Blank.';
        ResponseResultText: Text;
        ResponseMessageText: Text;
        InputDataJsonObject: JsonObject;
        InputDataJsonArray: JsonArray;
        InputJsonToken: JsonToken;
        InputDataJsonToken: JsonToken;
        ContactJsonToken: JsonToken;
        ContactDataJsonObject: JsonObject;
        ContactDataJsonArray: JsonArray;
        ContactDataJsonToken: JsonToken;
        ContactTargetID: Code[20];
        ContactSourceID: code[20];
        ContactBusinessRelation: Record "Contact Business Relation";
        Contact: Record Contact;
        InputJsonValue: JsonValue;
        ContactJsonvalue: JsonValue;
        Inputdata: JsonValue;
        CountL: Integer;
}