codeunit 70008 "i95 Update Data to BC"
{
    trigger OnRun()
    begin
        Clear(HttpReasonCode);
        Clear(ResponseResultText);

        if i95SyncLogEntry.get(i95SyncLogEntryNo) then begin
            WebServiceJsonObject.ReadFrom(i95SyncLogEntry.ReadFromBlobField(APIDatatoRead::"i95 Sync Result"));
            if i95SyncLogEntry."API Type" = i95SyncLogEntry."API Type"::SchedulerID then
                i95WebServiceExecuteCU.ProcessJsonResponseforSchedulerIDPull(WebServiceJsonObject)
            else
                If i95SyncLogEntry."API Type" = i95SyncLogEntry."API Type"::ReaccureToken then
                    i95WebServiceExecuteCU.ProcessJsonResponseforReccuretokenPull(WebServiceJsonObject)
                else
                    i95WebServiceExecuteCU.ProcessJsonResponseforPullData(WebServiceJsonObject);

            HttpReasonCode := i95SyncLogEntry."Http Response Code";
            ResponseResultText := i95SyncLogEntry."Response Result";

            case i95SyncLogEntry."API Type" of
                i95SyncLogEntry."API Type"::Customer:
                    UpdateCustomerData();
                i95SyncLogEntry."API Type"::CustomerGroup:
                    UpdateCustomerGroupData();
                i95SyncLogEntry."API Type"::SalesOrder:
                    UpdateSalesOrderData();
                i95SyncLogEntry."API Type"::Product:
                    // UpdateProductData()
                    begin
                        i95Setup.Get();
                        IF not (i95Setup."i95 Enable ProdAtriButeMapping" = true) then
                            UpdateProductData()
                        else
                            UpdateProductwithMapping();
                    end;
                i95SyncLogEntry."API Type"::SchedulerID:
                    UpdateSchedulerID();
                i95SyncLogEntry."API Type"::EntityManagement:
                    UpdateEntityManagement();
                i95SyncLogEntry."API Type"::PaymentJournal:
                    UpdatecashRecieptJournal();
                i95SyncLogEntry."API Type"::SalesQuote:
                    UpdateSalesQuote();
                i95SyncLogEntry."API Type"::AccountRecievable:
                    UpdatecashRecieptJournal();
                i95SyncLogEntry."API Type"::ReaccureToken:
                    UpdateReccuretoken();
                i95SyncLogEntry."API Type"::SalesReturn:
                    UpdateSalesreturnOrderData();
                i95SyncLogEntry."API Type"::ProductAttributeMapping:
                    UpdateProductAttributes();

            end;
        end;
    end;

    procedure SetParamaters(EntryNo: Integer)
    begin
        i95SyncLogEntryNo := EntryNo;
    end;

    procedure UpdateCustomerData()
    var
        NewCustomer: Record customer;
        ShiptoAddress: Record "Ship-to Address";
        SourceNo: Code[20];
        Email: Text;
        FirstName: Text;
        LastName: text;
        CustPriceGroup: Code[20];
        SourceAddressID: Code[20];
        ShipToFirstName: Text;
        ShipToLastName: Text;
        Address: text[50];
        Address2: text[50];
        City: text[30];
        PhoneNo: text[30];
        RegionCode: Code[10];
        CountryCode: Code[10];
        PostCode: code[20];
        IsDefaultBilling: Boolean;
        IsDefaultShipping: Boolean;
        CustomerNo: Code[20];
        CustomerDes: Text;
    begin

        ResultDataJsonArray := i95WebserviceExecuteCU.GetResultDataJsonArray();
        ResultJsonToken := i95WebserviceExecuteCU.GetResultJsonToken();
        ResultDataJsonToken := i95WebserviceExecuteCU.GetResultDataJsonToken();
        ResultDataJsonObject := i95WebserviceExecuteCU.GetResultDataJsonObject();

        i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"No Response", LogStatus::Cancelled, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);

        foreach ResultDataJsonToken in ResultDataJsonArray do begin
            //SourceNo := '';

            UpdateCustomer.SetCustomerValues(i95WebServiceExecuteCU, NoSeriesMgt, SourceRecordID, SecSourceRecordID, WebServiceJsonObject,
             ResultDataJsonArray, ResultJsonToken, ResultDataJsonToken, ResultDataJsonObject, HttpReasonCode, ResponseResultText, ResponseMessageText, i95SyncLogEntry,
             i95Setup, SyncSource, SalesReceivablesSetup);
            Commit();

            IF not UpdateCustomer.Run() then begin
                UpdateCustomer.GetCustomerValues(SourceRecordID, CustomerNo, CustomerDes, SecSourceRecordID, i95SyncLogEntry, SourceID, MessageID, ContactNo);
                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::Customer, SyncStatus::"Waiting for Sync", LogStatus::Error, SyncSource::i95, i95SyncLogEntryNo, NewCustomer."No.", CustomerDes, '', NewCustomer.RecordId, Database::customer);
                DetailedSyncLogEntry."Message ID" := MessageID;
                DetailedSyncLogEntry."Error Message" := copystr(GetLastErrorText(), 1, 300);
                DetailedSyncLogEntry."i95 Source Id" := SourceID;
                DetailedSyncLogEntry."Field 3" := ContactNo;
                DetailedSyncLogEntry."Status ID" := DetailedSyncLogEntry."Status ID"::Error;
                DetailedSyncLogEntry.Modify(false);
            end else begin
                UpdateCustomer.GetCustomerValues(SourceRecordID, CustomerNo, CustomerDes, SecSourceRecordID, i95SyncLogEntry, SourceID, MessageID, ContactNo);

                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::Customer, SyncStatus::"Waiting for Response", LogStatus::New, SyncSource::i95, i95SyncLogEntryNo, CustomerNo, CustomerDes, '', SourceRecordID, Database::customer);
                DetailedSyncLogEntry."i95 Source Id" := SourceID;
                DetailedSyncLogEntry."Message ID" := MessageID;
                DetailedSyncLogEntry."Field 1" := CustomerNo;
                DetailedSyncLogEntry."Field 2" := CustomerDes;
                DetailedSyncLogEntry."Field 3" := ContactNo;
                DetailedSyncLogEntry."Source Record ID" := SourceRecordID;
                DetailedSyncLogEntry.Modify(false);
            end;

            i95SyncLogEntry."Error Message" := '';
            i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Waiting for Response", LogStatus::"In-Progress", i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);
            i95SyncLogEntry.SetSourceRecordID(SourceRecordID);
            i95SyncLogEntry.SetSecondarySourceRecordID(SecSourceRecordID);
            i95SyncLogEntry.UpdateDataStatus(DataStatus::"Data Updated");
            //end else

        end;
    end;

    procedure UpdateCustomerGroupData()
    var
        CustomerGroup: Record "Customer price Group";
        CustomerGroupCode: code[20];
        CustomerGroupDescription: text;
        InputJsonObject: JsonObject;
    begin
        ResultDataJsonArray := i95WebserviceExecuteCU.GetResultDataJsonArray();

        i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"No Response", LogStatus::Cancelled, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);

        foreach ResultDataJsonToken in ResultDataJsonArray do begin
            CustomerGroupCode := '';

            ResultDataJsonObject := ResultDataJsonToken.AsObject();
            if ResultDataJsonObject.Contains('inputData') then begin
                ResultDataJsonObject.get('inputData', ResultJsonToken);
                InputJsonObject := ResultJsonToken.AsObject();
                CustomerGroupCode := i95WebserviceExecuteCU.ProcessJsonTokenasCode('customerGroup', InputJsonObject);
                CustomerGroupDescription := i95WebserviceExecuteCU.ProcessJsonTokenasText('groupDescription', InputJsonObject);
                TargetID := i95WebserviceExecuteCU.ProcessJsonTokenasCode('targetId', InputJsonObject);
                MessageID := i95WebServiceExecuteCU.ProcessJsontokenasInteger('messageId', ResultDataJsonObject);
                StatusID := i95WebServiceExecuteCU.ProcessJsonTokenasInteger('statusId', ResultDataJsonObject);
                SourceID := i95WebServiceExecuteCU.ProcessJsonTokenascode('sourceId', ResultDataJsonObject);
                i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Waiting for Sync", LogStatus::New, HttpReasonCode, ResponseResultText, ResponseMessageText, MessageID, SourceID, StatusID, SyncSource::i95);
            end;

            clear(SourceRecordID);
            If CustomerGroupCode <> '' then begin
                If not CustomerGroup.get(CustomerGroupCode) then begin
                    CustomerGroup.init();
                    CustomerGroup.validate(CustomerGroup.Code, CustomerGroupCode);
                    CustomerGroup.validate(Description, CustomerGroupDescription);
                    CustomerGroup."i95 Created By" := 'i95';
                    CustomerGroup."i95 Created DateTime" := CurrentDateTime();
                    CustomerGroup."i95 Creation Source" := CustomerGroup."i95 Creation Source"::i95;
                    CustomerGroup.insert();
                    SourceRecordID := CustomerGroup.RecordId();
                end else begin
                    CustomerGroup.validate(Description, CustomerGroupDescription);
                    CustomerGroup.Seti95APIUpdateCall(true);
                    CustomerGroup.Modify();
                    SourceRecordID := CustomerGroup.RecordId();
                end;
                CustomerGroup.Seti95APIUpdateCall(true);
                CustomerGroup."i95 Last Modification DateTime" := CurrentDateTime();
                CustomerGroup."i95 Last Modified By" := copystr(UserId(), 1, 80);
                CustomerGroup."i95 Last Sync DateTime" := CurrentDateTime();
                CustomerGroup."i95 Sync Status" := CustomerGroup."i95 Sync Status"::"Waiting for Response";
                CustomerGroup."i95 Last Modification Source" := CustomerGroup."i95 Last Modification Source"::i95;
                CustomerGroup."i95 Reference ID" := CustomerGroupCode;
                CustomerGroup.Modify(false);

                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::CustomerGroup, SyncStatus::"Waiting for Response", LogStatus::New, SyncSource::i95, i95SyncLogEntryNo, CustomerGroup.Code, CustomerGroup.Description, '', CustomerGroup.RecordId(), Database::"Customer Price Group");

                i95SyncLogEntry."Error Message" := '';
                i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Waiting for Response", LogStatus::"In-Progress", i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);
                i95SyncLogEntry.SetSourceRecordID(SourceRecordID);
                i95SyncLogEntry.UpdateDataStatus(DataStatus::"Data Updated");
            end else
                i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"No Response", LogStatus::Cancelled, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);
        end;
    end;

    procedure UpdateSalesOrderData()
    var
    begin
        SalesInputDataJsonArray := i95WebserviceExecuteCU.GetResultDataJsonArray();
        SalesInputJsonToken := i95WebserviceExecuteCU.GetResultJsonToken();
        SalesInputDataJsonToken := i95WebserviceExecuteCU.GetResultDataJsonToken();
        SalesInputDataJsonObject := i95WebserviceExecuteCU.GetResultDataJsonObject();

        i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"No Response", LogStatus::Cancelled, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);

        foreach SalesInputDataJsonToken in SalesInputDataJsonArray do begin

            SalesInputDataJsonObject := SalesInputDataJsonToken.AsObject();

            UpdateSalesOrder.SetSaleOrderValues(i95WebServiceExecuteCU, SalesHeader, SalesInputDataJsonArray, SalesInputJsonToken, SalesInputDataJsonToken, SalesInputDataJsonObject, i95SyncLogEntry);

            Commit();

            IF Not UpdateSalesOrder.Run() then begin
                UpdateSalesOrder.Getvalues(SalesHeader, SourceRecordID, i95SyncLogEntry, SourceID, MessageID, SalesOrderNo);
                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::SalesOrder, SyncStatus::"Waiting for Sync", LogStatus::Error, SyncSource::i95, i95SyncLogEntryNo, SalesHeader."No.", SalesHeader."Sell-to Customer No.", '', SalesHeader.RecordId(), Database::"Sales Header");
                DetailedSyncLogEntry."Error Message" := copystr(GetLastErrorText(), 1, 300);
                DetailedSyncLogEntry."Status ID" := DetailedSyncLogEntry."Status ID"::Error;
                DetailedSyncLogEntry."i95 Source Id" := SourceID;
                DetailedSyncLogEntry."Message ID" := MessageID;
                DetailedSyncLogEntry."Field 1" := SalesOrderNo;
                DetailedSyncLogEntry.Modify(false);
            end else begin
                UpdateSalesOrder.Getvalues(SalesHeader, SourceRecordID, i95SyncLogEntry, SourceID, MessageID, SalesOrderNo);

                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::SalesOrder, SyncStatus::"Waiting for Response", LogStatus::New, SyncSource::i95, i95SyncLogEntryNo, SalesHeader."No.", SalesHeader."Sell-to Customer No.", '', SourceRecordID, Database::"Sales Header");
                DetailedSyncLogEntry."i95 Source Id" := SourceID;
                DetailedSyncLogEntry."Message ID" := MessageID;
                DetailedSyncLogEntry."Field 1" := SalesOrderNo;
                DetailedSyncLogEntry.Modify(false);
            end;

            i95SyncLogEntry."Error Message" := '';
            i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Waiting for Response", LogStatus::"In-Progress", i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);

            i95SyncLogEntry.SetSourceRecordID(SourceRecordID);
            i95SyncLogEntry.UpdateDataStatus(DataStatus::"Data Updated");
        end;
    end;

    procedure UpdateSalesreturnOrderData()
    var
    begin
        SalesInputDataJsonArray := i95WebserviceExecuteCU.GetResultDataJsonArray();
        SalesInputJsonToken := i95WebserviceExecuteCU.GetResultJsonToken();
        SalesInputDataJsonToken := i95WebserviceExecuteCU.GetResultDataJsonToken();
        SalesInputDataJsonObject := i95WebserviceExecuteCU.GetResultDataJsonObject();

        i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"No Response", LogStatus::Cancelled, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);

        foreach SalesInputDataJsonToken in SalesInputDataJsonArray do begin

            SalesInputDataJsonObject := SalesInputDataJsonToken.AsObject();


            UpdateSalesreturnOrder.SetSaleOrderValues(i95WebServiceExecuteCU, SalesHeader, SalesInputDataJsonArray, SalesInputJsonToken, SalesInputDataJsonToken, SalesInputDataJsonObject, i95SyncLogEntry);

            Commit();

            IF Not UpdateSalesreturnOrder.Run() then begin
                UpdateSalesreturnOrder.Getvalues(SalesHeader, SourceRecordID, i95SyncLogEntry, SourceID, MessageID, SalesOrderNo);
                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::SalesReturn, SyncStatus::"Waiting for Sync", LogStatus::Error, SyncSource::i95, i95SyncLogEntryNo, SalesHeader."No.", SalesHeader."Sell-to Customer No.", '', SalesHeader.RecordId(), Database::"Sales Header");
                DetailedSyncLogEntry."Error Message" := copystr(GetLastErrorText(), 1, 300);
                DetailedSyncLogEntry."Status ID" := DetailedSyncLogEntry."Status ID"::Error;
                DetailedSyncLogEntry."i95 Source Id" := SourceID;
                DetailedSyncLogEntry."Message ID" := MessageID;
                DetailedSyncLogEntry."Field 1" := SalesOrderNo;
                DetailedSyncLogEntry.Modify(false);
            end else begin
                UpdateSalesreturnOrder.Getvalues(SalesHeader, SourceRecordID, i95SyncLogEntry, SourceID, MessageID, SalesOrderNo);

                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::SalesReturn, SyncStatus::"Waiting for Response", LogStatus::New, SyncSource::i95, i95SyncLogEntryNo, SalesHeader."No.", SalesHeader."Sell-to Customer No.", '', SourceRecordID, Database::"Sales Header");
                DetailedSyncLogEntry."i95 Source Id" := SourceID;
                DetailedSyncLogEntry."Message ID" := MessageID;
                DetailedSyncLogEntry."Field 1" := SalesOrderNo;
                DetailedSyncLogEntry.Modify(false);
            end;

            i95SyncLogEntry."Error Message" := '';
            i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Waiting for Response", LogStatus::"In-Progress", i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);

            i95SyncLogEntry.SetSourceRecordID(SourceRecordID);
            i95SyncLogEntry.UpdateDataStatus(DataStatus::"Data Updated");
        end;
    end;

    procedure UpdateSalesQuote()
    var
    begin
        SalesInputDataJsonArray := i95WebserviceExecuteCU.GetResultDataJsonArray();
        SalesInputJsonToken := i95WebserviceExecuteCU.GetResultJsonToken();
        SalesInputDataJsonToken := i95WebserviceExecuteCU.GetResultDataJsonToken();
        SalesInputDataJsonObject := i95WebserviceExecuteCU.GetResultDataJsonObject();

        i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"No Response", LogStatus::Cancelled, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);

        foreach SalesInputDataJsonToken in SalesInputDataJsonArray do begin

            SalesInputDataJsonObject := SalesInputDataJsonToken.AsObject();

            UpdateSalesquoteG.SetSaleOrderValues(i95WebServiceExecuteCU, SalesHeader, SalesInputDataJsonArray, SalesInputJsonToken, SalesInputDataJsonToken, SalesInputDataJsonObject, i95SyncLogEntry);

            Commit();

            IF Not UpdateSalesquoteG.Run() then begin
                UpdateSalesquoteG.Getvalues(SalesHeader, SourceRecordID, i95SyncLogEntry, SourceID, MessageID, SalesOrderNo);
                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::SalesQuote, SyncStatus::"Waiting for Sync", LogStatus::Error, SyncSource::i95, i95SyncLogEntryNo, SalesHeader."No.", SalesHeader."Sell-to Customer No.", '', SalesHeader.RecordId(), Database::"Sales Header");
                DetailedSyncLogEntry."Error Message" := copystr(GetLastErrorText(), 1, 300);
                DetailedSyncLogEntry."Status ID" := DetailedSyncLogEntry."Status ID"::Error;
                DetailedSyncLogEntry."i95 Source Id" := SourceID;
                DetailedSyncLogEntry."Message ID" := MessageID;
                DetailedSyncLogEntry."Field 1" := SalesOrderNo;
                DetailedSyncLogEntry.Modify(false);
            end else begin
                UpdateSalesquoteG.Getvalues(SalesHeader, SourceRecordID, i95SyncLogEntry, SourceID, MessageID, SalesOrderNo);
                DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::SalesQuote, SyncStatus::"Waiting for Response", LogStatus::New, SyncSource::i95, i95SyncLogEntryNo, SalesHeader."No.", SalesHeader."Sell-to Customer No.", '', SourceRecordID, Database::"Sales Header");
                DetailedSyncLogEntry."i95 Source Id" := SourceID;
                DetailedSyncLogEntry."Message ID" := MessageID;
                DetailedSyncLogEntry."Field 1" := SalesOrderNo;
                DetailedSyncLogEntry.Modify(false);
            end;

            i95SyncLogEntry."Error Message" := '';
            i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Waiting for Response", LogStatus::"In-Progress", i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);

            i95SyncLogEntry.SetSourceRecordID(SourceRecordID);
            i95SyncLogEntry.UpdateDataStatus(DataStatus::"Data Updated");
        end;
    end;



    procedure UpdateProductData()
    var
        InventorySetup: Record "Inventory Setup";
        ItemLedgEntry: Record "Item Ledger Entry";
        NewItem: Record Item;
        SourceNo: Code[20];
        Name: Text;
        Price: Decimal;
        Weight: Decimal;
        Cost: Decimal;
        Description: Text;
        Sku: text;
        ItemNoL: Code[20];
        CountL: Integer;

    begin
        Clear(CountL);
        ResultDataJsonArray := i95WebserviceExecuteCU.GetResultDataJsonArray();
        ResultJsonToken := i95WebserviceExecuteCU.GetResultJsonToken();
        ResultDataJsonToken := i95WebserviceExecuteCU.GetResultDataJsonToken();
        ResultDataJsonObject := i95WebserviceExecuteCU.GetResultDataJsonObject();

        i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"No Response", LogStatus::Cancelled, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);

        foreach ResultDataJsonToken in ResultDataJsonArray do begin
            SourceNo := '';

            ResultDataJsonObject := ResultDataJsonToken.AsObject();
            SourceNo := i95WebserviceExecuteCU.ProcessJsonTokenasCode('sourceId', ResultDataJsonObject);
            TargetID := i95WebserviceExecuteCU.ProcessJsonTokenasCode('targetId', ResultDataJsonObject);
            MessageID := i95WebServiceExecuteCU.ProcessJsontokenasInteger('messageId', ResultDataJsonObject);
            StatusID := i95WebServiceExecuteCU.ProcessJsonTokenasInteger('statusId', ResultDataJsonObject);
            SourceID := i95WebServiceExecuteCU.ProcessJsonTokenascode('sourceId', ResultDataJsonObject);
            i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Waiting for Sync", LogStatus::New, HttpReasonCode, ResponseResultText, ResponseMessageText, MessageID, SourceID, StatusID, SyncSource::i95);
            if ResultDataJsonObject.Contains('inputData') then begin
                ResultDataJsonObject.get('inputData', ResultDataJsonToken);
                ResultDataJsonObject := ResultDataJsonToken.AsObject();

                Name := i95WebserviceExecuteCU.ProcessJsonTokenasText('name', ResultDataJsonObject);
                Sku := i95WebServiceExecuteCU.ProcessJsonTokenastext('sku', ResultDataJsonObject);
                Price := i95WebServiceExecuteCU.ProcessJsonTokenasDecimal('price', ResultDataJsonObject);
                Weight := i95WebServiceExecuteCU.ProcessJsonTokenasDecimal('weight', ResultDataJsonObject);
                Cost := i95WebServiceExecuteCU.ProcessJsonTokenasDecimal('cost', ResultDataJsonObject);
                Description := i95WebServiceExecuteCU.ProcessJsonTokenasText('description', ResultDataJsonObject);


                UpdateProduct.set(InventorySetup, ItemLedgEntry, NewItem, SourceNo, Name, Price, Weight, Cost, Description, Sku, i95Setup, NoSeriesMgt, SourceRecordID);
                Commit();

                IF Not UpdateProduct.Run() then begin

                    DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::Product, SyncStatus::"Waiting for Sync", LogStatus::Error, SyncSource::i95, i95SyncLogEntryNo, NewItem."No.", NewItem."No.", '', NewItem.RecordId, Database::Item);
                    DetailedSyncLogEntry."Error Message" := copystr(GetLastErrorText(), 1, 300);
                    DetailedSyncLogEntry."Log Status" := DetailedSyncLogEntry."Log Status"::Error;
                    DetailedSyncLogEntry."Status ID" := DetailedSyncLogEntry."Status ID"::Error;
                    DetailedSyncLogEntry.Modify(false);

                end else begin
                    DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::Product, SyncStatus::"Waiting for Response", LogStatus::New, SyncSource::i95, i95SyncLogEntryNo, NewItem."No.", NewItem."No.", '', NewItem.RecordId(), Database::Item);
                    UpdateProduct.GetSourceRecordID(SourceRecordID, ItemNoL);
                    DetailedSyncLogEntry."Source Record ID" := SourceRecordID;
                    DetailedSyncLogEntry."Field 1" := ItemNoL;
                    DetailedSyncLogEntry.Modify(false);
                end;


                i95SyncLogEntry."Error Message" := '';
                i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Waiting for Response", LogStatus::"In-Progress", i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);
                i95SyncLogEntry.SetSourceRecordID(SourceRecordID);

                i95SyncLogEntry.UpdateDataStatus(DataStatus::"Data Updated");
            end else
                i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"No Response", LogStatus::Cancelled, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);
        end;
    end;

    procedure UpdateProductwithMapping()
    var
        InventorySetup: Record "Inventory Setup";
        ItemLedgEntry: Record "Item Ledger Entry";
        NewItem: Record Item;
        SourceNo: Code[20];
        Name: Text;
        Price: Decimal;
        Weight: Decimal;
        Cost: Decimal;
        Description: Text;
        Sku: Code[20];
        ItemNoL: Code[20];
        CountL: Integer;

    begin
        Clear(CountL);
        ResultDataJsonArray := i95WebserviceExecuteCU.GetResultDataJsonArray();
        ResultJsonToken := i95WebserviceExecuteCU.GetResultJsonToken();
        ResultDataJsonToken := i95WebserviceExecuteCU.GetResultDataJsonToken();
        ResultDataJsonObject := i95WebserviceExecuteCU.GetResultDataJsonObject();

        i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"No Response", LogStatus::Cancelled, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);

        foreach ResultDataJsonToken in ResultDataJsonArray do begin
            SourceNo := '';

            ResultDataJsonObject := ResultDataJsonToken.AsObject();
            SourceNo := i95WebserviceExecuteCU.ProcessJsonTokenasCode('sourceId', ResultDataJsonObject);
            TargetID := i95WebserviceExecuteCU.ProcessJsonTokenasCode('targetId', ResultDataJsonObject);
            MessageID := i95WebServiceExecuteCU.ProcessJsontokenasInteger('messageId', ResultDataJsonObject);
            StatusID := i95WebServiceExecuteCU.ProcessJsonTokenasInteger('statusId', ResultDataJsonObject);
            SourceID := i95WebServiceExecuteCU.ProcessJsonTokenascode('sourceId', ResultDataJsonObject);
            i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Waiting for Sync", LogStatus::New, HttpReasonCode, ResponseResultText, ResponseMessageText, MessageID, SourceID, StatusID, SyncSource::i95);
            if ResultDataJsonObject.Contains('inputData') then begin
                ResultDataJsonObject.get('inputData', ResultDataJsonToken);
                ResultDataJsonObject := ResultDataJsonToken.AsObject();


                UpdateProductwithMappingG.set(InventorySetup, ItemLedgEntry, NewItem, SourceNo, i95Setup, NoSeriesMgt, SourceRecordID, ResultDataJsonArray, ResultJsonToken, ResultDataJsonToken, ResultDataJsonObject, i95WebServiceExecuteCU);
                Commit();

                IF Not UpdateProductwithMappingG.Run() then begin

                    DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::Product, SyncStatus::"Waiting for Sync", LogStatus::Error, SyncSource::i95, i95SyncLogEntryNo, NewItem."No.", Name, '', NewItem.RecordId, Database::Item);
                    DetailedSyncLogEntry."Error Message" := copystr(GetLastErrorText(), 1, 300);
                    DetailedSyncLogEntry."Log Status" := DetailedSyncLogEntry."Log Status"::Error;
                    DetailedSyncLogEntry."Status ID" := DetailedSyncLogEntry."Status ID"::Error;
                    DetailedSyncLogEntry.Modify(false);

                end else begin
                    DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::Product, SyncStatus::"Waiting for Response", LogStatus::New, SyncSource::i95, i95SyncLogEntryNo, NewItem."No.", Name, '', NewItem.RecordId(), Database::Item);
                    UpdateProductwithMappingG.GetSourceRecordID(SourceRecordID, ItemNoL);
                    DetailedSyncLogEntry."Source Record ID" := SourceRecordID;
                    DetailedSyncLogEntry."Field 1" := ItemNoL;
                    DetailedSyncLogEntry.Modify(false);
                end;


                i95SyncLogEntry."Error Message" := '';
                i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Waiting for Response", LogStatus::"In-Progress", i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);
                i95SyncLogEntry.SetSourceRecordID(SourceRecordID);

                i95SyncLogEntry.UpdateDataStatus(DataStatus::"Data Updated");
            end else
                i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"No Response", LogStatus::Cancelled, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);
        end;
    end;

    procedure UpdateSchedulerID()
    var
        i95DevSetup: Record "i95 Setup";
        InputJsonObject: JsonObject;
        SchedulerIDTxt: Text;
        IsConfigurationUpdated: Boolean;
    begin
        ResultDataJsonArray := i95WebserviceExecuteCU.GetResultDataJsonArray();
        InputJsonObject := i95WebserviceExecuteCU.GetResultDataJsonObject();
        SchedulerIDTxt := '';

        SchedulerIDTxt := i95WebserviceExecuteCU.ProcessJsonTokenasText('schedulerId', InputJsonObject);
        IsConfigurationUpdated := false;
        IsConfigurationUpdated := i95WebServiceExecuteCU.ProcessJsonTokenasBoolean('IsConfigurationUpdated', InputJsonObject);
        clear(SourceRecordID);
        If SchedulerIDTxt <> '' then begin
            If not i95DevSetup.get() then begin
                i95DevSetup.init();
                i95DevSetup."Schedular ID" := copystr(SchedulerIDTxt, 1, 50);
                i95DevSetup.IsConfigurationUpdated := IsConfigurationUpdated;
                i95DevSetup.insert();
                SourceRecordID := i95DevSetup.RecordId();
            end else begin
                i95DevSetup."Schedular ID" := copystr(SchedulerIDTxt, 1, 50);
                i95DevSetup.IsConfigurationUpdated := IsConfigurationUpdated;
                i95DevSetup.Modify(false);
                SourceRecordID := i95DevSetup.RecordId();
            end;

            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::SchedulerID, SyncStatus::"Waiting for Response", LogStatus::New, SyncSource::i95, i95SyncLogEntryNo, i95DevSetup."Schedular ID", '', '', i95DevSetup.RecordId(), Database::"i95 Setup");
            DetailedSyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Sync Complete", LogStatus::Completed, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Message ID", '', i95SyncLogEntry."Status ID"::Complete, '', SyncSource::i95);

            i95SyncLogEntry."Error Message" := '';
            i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Sync Complete", LogStatus::Completed, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID"::Complete, SyncSource::i95);
            i95SyncLogEntry.SetSourceRecordID(SourceRecordID);
            i95SyncLogEntry.UpdateDataStatus(DataStatus::"Data Updated");
        end else
            i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"No Response", LogStatus::Cancelled, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);
    end;

    procedure UpdateReccuretoken()
    var
        i95DevSetup: Record "i95 Setup";
        InputJsonObject: JsonObject;
        SchedulerIDTxt: Text;
        IsConfigurationUpdated: Boolean;
        RefreshToken: Text;
        Accesstoken: Text;
        RefreshExpiretime: Text;
        AccessExpiretime: Text;
        Refreshtokenoutstream: OutStream;
        AccesstokenOutstream: OutStream;
        result: Boolean;
        Day: Integer;
        Month: Integer;
        Year: Integer;
        Day1: Integer;
        Month1: Integer;
        Year1: Integer;
        RefreshDate: Date;
        AccessDate: Date;
        Refreshtime: Time;
        Accesstime: Time;
        hours: Integer;
        mins: Integer;
        Secs: Integer;
        hours1: Integer;
        mins1: Integer;
        Secs1: Integer;
        RefreshTimeformat: Time;
        AccessTimeformat: Time;
        Varaible: Text;
        AccesstokenExpireDateTime: DateTime;
        RefreshtokenExpireDateTime: DateTime;

    begin
        ResultDataJsonArray := i95WebserviceExecuteCU.GetResultDataJsonArray();
        InputJsonObject := i95WebserviceExecuteCU.GetResultDataJsonObject();


        result := i95WebServiceExecuteCU.ProcessJsonTokenasBoolean('result', InputJsonObject);

        if InputJsonObject.Contains('accessToken') then begin
            InputJsonObject.get('accessToken', ResultDataJsonToken);
            // ResultDataJsonArray := ResultDataJsonToken.AsArray();
            // foreach ResultDataJsonToken in ResultDataJsonArray do begin
            ResultDataJsonObject := ResultDataJsonToken.AsObject();
            Accesstoken := i95WebServiceExecuteCU.ProcessJsonTokenasText('token', ResultDataJsonObject);
            AccessExpiretime := i95WebServiceExecuteCU.ProcessJsonTokenasText('expiryTime', ResultDataJsonObject);
            // end;
        end;
        Clear(ResultDataJsonObject);
        Clear(ResultDataJsonArray);
        Clear(ResultDataJsonToken);

        if InputJsonObject.Contains('refreshToken') then begin
            InputJsonObject.get('refreshToken', ResultDataJsonToken);
            //ResultDataJsonArray := ResultDataJsonToken.AsArray();

            //foreach ResultDataJsonToken in ResultDataJsonArray do begin
            ResultDataJsonObject := ResultDataJsonToken.AsObject();
            RefreshToken := i95WebServiceExecuteCU.ProcessJsonTokenasText('token', ResultDataJsonObject);
            RefreshExpiretime := i95WebServiceExecuteCU.ProcessJsonTokenasText('expiryTime', ResultDataJsonObject);
            // end;
        end;
        Clear(Day);
        Clear(Month);
        Clear(Year);
        Clear(Day1);
        Clear(Month1);
        Clear(Year1);
        Clear(Secs);
        Clear(mins);
        Clear(hours);
        Clear(Secs1);
        Clear(mins1);
        Clear(hours1);


        If strlen(RefreshExpiretime) >= 10 then begin
            Evaluate(RefreshTimeformat, CopyStr(RefreshExpiretime, 12, 8));
            Evaluate(Secs, CopyStr(RefreshExpiretime, 18, 2));
            Evaluate(mins, CopyStr(RefreshExpiretime, 15, 2));
            Evaluate(hours, CopyStr(RefreshExpiretime, 12, 2));
            evaluate(Day, CopyStr(RefreshExpiretime, 9, 2));
            evaluate(Month, CopyStr(RefreshExpiretime, 6, 2));
            evaluate(Year, CopyStr(RefreshExpiretime, 1, 4));
            RefreshDate := DMY2Date(Day, Month, Year);
            RefreshtokenExpireDateTime := CreateDateTime(RefreshDate, RefreshTimeformat);
        end;

        If strlen(AccessExpiretime) >= 10 then begin
            Evaluate(AccessTimeformat, CopyStr(AccessExpiretime, 12, 8));
            Evaluate(Secs1, CopyStr(AccessExpiretime, 18, 2));
            Evaluate(mins1, CopyStr(AccessExpiretime, 15, 2));
            Evaluate(hours1, CopyStr(AccessExpiretime, 12, 2));
            evaluate(Day1, CopyStr(AccessExpiretime, 9, 2));
            evaluate(Month1, CopyStr(AccessExpiretime, 6, 2));
            evaluate(Year1, CopyStr(AccessExpiretime, 1, 4));
            AccessDate := DMY2Date(Day1, Month1, Year1);

            AccesstokenExpireDateTime := CreateDateTime(AccessDate, AccessTimeformat);

        end;

        iF result = true then begin
            clear(SourceRecordID);

            i95DevSetup.FindSet();
            i95DevSetup.Refreshtoken.CreateOutStream(Refreshtokenoutstream, TextEncoding::Windows);
            Refreshtokenoutstream.WriteText(RefreshToken);
            i95DevSetup.Modify();
            /* i95DevSetup.accesstoken.CreateOutStream(AccesstokenOutstream, TextEncoding::Windows);
             AccesstokenOutstream.WriteText('Bearer' + Accesstoken);*/

            i95DevSetup.Authorization.CreateOutStream(AccesstokenOutstream, TextEncoding::Windows);
            Varaible := 'Bearer ';
            AccesstokenOutstream.WriteText(Varaible + Accesstoken);
            i95DevSetup.Modify();

            i95DevSetup.accesstokenExpirytime := AccesstokenExpireDateTime;
            i95DevSetup.RefreshtokenExpirytime := RefreshtokenExpireDateTime;
            i95DevSetup.Refreshtokentime := RefreshTimeformat;
            i95DevSetup.accesstokentime := AccessTimeformat;
            i95DevSetup.accesstokendate := AccessDate;
            i95DevSetup.Refreshtokendate := RefreshDate;
            i95DevSetup.Modify(false);
            SourceRecordID := i95DevSetup.RecordId();


            DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::SchedulerID, SyncStatus::"Waiting for Response", LogStatus::New, SyncSource::i95, i95SyncLogEntryNo, i95DevSetup."Schedular ID", '', '', i95DevSetup.RecordId(), Database::"i95 Setup");
            DetailedSyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Sync Complete", LogStatus::Completed, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Message ID", '', i95SyncLogEntry."Status ID"::Complete, '', SyncSource::i95);

            i95SyncLogEntry."Error Message" := '';
            i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Sync Complete", LogStatus::Completed, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID"::Complete, SyncSource::i95);
            i95SyncLogEntry.SetSourceRecordID(SourceRecordID);
            i95SyncLogEntry.UpdateDataStatus(DataStatus::"Data Updated");
        end else
            i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"No Response", LogStatus::Cancelled, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);
    end;

    procedure UpdateEntityManagement()
    var
        EntityMapping: Record "i95 Entity Mapping";
        InputJsonObject: JsonObject;
        Entityid: Integer;
        EntityName: Text;
        IsInboundActive: Boolean;
        IsOutboundActive: Boolean;
    begin
        ResultDataJsonArray := i95WebserviceExecuteCU.GetResultDataJsonArray();
        ResultJsonToken := i95WebserviceExecuteCU.GetResultJsonToken();
        ResultDataJsonToken := i95WebserviceExecuteCU.GetResultDataJsonToken();
        ResultDataJsonObject := i95WebserviceExecuteCU.GetResultDataJsonObject();

        foreach ResultDataJsonToken in ResultDataJsonArray do begin
            ResultDataJsonObject := ResultDataJsonToken.AsObject();
            Clear(Entityid);
            Clear(EntityName);
            Clear(IsInboundActive);
            Clear(IsOutboundActive);

            Entityid := i95WebserviceExecuteCU.ProcessJsonTokenasInteger('EntityId', ResultDataJsonObject);
            EntityName := i95WebserviceExecuteCU.ProcessJsonTokenasText('EntityName', ResultDataJsonObject);
            IsInboundActive := i95WebserviceExecuteCU.ProcessJsonTokenasBoolean('IsInboundActive', ResultDataJsonObject);
            IsOutboundActive := i95WebserviceExecuteCU.ProcessJsonTokenasBoolean('IsOutboundActive', ResultDataJsonObject);

            IF EntityMapping.FindSet() then
                EntityMapping.Delete();

            EntityMapping."Primary Key" := 'P';
            IF not EntityMapping.FindFirst() then
                EntityMapping.Insert(false);
            IF Entityid = 1 then begin
                EntityMapping."Allow Product Oubound Sync" := IsOutboundActive;
                EntityMapping."Allow Product Inbound Sync" := IsInboundActive;
            end else
                If Entityid = 2 then
                    EntityMapping."Allow Inventory Oubound Sync" := IsOutboundActive
                else
                    if Entityid = 3 then begin
                        EntityMapping."Allow CustGroup Outbound Sync" := IsOutboundActive;
                        EntityMapping."Allow CustGroup inbound Sync" := IsInboundActive;
                    end else
                        IF Entityid = 5 then
                            EntityMapping."Allow Tier Prices Oubound Sync" := IsOutboundActive
                        else
                            IF Entityid = 6 then begin
                                EntityMapping."Allow Customer Oubound Sync" := IsOutboundActive;
                                EntityMapping."Allow Customer Inbound Sync" := IsInboundActive;
                            end else
                                IF Entityid = 7 then begin
                                    EntityMapping."Allow SalesOrder Oubound Sync" := IsOutboundActive;
                                    EntityMapping."Allow SalesOrder Inbound Sync" := IsInboundActive;
                                end else
                                    IF Entityid = 8 then begin
                                        EntityMapping."Allow Shipment Oubound Sync" := IsOutboundActive;
                                        EntityMapping."Allow Shipment inbound Sync" := IsInboundActive;
                                    end else
                                        IF Entityid = 9 then begin
                                            EntityMapping."Allow Invoice Oubound Sync" := IsOutboundActive;
                                            EntityMapping."Allow Invoice inbound Sync" := IsInboundActive;
                                        end else
                                            IF Entityid = 15 then begin
                                                EntityMapping."Allow ESalesOrder Oubound Sync" := IsOutboundActive;
                                            end else
                                                IF Entityid = 16 then begin
                                                    EntityMapping."Allow CustDiscG Oubound Sync" := IsOutboundActive;
                                                    EntityMapping."Allow CustDiscG Inbound Sync" := IsInboundActive;
                                                end else
                                                    IF Entityid = 17 then begin
                                                        EntityMapping."Allow ItemDiscG Oubound Sync" := IsOutboundActive;
                                                        EntityMapping."Allow ItemDiscG Inbound Sync" := IsInboundActive;
                                                    end else
                                                        IF Entityid = 18 then begin
                                                            EntityMapping."Allow DiscPrice Oubound Sync" := IsOutboundActive;
                                                            EntityMapping."Allow DiscPrice Inbound Sync" := IsInboundActive;
                                                        end else
                                                            if Entityid = 19 then begin
                                                                entityMapping."Allow SalesQuote Inbound Sync" := IsInboundActive;
                                                                EntityMapping."Allow SalesQuote Outbound Sync" := IsOutboundActive;
                                                            end else
                                                                IF Entityid = 20 then
                                                                    EntityMapping."Allow ItemVar Oubound Sync" := IsOutboundActive
                                                                else
                                                                    if Entityid = 24 then
                                                                        EntityMapping."Allow CancelOrder Oubound Sync" := IsOutboundActive
                                                                    else
                                                                        if Entityid = 40 then begin
                                                                            EntityMapping."Allow TaxBusPosG Oubound Sync" := IsOutboundActive;
                                                                            EntityMapping."Allow TaxBusPosG Inbound Sync" := IsInboundActive;
                                                                        end else
                                                                            if Entityid = 41 then begin
                                                                                entityMapping."Allow TaxProdPosG Oubound Sync" := IsOutboundActive;
                                                                                EntityMapping."Allow TaxProdPosG Inbound Sync" := IsInboundActive;
                                                                            end else
                                                                                if Entityid = 27 then begin
                                                                                    entityMapping."Allow CashReci Outbound Sync" := IsOutboundActive;
                                                                                    EntityMapping."Allow CashReci Inputbound Sync" := IsInboundActive;
                                                                                end else
                                                                                    if Entityid = 42 then begin
                                                                                        entityMapping."Allow TaxPossetup Oubound Sync" := IsOutboundActive;
                                                                                        EntityMapping."Allow TaxPossetup Inbound Sync" := IsInboundActive;
                                                                                    end else
                                                                                        if Entityid = 43 then begin
                                                                                            EntityMapping."Allow CLimit Outbound Sync" := IsOutboundActive;
                                                                                            EntityMapping."Allow CLimit Inputbound Sync" := IsInboundActive;
                                                                                        end else
                                                                                            if Entityid = 14 then begin
                                                                                                entityMapping."Allow PaymentTerm Oubound Sync" := IsOutboundActive;
                                                                                                EntityMapping."Allow PaymentTerm Inbound Sync" := IsInboundActive;
                                                                                            end else
                                                                                                if Entityid = 37 then begin
                                                                                                    EntityMapping."Allow CanceQuote Outbound Sync" := IsOutboundActive;
                                                                                                    EntityMapping."Allow CanceQuote Inbound Sync" := IsInboundActive;
                                                                                                end else
                                                                                                    IF Entityid = 28 then begin
                                                                                                        EntityMapping."Allow Financecharge Ob Sync" := IsOutboundActive;
                                                                                                        EntityMapping."Allow Financecharge Ib Sync" := IsInboundActive;
                                                                                                    end else
                                                                                                        IF Entityid = 26 then begin
                                                                                                            EntityMapping."Allow AcountRecievable Ib Sync" := IsInboundActive;
                                                                                                            EntityMapping."Allow AcountRecievable Ob Sync" := IsOutboundActive;
                                                                                                        end;



            SourceRecordID := EntityMapping.RecordId();
            EntityMapping.Modify(false);
        end;

        DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::EntityManagement, SyncStatus::"Waiting for Response", LogStatus::New, SyncSource::i95, i95SyncLogEntryNo, '', '', '', EntityMapping.RecordId, Database::"i95 Entity Mapping");

        i95SyncLogEntry."Error Message" := '';
        i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Waiting for Response", LogStatus::"In-Progress", i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID"::Complete, SyncSource::i95);
        i95SyncLogEntry.SetSourceRecordID(SourceRecordID);
        i95SyncLogEntry.UpdateDataStatus(DataStatus::"Data Updated");

        //i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"No Response", LogStatus::Cancelled, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);

    end;

    procedure UpdatecashRecieptJournal()
    var
        InputJsonObject: JsonObject;
        aRPostedInvoiceObject: JsonObject;
        aRPostedInvoiceArray: JsonArray;
        aRPostedInvoiceToken: JsonToken;
        receiptAppliedAmountL: Decimal;
        paymentJournalId: Code[50];
        targetInvoiceId: Code[50];
        sourceInvoiceId: Code[50];
        sourceOrderId: Code[50];
        GeneralJournalLine: Record "Gen. Journal Line";
        SalesinvoiceHeader: Record "Sales Invoice Header";
        CurrentJnlBatchName: Text;
        CashRecieptJournal: Page "Cash Receipt Journal";
        ApplyCustEntries: Page "Applied Customer Entries";
        CustLedgEntry: Record "Cust. Ledger Entry";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlTemplate: Record "Gen. Journal Template";
        NoSeriesMgt: Codeunit NoSeriesManagement;

    begin
        i95Setup.Get();
        i95Setup.TestField("I95 Default Template Name");
        i95Setup.TestField("I95 Default Batch Name");
        ResultDataJsonArray := i95WebserviceExecuteCU.GetResultDataJsonArray();
        ResultJsonToken := i95WebserviceExecuteCU.GetResultJsonToken();
        ResultDataJsonToken := i95WebserviceExecuteCU.GetResultDataJsonToken();
        ResultDataJsonObject := i95WebserviceExecuteCU.GetResultDataJsonObject();

        foreach ResultDataJsonToken in ResultDataJsonArray do begin
            ResultDataJsonObject := ResultDataJsonToken.AsObject();
            Clear(paymentJournalId);
            Clear(targetInvoiceId);
            Clear(sourceInvoiceId);
            Clear(sourceOrderId);

            if ResultDataJsonObject.Contains('inputData') then begin
                ResultDataJsonObject.get('inputData', ResultDataJsonToken);
                ResultDataJsonObject := ResultDataJsonToken.AsObject();

                paymentJournalId := i95WebserviceExecuteCU.ProcessJsonTokenasCode('sourcePaymentJournalId', ResultDataJsonObject);
                targetInvoiceId := i95WebserviceExecuteCU.ProcessJsonTokenasCode('targetInvoiceId', ResultDataJsonObject);
                sourceInvoiceId := i95WebserviceExecuteCU.ProcessJsonTokenasCode('sourceInvoiceId', ResultDataJsonObject);
                sourceOrderId := i95WebserviceExecuteCU.ProcessJsonTokenascode('sourceOrderId', ResultDataJsonObject);

                i95Setup.Get();
                IF i95Setup."i95 Enable BillPay" = true then begin
                    if ResultDataJsonObject.Contains('aRPostedInvoice') then begin
                        ResultDataJsonObject.get('aRPostedInvoice', aRPostedInvoiceToken);
                        aRPostedInvoiceArray := aRPostedInvoiceToken.AsArray();

                        Clear(paymentJournalId);
                        Clear(targetInvoiceId);
                        Clear(sourceOrderId);
                        Clear(receiptAppliedAmountL);

                        foreach aRPostedInvoiceToken in aRPostedInvoiceArray do begin
                            aRPostedInvoiceObject := aRPostedInvoiceToken.AsObject();

                            paymentJournalId := i95WebserviceExecuteCU.ProcessJsonTokenasCode('receiptDocumentNumber', aRPostedInvoiceObject);
                            targetInvoiceId := i95WebserviceExecuteCU.ProcessJsonTokenasCode('appliedDocumentNumber', aRPostedInvoiceObject);
                            //sourceInvoiceId := i95WebserviceExecuteCU.ProcessJsonTokenasCode('sourceInvoiceId', aRPostedInvoiceObject);
                            sourceOrderId := i95WebserviceExecuteCU.ProcessJsonTokenascode('targetOrderId', aRPostedInvoiceObject);
                            receiptAppliedAmountL := i95WebServiceExecuteCU.ProcessJsonTokenasDecimal('receiptAppliedAmount', aRPostedInvoiceObject);
                        end;
                    end;
                end;
                GeneralJournalLine.Init();
                GeneralJournalLine.Validate("Journal Template Name", i95Setup."I95 Default Template Name");
                GeneralJournalLine.Validate("Journal Batch Name", i95Setup."I95 Default Batch Name");
                GeneralJournalLine.SetRange("Journal Template Name", i95Setup."I95 Default Template Name");
                GeneralJournalLine.SetRange("Journal Batch Name", i95Setup."I95 Default Batch Name");
                IF GeneralJournalLine.FindLast() then begin
                    GeneralJournalLine."Line No." := GeneralJournalLine."Line No." + 10000;
                    IF i95SyncLogEntry."API Type" = i95SyncLogEntry."API Type"::AccountRecievable then
                        GeneralJournalLine."Document No." := targetInvoiceId
                    else
                        GeneralJournalLine."Document No." := GeneralJournalLine."Document No.";

                    IF i95SyncLogEntry."API Type" = i95SyncLogEntry."API Type"::PaymentJournal then
                        GeneralJournalLine.IncrementDocumentNo(GenJnlBatch, GeneralJournalLine."Document No.");

                end else begin
                    GeneralJournalLine."Line No." := 10000;
                    GenJnlTemplate.GET(i95Setup."I95 Default Template Name");
                    GenJnlBatch.GET(i95Setup."I95 Default Template Name", i95Setup."I95 Default Batch Name");
                    IF i95SyncLogEntry."API Type" = i95SyncLogEntry."API Type"::AccountRecievable then
                        GeneralJournalLine."Document No." := targetInvoiceId
                    else
                        GeneralJournalLine."Document No." := NoSeriesMgt.TryGetNextNo(GenJnlBatch."No. Series", WorkDate());
                end;

                GeneralJournalLine.Validate("Posting Date", WorkDate);
                GeneralJournalLine.Validate("Document Type", GeneralJournalLine."Document Type"::Payment);
                GeneralJournalLine.Validate("Account Type", GeneralJournalLine."Account Type"::Customer);


                SalesinvoiceHeader.Reset();
                SalesinvoiceHeader.SetRange("No.", targetInvoiceId);
                IF SalesinvoiceHeader.FindSet() then;
                GeneralJournalLine.Validate("Account No.", SalesinvoiceHeader."Sell-to Customer No.");

                GenJnlBatch.GET(i95Setup."I95 Default Template Name", i95Setup."I95 Default Batch Name");
                GeneralJournalLine.Validate("Bal. Account Type", GenJnlBatch."Bal. Account Type");
                GeneralJournalLine.Validate("Bal. Account No.", GenJnlBatch."Bal. Account No.");

                GeneralJournalLine.Validate("Applies-to Doc. Type", GeneralJournalLine."Applies-to Doc. Type"::Invoice);
                GeneralJournalLine.Validate("Applies-to Doc. No.", targetInvoiceId);
                GeneralJournalLine.Validate("i95 Reference ID", paymentJournalId);
                i95Setup.Get();
                IF not (receiptAppliedAmountL <> 0) then begin
                    CustLedgEntry.Reset();
                    CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
                    CustLedgEntry.SetRange("Document No.", targetInvoiceId);
                    CustLedgEntry.SetRange("Customer No.", SalesinvoiceHeader."Sell-to Customer No.");
                    IF CustLedgEntry.FindSet() then begin
                        CustLedgEntry.CalcFields("Remaining Amount");
                        CustLedgEntry.CalcFields("Remaining Amt. (LCY)");
                        GeneralJournalLine.validate(Amount, -CustLedgEntry."Remaining Amount");
                        GeneralJournalLine.Validate("Amount (LCY)", -CustLedgEntry."Remaining Amt. (LCY)");
                    end;
                end else begin
                    GeneralJournalLine.validate(Amount, -receiptAppliedAmountL);
                    GeneralJournalLine.Validate("Amount (LCY)", -receiptAppliedAmountL);

                end;

                GeneralJournalLine.Insert(false);

                IF i95SyncLogEntry."API Type" = i95SyncLogEntry."API Type"::PaymentJournal then
                    DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::PaymentJournal, SyncStatus::"Waiting for Response", LogStatus::New, SyncSource::i95, i95SyncLogEntryNo, '', '', '', GeneralJournalLine.RecordId, Database::"Gen. Journal Line")
                else begin
                    if i95SyncLogEntry."API Type" = i95SyncLogEntry."API Type"::AccountRecievable then
                        DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::AccountRecievable, SyncStatus::"Waiting for Response", LogStatus::New, SyncSource::i95, i95SyncLogEntryNo, '', '', '', GeneralJournalLine.RecordId, Database::"Gen. Journal Line")
                end;
            end;
        end;


        i95SyncLogEntry."Error Message" := '';
        i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Waiting for Response", LogStatus::"In-Progress", i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID"::Complete, SyncSource::i95);
        i95SyncLogEntry.SetSourceRecordID(SourceRecordID);
        i95SyncLogEntry.UpdateDataStatus(DataStatus::"Data Updated");
        If targetInvoiceId = '' then
            i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"No Response", LogStatus::Cancelled, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);

    end;

    Procedure UpdateProductAttributes()
    var
        InputJsonObject: JsonObject;
        ErpAttribute: text[50];
        EcommerceAttribute: text[50];
        IsEcommerceDefault: Boolean;
        IsErpDefault: Boolean;
        ProductAttributeMapping: Record "i95 Product Attribute Mapping";
        EcommerceJsonObject: JsonObject;
        EcommerceJsonToken: JsonToken;
        EcommerceDataJsonArray: JsonArray;
        EcommerceDataJsonToken: JsonToken;
        ErpJsonObject: JsonObject;
        ErpJsonToken: JsonToken;
        ErpDataJsonArray: JsonArray;
        ErpDataJsonToken: JsonToken;
    Begin
        ResultDataJsonArray := i95WebserviceExecuteCU.GetResultDataJsonArray();
        ResultJsonToken := i95WebserviceExecuteCU.GetResultJsonToken();
        ResultDataJsonToken := i95WebserviceExecuteCU.GetResultDataJsonToken();
        ResultDataJsonObject := i95WebserviceExecuteCU.GetResultDataJsonObject();

        IF ProductAttributeMapping.FindSet() then
            ProductAttributeMapping.DeleteAll();

        foreach ResultDataJsonToken in ResultDataJsonArray do begin
            ResultDataJsonObject := ResultDataJsonToken.AsObject();
            Clear(ErpAttribute);
            Clear(EcommerceAttribute);
            Clear(IsEcommerceDefault);
            Clear(IsErpDefault);

            /* if ResultDataJsonObject.Contains('ecommerce') then begin
                 ResultDataJsonObject.get('ecommerce', EcommerceJsonToken);
                 //EcommerceDataJsonArray := EcommerceJsonToken.AsArray();
                 EcommerceJsonObject := EcommerceJsonToken.AsObject();
                 EcommerceAttribute := i95WebserviceExecuteCU.ProcessJsonTokenasText('name', EcommerceJsonObject);
             end;

             if ResultDataJsonObject.Contains('erp') then begin
                 ResultDataJsonObject.get('erp', ErpJsonToken);
                 // ErpDataJsonArray := ErpJsonToken.AsArray();
                 // foreach ErpDataJsonToken in ErpDataJsonArray do begin
                 ErpJsonObject := ErpJsonToken.AsObject();
                 ErpAttribute := i95WebserviceExecuteCU.ProcessJsonTokenasText('name', ErpJsonObject);
             end;*/
            EcommerceAttribute := i95WebserviceExecuteCU.ProcessJsonTokenasText('ecommerceAttributeName', ResultDataJsonObject);
            ErpAttribute := i95WebserviceExecuteCU.ProcessJsonTokenasText('erpAttributeName', ResultDataJsonObject);


            /*EcommerceAttribute := i95WebserviceExecuteCU.ProcessJsonTokenasCode('EcommerceMethod', ResultDataJsonObject);
            ErpAttribute := i95WebserviceExecuteCU.ProcessJsonTokenasCode('ErpMethod', ResultDataJsonObject);
            IsEcommerceDefault := i95WebserviceExecuteCU.ProcessJsonTokenasBoolean('IsEcommerceDefault', ResultDataJsonObject);
            IsErpDefault := i95WebserviceExecuteCU.ProcessJsonTokenasBoolean('IsErpDefault', ResultDataJsonObject);*/



            ProductAttributeMapping.Reset();
            ProductAttributeMapping.SetCurrentKey("Entry No");

            ProductAttributeMapping.Init();
            IF ProductAttributeMapping.FindLast() then
                ProductAttributeMapping."Entry No" := ProductAttributeMapping."Entry No" + 1
            else
                ProductAttributeMapping."Entry No" := 1;

            ProductAttributeMapping.SetRange(BCAttribute, ErpAttribute);
            IF ProductAttributeMapping.FindFirst() then begin
                ProductAttributeMapping.BCAttribute := ErpAttribute;
                ProductAttributeMapping.MagentoAttribute := EcommerceAttribute;

                // ProductAttributeMapping.IsEcommerceDefault := IsEcommerceDefault;
                //ProductAttributeMapping.IsErpDefault := IsErpDefault;
                ProductAttributeMapping.Modify();
            end else begin
                ProductAttributeMapping.BCAttribute := ErpAttribute;
                ProductAttributeMapping.MagentoAttribute := EcommerceAttribute;
                ProductAttributeMapping.Insert();
            end;


        end;

        DetailedSyncLogEntry.InsertDetailSyncLogEntry(APIType::ProductAttributeMapping, SyncStatus::"Sync Complete", LogStatus::Completed, SyncSource::i95, i95SyncLogEntryNo, '', '', '', ProductAttributeMapping.RecordId, Database::"i95 Product Attribute Mapping");

        i95SyncLogEntry."Error Message" := '';
        i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Sync Complete", LogStatus::Completed, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID"::Complete, SyncSource::i95);
        i95SyncLogEntry.SetSourceRecordID(SourceRecordID);
        i95SyncLogEntry.UpdateDataStatus(DataStatus::"Data Updated");

    End;


    var
        i95SyncLogEntry: Record "i95 Sync Log Entry";
        i95Setup: Record "i95 Setup";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        DetailedSyncLogEntry: Record "i95 Detailed Sync Log Entry";
        i95WebServiceExecuteCU: Codeunit "i95 Webservice Execute";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        SourceRecordID: RecordId;
        SecSourceRecordID: RecordId;
        WebServiceJsonObject: JsonObject;
        ResultDataJsonArray: JsonArray;
        ResultJsonToken: JsonToken;
        ResultDataJsonToken: JsonToken;
        ResultDataJsonObject: JsonObject;
        MessageID: Integer;
        SourceID: code[20];
        StatusID: Option "Request Received","Request Inprocess","Error","Response Received","Response Transferred","Complete";
        APIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerID,ReaccureToken;
        SyncStatus: Option "Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete","No Response";
        LogStatus: Option " ",New,"In-Progress",Completed,Error,Cancelled;
        SyncSource: Option "","Business Central",i95;
        SalesInputDataJsonArray: JsonArray;
        SalesInputJsonToken: JsonToken;
        SalesInputDataJsonToken: JsonToken;
        SalesInputDataJsonObject: JsonObject;
        SOAddressJsonObject: JsonObject;
        SalesLineInputDataJsonArray: JsonArray;
        SalesLineInputDataJsonToken: JsonToken;
        SalesLineInputDataJsonObject: JsonObject;
        PaymentInputDataJsonarray: JsonArray;
        PaymentInputDataJsonToken: JsonToken;
        PaymentInputDataJsonObject: JsonObject;
        DiscountAmountInputDataJsonArray: JsonArray;
        DiscountAmountInputDataJsonToken: JsonToken;
        DiscountAmountInputDataJsonObject: JsonObject;
        LineNo: Integer;
        ItemNo: code[20];
        ItemPrice: Decimal;
        QuantityOrdered: Decimal;
        SpecialPrice: Decimal;
        LineDiscountAmount: Decimal;
        TargetId: code[20];
        DataStatus: Option "","Data Received","Data Updated";
        i95SyncLogEntryNo: Integer;
        APIDatatoRead: Option "i95 Sync Request","i95 Sync Result","i95 Response Request","i95 Response Result","i95 Acknowledgement Request","i95 Acknowledgement Result";
        HttpReasonCode: text[100];
        ResponseResultText: Text[30];
        ResponseMessageText: Text[100];
        RetailVariantId: Code[20];
        ParentSku: Code[20];
        UpdateProduct: Codeunit "i95 Update Product";
        UpdateCustomer: Codeunit "i95 Update Customer";
        UpdateSalesOrder: Codeunit "I95 Update Sales Order";
        UpdateProductwithMappingG: Codeunit "I95 UpdateProductWithMapping";
        UpdateSalesquoteG: Codeunit "i95 Update SalesQuote";
        UpdateSalesreturnOrder: Codeunit "I95 Update SalesReturn Order";
        SalesHeader: Record "Sales Header";
        SalesOrderNo: Code[20];
        ContactNo: Code[20];

}