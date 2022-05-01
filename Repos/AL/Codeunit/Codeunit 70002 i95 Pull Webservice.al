codeunit 70002 "i95 Pull Webservice"
{

    procedure ProcessPullData(CurrentAPIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerID,ReaccureToken; SchedularTypeP: Option PushDatas,PullData)
    var
        i95ProcessPulledDataCU: Codeunit "i95 Process Pulled Data";
        BodyContent: Text;
    begin
        Clear(i95WebserviceExecuteCU);
        clear(SyncLogEntryNo);
        clear(APILogEntryNo);
        i95Setup.get();
        Checki95SetupData();

        SyncLogEntryNo := i95SyncLogEntry.InsertSyncLogEntry(CurrentAPIType, SyncStatus::"Waiting for Sync", LogStatus::New, SyncSource::i95);
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, CurrentAPIType, SchedulerType::PullData, SyncSource::i95);

        IF CurrentAPIType = CurrentAPIType::ReaccureToken then
            CreateBodyContent.RefreshTokenpullData(BodyContent, 'PullData')
        else
            if SchedularTypeP = SchedularTypeP::PushDatas then begin
                CreateBodyContent.AddContextHeader(BodyContent, 'PushDatas');
            end else
                IF SchedularTypeP = SchedularTypeP::PullData then begin
                    CreateBodyContent.AddContextHeader(BodyContent, 'PullData');
                end;

        CreateBodyContent.AddContextFooter(BodyContent);

        i95SyncLogEntry.reset();
        if i95SyncLogEntry.get(SyncLogEntryNo) then;
        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        i95SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Sync Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        commit();

        i95WebserviceExecuteCU.GetAPIUrl(CurrentAPIType, SchedulerType::PullData);
        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        case CurrentAPIType of
            CurrentAPIType::Customer:
                PullDataSource := PullDataSource::Customer;
            CurrentAPIType::CustomerGroup:
                PullDataSource := PullDataSource::CustomerGroup;
            CurrentAPIType::SalesOrder:
                PullDataSource := PullDataSource::SalesOrder;
            CurrentAPIType::Product:
                PullDataSource := PullDataSource::Product;
            CurrentAPIType::EntityManagement:
                PullDataSource := PullDataSource::EntityManagement;
            CurrentAPIType::SchedulerID:
                PullDataSource := PullDataSource::SchedulerID;
            CurrentAPIType::PaymentJournal:
                PullDataSource := PullDataSource::PaymentJournal;
            CurrentAPIType::SalesQuote:
                PullDataSource := PullDataSource::SalesQuote;
            CurrentAPIType::AccountRecievable:
                PullDataSource := PullDataSource::AccountRecievable;
            CurrentAPIType::ReaccureToken:
                PullDataSource := PullDataSource::ReaccureToken;
            CurrentAPIType::SalesReturn:
                PullDataSource := PullDataSource::SalesReturn;
            CurrentAPIType::ProductAttributeMapping:
                PullDataSource := PullDataSource::ProductAttributeMapping;
        end;

        i95WebserviceExecuteCU.SetPullDataSource(PullDataSource);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Sync", LogStatus::"In Progress", CurrentAPIType);

        if CurrentAPIType = CurrentAPIType::SchedulerID then begin
            Commit();
            i95ProcessPulledDataCU.SetParamaters(SyncLogEntryNo);
            if i95ProcessPulledDataCU.Run() then;
        end;
        if (CurrentAPIType = CurrentAPIType::ReaccureToken) then begin
            Commit();
            i95ProcessPulledDataCU.SetParamaters(SyncLogEntryNo);
            if i95ProcessPulledDataCU.Run() then;
        end;

    end;

    procedure ProcessPushResponse(CurrentAPIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerID,ReaccureToken)
    var
        Customer: Record Customer;
        CustomerPriceGroup: Record "Customer Price Group";
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        BodyContent: Text;
        EntityMapping: Record "i95 Entity Mapping";
        GeneralJournalLine: Record "Gen. Journal Line";
    begin
        Clear(i95WebserviceExecuteCU);
        i95Setup.get();
        Checki95SetupData();

        i95WebserviceExecuteCU.GetAPIUrl(CurrentAPIType, SchedulerType::PushResponse);
        APILogEntryNo := APILogEntry.InsertApiCallLogEntry(SyncLogEntryNo, CurrentAPIType, SchedulerType::PushResponse, SyncSource::i95);

        i95SyncLogEntry.reset();
        if i95SyncLogEntry.get(SyncLogEntryNo) then;

        CreateBodyContent.AddContextHeader(BodyContent, 'PushResponse');
        DetailedSyncLogEntry.Reset();
        DetailedSyncLogEntry.SetCurrentKey("API Type", "Sync Log Entry No", "Sync Status");
        DetailedSyncLogEntry.SetRange("API Type", CurrentAPIType);
        DetailedSyncLogEntry.SetRange("Sync Log Entry No", i95SyncLogEntry."Entry No");
        if DetailedSyncLogEntry.FindSet() then
            repeat
                case CurrentAPIType of
                    currentAPIType::Customer:
                        begin
                            IF not (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then begin
                                if Customer.get(DetailedSyncLogEntry."Source Record ID") then
                                    CreateBodyContent.CustomerPushResponseData(Customer, BodyContent, DetailedSyncLogEntry);
                            end else
                                CreateBodyContent.CustomerPushResponseData(Customer, BodyContent, DetailedSyncLogEntry);
                        end;
                    CurrentAPIType::CustomerGroup:
                        if CustomerPriceGroup.get(DetailedSyncLogEntry."Source Record ID") then
                            CreateBodyContent.CustomerPrieGroupPushResponseData(CustomerPriceGroup, BodyContent, DetailedSyncLogEntry);
                    CurrentAPIType::SalesOrder:
                        begin
                            IF not (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then begin
                                If SalesHeader.get(DetailedSyncLogEntry."Source Record ID") then
                                    CreateBodyContent.SalesOrderPushResponseData(SalesHeader, BodyContent, DetailedSyncLogEntry);
                            end else
                                CreateBodyContent.SalesOrderPushResponseData(SalesHeader, BodyContent, DetailedSyncLogEntry);
                        end;
                    CurrentAPIType::Product:
                        begin
                            IF not (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then begin
                                If Item.get(DetailedSyncLogEntry."Source Record ID") then
                                    CreateBodyContent.ProductPushResponseData(Item, BodyContent, DetailedSyncLogEntry);
                            end else
                                CreateBodyContent.ProductPushResponseData(Item, BodyContent, DetailedSyncLogEntry);
                        end;
                    CurrentAPIType::EntityManagement:
                        begin
                            CreateBodyContent.EntityManagementPushAck(EntityMapping, BodyContent, DetailedSyncLogEntry);
                        end;
                    CurrentAPIType::PaymentJournal, CurrentAPIType::AccountRecievable:
                        begin
                            IF not (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then begin
                                If GeneralJournalLine.get(DetailedSyncLogEntry."Source Record ID") then
                                    CreateBodyContent.CashRecieptPushResponseData(GeneralJournalLine, BodyContent, DetailedSyncLogEntry);
                            end else
                                CreateBodyContent.CashRecieptPushResponseData(GeneralJournalLine, BodyContent, DetailedSyncLogEntry);
                        end;
                    CurrentAPIType::SalesQuote:
                        begin
                            IF not (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then begin
                                If SalesHeader.get(DetailedSyncLogEntry."Source Record ID") then
                                    CreateBodyContent.SalesQuotePushResponseData(SalesHeader, BodyContent, DetailedSyncLogEntry);
                            end else
                                CreateBodyContent.SalesQuotePushResponseData(SalesHeader, BodyContent, DetailedSyncLogEntry);
                        end;
                    CurrentAPIType::SalesReturn:
                        begin
                            IF not (DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error) then begin
                                If SalesHeader.get(DetailedSyncLogEntry."Source Record ID") then
                                    CreateBodyContent.SalesReturnPushResponseData(SalesHeader, BodyContent, DetailedSyncLogEntry);
                            end else
                                CreateBodyContent.SalesReturnPushResponseData(SalesHeader, BodyContent, DetailedSyncLogEntry);
                        end;

                end;
            Until DetailedSyncLogEntry.Next() = 0;
        CreateBodyContent.AddContextFooter(BodyContent);

        APILogEntry.reset();
        if APILogEntry.get(APILogEntryNo) then;

        i95SyncLogEntry.WriteToBlobField(BodyContent, CalledByAPI::"i95 Response Request");
        APILogEntry.WriteToBlobField(BodyContent, BlobToUpdate::"i95 API Request");
        commit();

        i95WebserviceExecuteCU.SetWebRequestData(BodyContent);

        if TestMode then begin
            i95WebserviceExecuteCU.SetTestMode(true);
            i95WebserviceExecuteCU.SetMockResponseText(TestModeResponseTxt);
        end;

        IF DetailedSyncLogEntry."Log Status" = DetailedSyncLogEntry."Log Status"::Error then
            ExecuteAPIAndUpdateLogs(SyncStatus::"Waiting for Sync", LogStatus::Error, CurrentAPIType)
        else
            ExecuteAPIAndUpdateLogs(SyncStatus::"Sync Complete", LogStatus::Completed, CurrentAPIType);
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

    Procedure ExecuteAPIAndUpdateLogs(CurrentSyncStatus: Integer;
                                    CurrentLogStatus: Option " ",New,"In Progress",Completed,Error;
                                    CurrentAPIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerID,ReaccureToken)
    var
        SourceRecordID: RecordId;
        TargetIDL: Code[20];
        ResultmessageIDL: Integer;
        Result: Boolean;
    begin
        if i95WebserviceExecuteCU.run() then begin
            HttpReasonCode := i95WebserviceExecuteCU.GetResponseStatusCode();
            i95SyncLogEntry."Error Message" := Copystr(ResultDataBlankMsg, 1, 300);

            Clear(Result);
            Result := evaluate(result, i95WebserviceExecuteCU.GetAPIResponseResultText());

            IF not (((CurrentAPIType = CurrentAPIType::EntityManagement) or (CurrentAPIType = CurrentAPIType::ProductAttributeMapping)) and (Result = true) and (i95SyncLogEntry."PullData Status" = i95SyncLogEntry."PullData Status"::"Data Updated")) then
                i95SyncLogEntry.UpdateSyncLogEntry(i95SyncLogEntry."Sync Status", LogStatus::"In Progress", HttpReasonCode, i95WebserviceExecuteCU.GetAPIResponseResultText(),
                                   i95WebserviceExecuteCU.GetAPIResponseMessageText(), i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID",
                                   i95SyncLogEntry."Status ID"::"Response Received", SyncSource::i95)
            else
                i95SyncLogEntry.UpdateSyncLogEntry(i95SyncLogEntry."Sync Status", LogStatus::Completed, HttpReasonCode, i95WebserviceExecuteCU.GetAPIResponseResultText(),
                                        i95WebserviceExecuteCU.GetAPIResponseMessageText(), i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID",
                                        i95SyncLogEntry."Status ID"::"Response Received", SyncSource::i95);


            APILogEntry.UpdateAPILogEntry(HttpReasonCode, copystr(ResultDataBlankMsg, 1, 300));

            MessageID := i95WebserviceExecuteCU.GetResultMessageID();
            SourceID := i95WebserviceExecuteCU.GetSourceID();
            StatusID := i95WebserviceExecuteCU.GetStatusID();


            IF i95SyncLogEntry."Log Status" = i95SyncLogEntry."Log Status"::Error then
                i95SyncLogEntry.WriteToBlobField(i95WebserviceExecuteCU.GetWebServiceResponseJson(), CalledByAPI::"i95 Response Result")
            else begin
                case i95SyncLogEntry."Sync Status" of
                    i95SyncLogEntry."Sync Status"::"Waiting for Sync":
                        i95SyncLogEntry.WriteToBlobField(i95WebserviceExecuteCU.GetWebServiceResponseJson(), CalledByAPI::"i95 Sync Result");
                    i95SyncLogEntry."Sync Status"::"Waiting for Response":
                        i95SyncLogEntry.WriteToBlobField(i95WebserviceExecuteCU.GetWebServiceResponseJson(), CalledByAPI::"i95 Response Result");
                end;
            end;

            APILogEntry.WriteToBlobField(i95WebserviceExecuteCU.GetWebServiceResponseJson(), BlobToUpdate::"i95 API Result");

            i95SyncLogEntry.UpdateDataStatus(DataStatus::"Data Received");

            If (SourceId <> '') or (StatusId <> 0) or (MessageId <> 0) then
                If (i95WebserviceExecuteCU.GetAPIResponseResultText() <> 'false') and (i95WebserviceExecuteCU.GetAPIResponseMessageText() = '') then begin
                    i95SyncLogEntry."Error Message" := '';
                    i95SyncLogEntry.UpdateSyncLogEntry(CurrentSyncStatus, CurrentLogStatus, HttpReasonCode,
                                                    i95WebserviceExecuteCU.GetAPIResponseResultText(), i95WebserviceExecuteCU.GetAPIResponseMessageText(),
                                                    MessageID, SourceID, StatusID, SyncSource::i95);

                    ResultDataJsonArray := i95WebserviceExecuteCU.GetResultDataJsonArray();

                    foreach ResultDataJsonToken in ResultDataJsonArray do begin
                        ResultDataJsonObject := ResultDataJsonToken.AsObject();
                        Clear(ResultmessageIDL);
                        ResultMessageIDL := i95WebserviceExecuteCU.ProcessJsontokenasInteger('messageId', ResultDataJsonObject);

                        if (CurrentSyncStatus <> 0) then begin

                            TargetIDL := i95WebserviceExecuteCU.ProcessJsonTokenasCode('targetId', ResultDataJsonObject);


                            IF TargetIDL <> '' then
                                GetSourceRecordID(SourceRecordID, i95WebserviceExecuteCU.ProcessJsonTokenasCode('targetId', ResultDataJsonObject), CurrentAPIType);

                            Clear(CustomerNo);

                            i95Setup.Get();
                            IF i95Setup."i95 Enable Company" = true then begin
                                ContactG.Reset();
                                ContactG.SetRange("No.", TargetIDL);
                                IF ContactG.FindFirst() then begin
                                    ContactG."i95 Enable Forward Sync" := false;
                                    ContactG.Modify(false);
                                end;
                            end;
                            DetailedSyncLogEntry.Reset();
                            DetailedSyncLogEntry.SetCurrentKey("Sync Log Entry No");
                            DetailedSyncLogEntry.SetRange("Sync Log Entry No", SyncLogEntryNo);
                            DetailedSyncLogEntry.SetRange("Source Record ID", SourceRecordID);
                            IF ResultmessageIDL <> 0 then
                                DetailedSyncLogEntry.SetRange("Message ID", ResultmessageIDL);
                            IF DetailedSyncLogEntry."Field 3" <> '' then
                                DetailedSyncLogEntry.SetRange("Field 3", TargetIDL);


                            if DetailedSyncLogEntry.FindSet() then
                                ContactG.Reset();
                            ContactG.SetRange("No.", TargetIDL);
                            IF ContactG.FindFirst() then begin
                                Clear(CustomerNo);
                                ContactL.Reset();
                                ContactL.SetRange("Company No.", ContactG."Company No.");
                                IF ContactL.FindFirst() then begin
                                    repeat
                                        ContactBusinessRelation.Reset();
                                        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                                        ContactBusinessRelation.SetRange("Contact No.", ContactL."No.");
                                        IF ContactBusinessRelation.FindFirst() then begin
                                            CustomerNo := ContactBusinessRelation."No.";
                                        end;
                                    until ContactL.Next() = 0;
                                end;
                            end;
                            IF CustomerNo <> '' then begin
                                Customer.Reset();
                                Customer.SetRange("No.", CustomerNo);
                                IF Customer.FindFirst() then begin
                                    CustomerReferenceid := Customer."i95 Reference ID";
                                end;
                            end;

                            IF not (DetailedSyncLogEntry."Field 3" <> '') then begin
                                DetailedSyncLogEntry.UpdateSyncLogEntry(CurrentSyncStatus, CurrentLogStatus, HttpReasonCode,
                                i95WebserviceExecuteCU.GetAPIResponseResultText(), i95WebserviceExecuteCU.GetAPIResponseMessageText(),
                                i95WebserviceExecuteCU.ProcessJsonTokenasCode('sourceId', ResultDataJsonObject),
                                i95WebserviceExecuteCU.ProcessJsontokenasInteger('messageId', ResultDataJsonObject),
                                i95WebserviceExecuteCU.ProcessJsonTokenasText('message', ResultDataJsonObject),
                                i95WebserviceExecuteCU.ProcessJsonTokenasInteger('statusId', ResultDataJsonObject),
                                i95WebserviceExecuteCU.ProcessJsonTokenasCode('targetId', ResultDataJsonObject), SyncSource::i95)
                            end else begin
                                DetailedSyncLogEntry.UpdateSyncLogEntry(CurrentSyncStatus, CurrentLogStatus, HttpReasonCode,
                           i95WebserviceExecuteCU.GetAPIResponseResultText(), i95WebserviceExecuteCU.GetAPIResponseMessageText(),
                           CustomerReferenceid, i95WebserviceExecuteCU.ProcessJsontokenasInteger('messageId', ResultDataJsonObject),
                           i95WebserviceExecuteCU.ProcessJsonTokenasText('message', ResultDataJsonObject),
                           i95WebserviceExecuteCU.ProcessJsonTokenasInteger('statusId', ResultDataJsonObject),
                           CustomerNo, SyncSource::i95);
                            end;

                            IF TargetIDL <> '' then begin
                                IF not (DetailedSyncLogEntry."Field 3" <> '') then
                                    UpdateSourceRecord(SourceRecordID, Format(i95WebserviceExecuteCU.ProcessJsonTokenasCode('sourceId', ResultDataJsonObject)), CurrentAPIType, CurrentSyncStatus)
                                else begin
                                    IF Customer.get(CustomerNo) then
                                        SourceRecordID := Customer.RecordId;
                                    UpdateSourceRecord(SourceRecordID, CustomerReferenceid, CurrentAPIType, CurrentSyncStatus)
                                end;
                            end;
                        end;
                        APILogEntry.UpdateAPILogEntry(HttpReasonCode, '');
                    end;
                end else
                    If (i95WebserviceExecuteCU.GetAPIResponseResultText() = 'false') and (i95WebserviceExecuteCU.GetAPIResponseMessageText() <> '') then begin
                        i95SyncLogEntry."Sync Status" := i95SyncLogEntry."Sync Status"::"No Response";
                        i95SyncLogEntry."Log Status" := i95SyncLogEntry."Log Status"::Cancelled;
                        i95SyncLogEntry."Error Message" := '';
                        i95SyncLogEntry.modify();

                        APILogEntry.UpdateAPILogEntry(HttpReasonCode, i95WebserviceExecuteCU.GetAPIResponseMessageText());
                    end;
        end else begin
            i95SyncLogEntry.UpdateSyncLogEntry(i95SyncLogEntry."Sync Status", LogStatus::Error, HttpReasonCode, i95WebserviceExecuteCU.GetAPIResponseResultText(), i95WebserviceExecuteCU.GetAPIResponseMessageText(), MessageID, SourceID, i95SyncLogEntry."Status ID"::Error, SyncSource::i95);
            i95SyncLogEntry."Error Message" := copystr(GetLastErrorText(), 1, 300);
            i95SyncLogEntry.Modify();

            APILogEntry.UpdateAPILogEntry(HttpReasonCode, copystr(GetLastErrorText(), 1, 300));
        end;
    end;


    procedure GetSourceRecordID(Var SourceRecordID: RecordId; CurrentTargetID: Code[20]; CurrentAPIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerID,ReaccureToken)
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        CustomerGroup: Record "Customer Price Group";
        SalesShipment: Record "Sales Shipment Header";
        SalesInvoice: Record "Sales Invoice Header";
        GeneralJournalLine: Record "Gen. Journal Line";

    begin
        case CurrentAPIType of
            CurrentAPIType::Product,
            CurrentAPIType::Inventory,
            CurrentAPIType::TierPrices:
                begin
                    IF item.Get(CurrentTargetID) then begin
                        SourceRecordID := Item.RecordId();
                    end;
                end;
            CurrentAPIType::SalesOrder:
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
            CurrentAPIType::PaymentJournal:
                begin
                    GeneralJournalLine.Reset();
                    GeneralJournalLine.SetRange("Document No.", CurrentTargetID);
                    IF GeneralJournalLine.FindSet() then
                        SourceRecordID := GeneralJournalLine.RecordId();
                end;
            CurrentAPIType::SalesQuote:
                begin
                    IF SalesHeader.get(SalesHeader."Document Type"::Quote, CurrentTargetID) then begin
                        SourceRecordID := SalesHeader.RecordId();
                    end;
                end;
            CurrentAPIType::SalesReturn:
                begin
                    IF SalesHeader.get(SalesHeader."Document Type"::"Return Order", CurrentTargetID) then begin
                        SourceRecordID := SalesHeader.RecordId();
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
        GeneralJournalLine: Record "Gen. Journal Line";
    begin
        case CurrentAPIType of
            CurrentAPIType::Product:
                begin
                    IF item.Get(SourceRecordID) then begin
                        Item.Seti95APIUpdateCall(true);
                        Item.Updatei95SyncStatus(SyncSource::i95, CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::Inventory:
                begin
                    IF item.Get(SourceRecordID) then begin
                        Item.Seti95APIUpdateCall(true);
                        Item.Updatei95InventorySyncStatus(CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::Customer:
                begin
                    IF Customer.Get(SourceRecordID) then begin
                        Customer.Seti95APIUpdateCall(true);
                        Customer.Updatei95SyncStatus(SyncSource::i95, CurrentSyncStatus + 1, i95SourceCode);
                        ShipToAddress.Updatei95SyncStatus(SyncSource::i95, Customer."No.");
                    end;
                end;
            CurrentAPIType::CustomerGroup:
                begin
                    IF CustomerPriceGroup.Get(SourceRecordID) then begin
                        CustomerPriceGroup.Seti95APIUpdateCall(true);
                        CustomerPriceGroup.Updatei95SyncStatus(SyncSource::i95, CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::TierPrices:
                begin
                    IF item.Get(SourceRecordID) then begin
                        Item.Seti95APIUpdateCall(true);
                        Item.Updatei95SalesPriceSyncStatus(SyncSource::i95, CurrentSyncStatus + 1);
                    end;
                end;
            CurrentAPIType::SalesOrder, CurrentAPIType::SalesQuote, CurrentAPIType::SalesReturn:
                begin
                    IF SalesHeader.Get(SourceRecordID) then begin
                        SalesHeader.Seti95PullRequestAPICall(true);
                        SalesHeader.Updatei95SyncStatus(SyncSource::i95, CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
            CurrentAPIType::Shipment:
                begin
                    IF SalesShipmentHeader.Get(SourceRecordID) then begin
                        //  SalesShipmentHeader.Updatei95SyncStatus(CurrentSyncStatus + 1, i95SourceCode);
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
            CurrentAPIType::PaymentJournal:
                begin
                    IF GeneralJournalLine.Get(SourceRecordID) then begin
                        GeneralJournalLine.Seti95APIUpdateCall(true);
                        GeneralJournalLine.Updatei95SyncStatus(SyncSource::i95, CurrentSyncStatus + 1, i95SourceCode);
                    end;
                end;
        end;
    end;

    var
        i95SyncLogEntry: Record "i95 Sync Log Entry";
        APILogEntry: Record "i95 API Call Log Entry";
        i95Setup: Record "i95 Setup";
        DetailedSyncLogEntry: Record "i95 Detailed Sync Log Entry";
        i95WebserviceExecuteCU: codeunit "i95 Webservice Execute";
        CreateBodyContent: Codeunit "i95 Create Body Content";
        MessageID: Integer;
        SourceID: Code[20];
        StatusID: Integer;
        SyncLogEntryNo: Integer;
        APILogEntryNo: Integer;
        TestModeResponseTxt: Text;
        PullDataSource: Option " ",Customer,CustomerGroup,SalesOrder,Product,EntityManagement,PaymentJournal,SalesQuote,AccountRecievable,SalesReturn,ProductAttributeMapping,SchedulerID,ReaccureToken;
        SyncStatus: Option "Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete";
        LogStatus: Option " ",New,"In Progress",Completed,Error;
        CalledByAPI: Option "i95 Sync Request","i95 Sync Result","i95 Response Request","i95 Response Result","i95 Acknowledgement Request","i95 Acknowledgement Result";
        SyncSource: Option "","Business Central",i95;
        SchedulerType: Option " ",PushData,PullResponse,PullResponseAck,PullData,PushResponse;
        DataStatus: Option "","Data Received","Data Updated";
        BlobToUpdate: Option "i95 API Request","i95 API Result";
        TestMode: Boolean;
        HttpReasonCode: Text;
        ResultDataJsonArray: JsonArray;
        ResultDataJsonObject: JsonObject;
        ResultDataJsonToken: JsonToken;
        ResultDataBlankMsg: Label 'Result Data Blank.';
        ContactG: Record Contact;
        ContactL: Record Contact;
        Customer: Record Customer;
        ContactBusinessRelation: Record "Contact Business Relation";
        CustomerNo: Code[20];
        CustomerReferenceid: Code[20];

}