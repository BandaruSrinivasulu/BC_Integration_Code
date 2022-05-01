codeunit 70015 "I95 Update Sales Order"
{
    trigger OnRun()
    begin
        CreateSalesOrder();
    end;


    procedure CreateSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        GenLedgerSetup: Record "General Ledger Setup";
        ShippingAgentMapping: Record "i95 Shipping Agent Mapping";
        PaymentMethodsMapping: Record "i95 Payment Methods Mapping";
        CurrencyCode: code[20];
        TaxAmount: Decimal;
        OrderAmount: Decimal;
        SourceOrderStatus: text;
        OrderDateText: Text;
        OrderDate: Date;
        LastUpdatedDateText: Text;
        LastUpdatedDate: date;
        ShippingAmount: Decimal;
        CustomerId: code[20];
        CustomerPostingGroup: code[20];
        Email: text;
        ShippingAgentCode: code[50];
        BCShippingAgentCode: Code[10];
        PaymentMethodCode: code[50];
        BCPaymentMethodCode: Code[10];
        BCShippingAgentServiceCode: Code[10];
        IsGuest: Boolean;
        Month: Integer;
        Day: Integer;
        Year: Integer;
        CustomerIdBlankErr: Label 'Customer No. is blank';
        BillToCity: Text[30];
        BillToCountryId: Code[10];
        BillToName: text[50];
        BillToName2: Text[50];
        BillToPostCode: code[20];
        BillToRegion: Text[30];
        BillToAddress: Text[50];
        BillToAddress2: Text[50];
        BillToPhone: Text[50];
        ShipToCity: Text[30];
        ShipToCountryId: Code[10];
        ShipToName: text[50];
        ShipToName2: Text[50];
        ShipToPostCode: code[20];
        ShipToRegion: Text[30];
        ShipToAddress: Text[50];
        ShipToAddress2: Text[50];
        ShipToPhone: Text[50];
        ShippingAgentMappingErrorTxt: Label 'Shipping Method Mapping not available for %1 in order %2.';
        PaymentMethodMappingErrorTxt: Label 'Payment Method Mapping not available for %1 in order %2.';
        TrasactionNumber: Text[50];
        customerSourceId: Code[20];
        companyName: Text;
        SourceParentId: Code[20];
        targetParentId: code[20];
        customerType: text[50];
        CompanyInfoJsonObject: JsonObject;
        TargetCustomerID: code[20];
        PaymentTermsCode: Code[20];
        SalesPersonCode: Code[20];
    //EntityMapping: Record "i95 Entity Mapping";

    begin
        clear(ItemNo);
        Clear(QuantityOrdered);
        Clear(ItemPrice);
        Clear(SpecialPrice);
        Clear(RetailVariantId);
        Clear(ParentSku);
        i95Setup.get();
        SalesReceivablesSetup.get();
        Clear(SalesOrderNo);
        Clear(TargetId);
        Clear(MessageID);
        Clear(SourceID);
        Clear(typeid);


        TargetId := i95WebserviceExecuteCU.ProcessJsonTokenasCode('targetId', SalesInputDataJsonObject);
        MessageID := i95WebServiceExecuteCU.ProcessJsontokenasInteger('messageId', SalesInputDataJsonObject);
        StatusID := i95WebServiceExecuteCU.ProcessJsonTokenasInteger('statusId', SalesInputDataJsonObject);
        SourceID := i95WebServiceExecuteCU.ProcessJsonTokenascode('sourceId', SalesInputDataJsonObject);
        i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Waiting for Sync", LogStatus::New, HttpReasonCode, ResponseResultText, ResponseMessageText, MessageID, SourceID, StatusID, SyncSource::i95);
        If SalesInputDataJsonObject.Contains('inputData') then begin
            SalesInputDataJsonObject.get('inputData', SalesInputDataJsonToken);
            SalesInputDataJsonObject := SalesInputDataJsonToken.AsObject();

            SalesOrderNo := i95WebserviceExecuteCU.ProcessJsonTokenasCode('sourceId', SalesInputDataJsonObject);
            CurrencyCode := i95WebserviceExecuteCU.ProcessJsonTokenasCode('currency', SalesInputDataJsonObject);
            TaxAmount := i95WebserviceExecuteCU.ProcessJsonTokenasDecimal('taxAmount', SalesInputDataJsonObject);
            OrderAmount := i95WebserviceExecuteCU.ProcessJsonTokenasDecimal('orderDocumentAmount', SalesInputDataJsonObject);
            SourceOrderStatus := i95WebserviceExecuteCU.ProcessJsonTokenasText('sourceOrderStatus', SalesInputDataJsonObject);
            OrderDateText := i95WebserviceExecuteCU.ProcessJsonTokenasText('orderCreatedDate', SalesInputDataJsonObject);
            If strlen(OrderDateText) >= 10 then begin
                evaluate(Day, CopyStr(OrderDateText, 9, 2));
                evaluate(Month, CopyStr(OrderDateText, 6, 2));
                evaluate(Year, CopyStr(OrderDateText, 1, 4));
                OrderDate := DMY2Date(Day, Month, Year);
            end;

            LastUpdatedDateText := i95WebserviceExecuteCU.ProcessJsonTokenasText('lastUpdatedDate', SalesInputDataJsonObject);
            If strlen(LastUpdatedDateText) >= 10 then begin
                evaluate(Day, CopyStr(LastUpdatedDateText, 9, 2));
                evaluate(Month, CopyStr(LastUpdatedDateText, 6, 2));
                evaluate(Year, CopyStr(LastUpdatedDateText, 1, 4));
                LastUpdatedDate := DMY2Date(Day, Month, Year);
            end;
            Clear(CustomerId);
            ShippingAmount := i95WebserviceExecuteCU.ProcessJsonTokenasDecimal('shippingAmount', SalesInputDataJsonObject);
            CustomerID := i95WebserviceExecuteCU.ProcessJsonTokenasCode('targetCustomerId', SalesInputDataJsonObject);
            CustomerPostingGroup := i95WebserviceExecuteCU.ProcessJsonTokenasCode('customerGroup', SalesInputDataJsonObject);
            ShippingAgentCode := copystr(i95WebserviceExecuteCU.ProcessJsonTokenasText('shippingMethod', SalesInputDataJsonObject), 1, 50);

            If SalesInputDataJsonObject.Contains('customer') then begin
                SalesInputDataJsonObject.get('customer', SalesInputDataJsonToken);
                SOAddressJsonObject := SalesInputDataJsonToken.AsObject();

                Email := i95WebserviceExecuteCU.ProcessJsonTokenasText('email', SOAddressJsonObject);
                IsGuest := i95WebserviceExecuteCU.ProcessJsonTokenasBoolean('isGuest', SOAddressJsonObject);
                //Filling the customer target id based on customer source id
                customerSourceId := i95WebServiceExecuteCU.ProcessJsonTokenasCode('sourceId', SOAddressJsonObject);
                TargetCustomerID := i95WebServiceExecuteCU.ProcessJsonTokenasCode('targetCustomerId', SOAddressJsonObject);

                //End Filling the customer target id based on customer source id
                //Start Company Account
                IF SOAddressJsonObject.Contains('companyInfo') then begin
                    SOAddressJsonObject.get('companyInfo', SOAddressJsonToken);
                    CompanyInfoJsonObject := SOAddressJsonToken.AsObject();

                    SourceParentId := i95WebServiceExecuteCU.ProcessJsonTokenasCode('sourceParentId', CompanyInfoJsonObject);
                    targetParentId := i95WebServiceExecuteCU.ProcessJsonTokenasCode('targetParentId', CompanyInfoJsonObject);
                    customerType := i95WebServiceExecuteCU.ProcessJsonTokenasText('customerType', CompanyInfoJsonObject);
                    companyName := i95WebServiceExecuteCU.ProcessJsonTokenasText('companyName', CompanyInfoJsonObject);

                end;
                //Stop Company account
            end;

            If SalesInputDataJsonObject.Contains('billingAddress') then begin
                SalesInputDataJsonObject.get('billingAddress', SalesInputDataJsonToken);
                SOAddressJsonObject := SalesInputDataJsonToken.AsObject();

                BillToCity := copystr(i95WebserviceExecuteCU.ProcessJsonTokenasText('city', SOAddressJsonObject), 1, 30);
                BillToCountryId := copystr(i95WebserviceExecuteCU.ProcessJsonTokenasCode('countryId', SOAddressJsonObject), 1, 10);
                BillToName := copystr(i95WebserviceExecuteCU.ProcessJsonTokenasText('firstName', SOAddressJsonObject), 1, 50);
                BillToName2 := copystr(i95WebserviceExecuteCU.ProcessJsonTokenasText('lastName', SOAddressJsonObject), 1, 50);
                BillToPostCode := i95WebserviceExecuteCU.ProcessJsonTokenasCode('postcode', SOAddressJsonObject);
                BillToRegion := copystr(i95WebserviceExecuteCU.ProcessJsonTokenastext('region', SOAddressJsonObject), 1, 30);
                BillToAddress := copystr(i95WebserviceExecuteCU.ProcessJsonTokenastext('street', SOAddressJsonObject), 1, 50);
                BillToAddress2 := copystr(i95WebserviceExecuteCU.ProcessJsonTokenastext('street2', SOAddressJsonObject), 1, 50);
                BillToPhone := copystr(i95WebserviceExecuteCU.ProcessJsonTokenasText('telephone', SOAddressJsonObject), 1, 50);
            end;

            If SalesInputDataJsonObject.Contains('shippingAddress') then begin
                SalesInputDataJsonObject.get('shippingAddress', SalesInputDataJsonToken);
                SOAddressJsonObject := SalesInputDataJsonToken.AsObject();

                ShipToCity := copystr(i95WebserviceExecuteCU.ProcessJsonTokenasText('city', SOAddressJsonObject), 1, 30);
                ShipToCountryId := copystr(i95WebserviceExecuteCU.ProcessJsonTokenasCode('countryId', SOAddressJsonObject), 1, 10);
                ShipToName := copystr(i95WebserviceExecuteCU.ProcessJsonTokenasText('firstName', SOAddressJsonObject), 1, 50);
                ShipToName2 := copystr(i95WebserviceExecuteCU.ProcessJsonTokenasText('lastName', SOAddressJsonObject), 1, 50);
                ShipToPostCode := i95WebserviceExecuteCU.ProcessJsonTokenasCode('postcode', SOAddressJsonObject);
                ShipToRegion := copystr(i95WebserviceExecuteCU.ProcessJsonTokenastext('region', SOAddressJsonObject), 1, 30);
                ShipToAddress := copystr(i95WebserviceExecuteCU.ProcessJsonTokenastext('street', SOAddressJsonObject), 1, 50);
                ShipToAddress2 := copystr(i95WebserviceExecuteCU.ProcessJsonTokenastext('street2', SOAddressJsonObject), 1, 50);
                ShipToPhone := copystr(i95WebserviceExecuteCU.ProcessJsonTokenasText('telephone', SOAddressJsonObject), 1, 50);
            end;
        end;

        if SalesInputDataJsonObject.Contains('payment') then begin
            SalesInputDataJsonObject.get('payment', PaymentInputDataJsonToken);
            PaymentInputDataJsonarray := PaymentInputDataJsonToken.AsArray();
        end;
        foreach PaymentInputDataJsonToken in PaymentInputDataJsonarray do begin
            PaymentInputDataJsonObject := PaymentInputDataJsonToken.AsObject();
            PaymentMethodCode := copystr(i95WebserviceExecuteCU.ProcessJsonTokenastext('paymentMethod', PaymentInputDataJsonObject), 1, 50);
        end;

        //For charge logic
        TrasactionNumber := i95WebserviceExecuteCU.ProcessJsonTokenastext('transactionNumber', PaymentInputDataJsonObject);

        /* //Check Shipment Method and Payment Method Mapping
         If ShippingAgentCode <> '' then begin
             ShippingAgentMapping.Reset();
             ShippingAgentMapping.SetRange(ShippingAgentMapping."E-Com Shipping Method Code", ShippingAgentCode);
             If ShippingAgentMapping.FindFirst() then begin
                 BCShippingAgentCode := ShippingAgentMapping."BC Shipping Agent Code";
                 BCShippingAgentServiceCode := ShippingAgentMapping."BC Shipping Agent Service Code";
             end else
                 Error(StrSubstNo(ShippingAgentMappingErrorTxt, ShippingAgentCode, SalesOrderNo));
         end;*/

        IF ShippingAgentCode <> '' then begin //New Changes for Shipping mapping 
            BCShippingAgentCode := CopyStr(ShippingAgentCode, 1, StrPos(ShippingAgentCode, '-') - 1);
            BCShippingAgentServiceCode := CopyStr(ShippingAgentCode, StrPos(ShippingAgentCode, '-') + 1, StrLen(ShippingAgentCode) - StrPos(ShippingAgentCode, '-') + 1);
        end else
            Error(StrSubstNo(ShippingAgentMappingErrorTxt, ShippingAgentCode, SalesOrderNo));


        /*  If PaymentMethodCode <> '' then begin
              PaymentMethodsMapping.Reset();
              PaymentMethodsMapping.SetRange(PaymentMethodsMapping."E-Commerce Payment Method Code", PaymentMethodCode);
              PaymentMethodsMapping.SetRange(PaymentMethodsMapping."Ecommerce to BC Default", true);
              If PaymentMethodsMapping.FindFirst() then
                  BCPaymentMethodCode := PaymentMethodsMapping."BC Payment Method Code"
              else begin
                  PaymentMethodsMapping.SetRange(PaymentMethodsMapping."Ecommerce to BC Default");
                  If paymentMethodsMapping.FindFirst() then
                      BCPaymentMethodCode := PaymentMethodsMapping."BC Payment Method Code"
                  else
                      error(StrSubstNo(PaymentMethodMappingErrorTxt, PaymentMethodCode, SalesOrderNo));
              end;
          end;*/

        IF PaymentMethodCode <> '' then begin //New Changes for Payment Method
            BCPaymentMethodCode := PaymentMethodCode;
        end else
            error(StrSubstNo(PaymentMethodMappingErrorTxt, PaymentMethodCode, SalesOrderNo));


        clear(SourceRecordID);
        If SalesOrderNo <> '' then begin
            SalesHeader.init();
            SalesHeader.validate("Document Type", SalesHeader."Document Type"::Order);
            SalesHeader."No." := '';
            SalesHeader.Insert(true);

            If IsGuest and (i95Setup."Default Guest Customer No." <> '') then
                SalesHeader.validate("Sell-to Customer No.", i95Setup."Default Guest Customer No.")
            else
                     /*if (CustomerId <> '') then begin
                         Customer.reset();
                         Customer.SetCurrentKey("i95 Reference ID");
                         Customer.SetRange("i95 Reference ID", CustomerId);
                         if Customer.FindFirst() then
                             CustomerId := Customer."No.";

                         SalesHeader.validate("Sell-to Customer No.", CustomerId);
                     end else
                         Error(CustomerIdBlankErr);*/
                     begin
                Customer.Reset();
                i95Setup.Get();
                IF i95Setup."i95 Enable Company" = true then begin
                    IF customerType = 'Company' then
                        Customer.SetRange("i95 Reference ID", SourceParentId)
                    else
                        if customerType = 'Customer' then
                            Customer.SetRange("i95 Reference ID", customerSourceId)
                        else
                            IF customerType = 'User' then
                                Customer.SetRange("i95 Reference ID", SourceParentId);

                end else
                    Customer.SetRange("i95 Reference ID", customerSourceId);

                if Customer.FindFirst() then begin
                    CustomerId := Customer."No.";
                    //End: Filling the customer target id based on customer source id
                    SalesHeader.validate("Sell-to Customer No.", CustomerId);
                end else
                    Error(CustomerIdBlankErr);
            end;


            SalesHeader."i95 Created By" := 'i95Dev';
            SalesHeader."i95 Created DateTime" := CurrentDateTime();
            SalesHeader."i95 Creation Source" := SalesHeader."i95 Creation Source"::i95;

            GenLedgerSetup.get();
            if GenLedgerSetup."LCY Code" <> CurrencyCode then
                SalesHeader.validate("Currency Code", CurrencyCode);
            SalesHeader.validate("Order Date", OrderDate);

            SalesHeader."Ship-to Name" := copystr(ShipToName + ' ' + ShipToName2, 1, 99);
            SalesHeader."Ship-to Address" := ShipToAddress;
            SalesHeader."Ship-to Address 2" := ShipToAddress2;
            SalesHeader."Ship-to City" := ShipToCity;
            SalesHeader."Ship-to Post Code" := ShipToPostCode;
            SalesHeader."Ship-to County" := ShipToRegion;
            SalesHeader."Ship-to Country/Region Code" := ShipToCountryId;
            SalesHeader."Ship-to Contact" := ShipToPhone;


            SalesHeader."Bill-to Name" := Copystr(BillToName + ' ' + BillToName2, 1, 99);
            SalesHeader."Bill-to Address" := BillToAddress;
            SalesHeader."Bill-to Address 2" := BillToAddress2;
            SalesHeader."Bill-to City" := BillToCity;
            SalesHeader."Bill-to Post Code" := BillToPostCode;
            SalesHeader."Bill-to County" := BillToRegion;
            SalesHeader."Bill-to Country/Region Code" := BillToCountryId;
            SalesHeader."Bill-to Contact" := BillToPhone;

            SalesHeader."Sell-to Customer Name" := Copystr(BillToName + ' ' + BillToName2, 1, 99);
            SalesHeader."Sell-to Address" := BillToAddress;
            SalesHeader."Sell-to Address 2" := BillToAddress2;
            SalesHeader."Sell-to City" := BillToCity;
            SalesHeader."Sell-to Post Code" := BillToPostCode;
            SalesHeader."Sell-to County" := BillToRegion;
            SalesHeader."Sell-to Country/Region Code" := BillToCountryId;


            IF TargetCustomerID <> '' then
                SalesHeader."Sell-to Contact" := TargetCustomerID
            else
                SalesHeader."Sell-to Contact" := BillToPhone;

            SalesHeader."Sell-to Phone No." := BillToPhone;
            SalesPersonCode := i95WebserviceExecuteCU.ProcessJsonTokenasCode('salesPersonId', SalesInputDataJsonObject);
            SalesHeader."Salesperson Code" := SalesPersonCode;

            PaymentTermsCode := i95WebserviceExecuteCU.ProcessJsonTokenasCode('netTermsId', SalesInputDataJsonObject);
            SalesHeader."Payment Terms Code" := PaymentTermsCode;
            Clear(WarehouseCode);
            WarehouseCode := i95WebServiceExecuteCU.ProcessJsonTokenasCode('warehouseCode', SalesInputDataJsonObject);

            SalesHeader.validate("Shipping Agent Code", BCShippingAgentCode);
            SalesHeader.validate("Shipping Agent Service Code", BCShippingAgentServiceCode);
            SalesHeader.validate("Payment Method Code", BCPaymentMethodCode);
            //For Charge Logic
            SalesHeader."CL-TransactionNumber" := TrasactionNumber;

            i95Setup.Get();
            IF not (i95Setup."i95 Enable MultiWarehouse" = true) then begin
                If i95Setup."i95 Default Warehouse" <> '' then
                    SalesHeader.validate("Location Code", i95Setup."i95 Default Warehouse");
            end else begin
                SalesHeader.validate("Location Code", WarehouseCode);
            end;

            If IsGuest then
                SalesHeader."Sell-to E-Mail" := CopyStr(Email, 1, 80);
            SalesHeader.validate("i95 Reference ID", SalesOrderNo);
            SalesHeader.Seti95PullRequestAPICall(true);
            SalesHeader.Modify();

            if SalesInputDataJsonObject.Contains('orderItems') then begin
                SalesInputDataJsonObject.get('orderItems', SalesLineInputDataJsonToken);
                SalesLineInputDataJsonArray := SalesLineInputDataJsonToken.AsArray();
            end;
            Clear(LineNo);


            foreach SalesLineInputDataJsonToken in SalesLineInputDataJsonArray do begin
                SalesLineInputDataJsonObject := SalesLineInputDataJsonToken.AsObject();
                ItemNo := i95WebserviceExecuteCU.ProcessJsonTokenasCode('sku', SalesLineInputDataJsonObject);
                ItemPrice := i95WebserviceExecuteCU.ProcessJsonTokenasDecimal('price', SalesLineInputDataJsonObject);
                QuantityOrdered := i95WebserviceExecuteCU.ProcessJsonTokenasDecimal('qty', SalesLineInputDataJsonObject);
                SpecialPrice := i95WebserviceExecuteCU.ProcessJsonTokenasDecimal('specialPrice', SalesLineInputDataJsonObject);
                RetailVariantId := i95WebServiceExecuteCU.ProcessJsonTokenasCode('retailVariantId', SalesLineInputDataJsonObject);
                ParentSku := i95WebServiceExecuteCU.ProcessJsonTokenasCode('parentSku', SalesLineInputDataJsonObject);
                typeid := i95WebServiceExecuteCU.ProcessJsonTokenasText('typeId', SalesLineInputDataJsonObject);
                //Discount Amount
                clear(LineDiscountAmount);
                if SalesLineInputDataJsonObject.Contains('discount') then begin
                    SalesLineInputDataJsonObject.get('discount', DiscountAmountInputDataJsonToken);
                    DiscountAmountInputDataJsonArray := DiscountAmountInputDataJsonToken.AsArray();
                end;

                foreach DiscountAmountInputDataJsonToken in DiscountAmountInputDataJsonArray do begin
                    DiscountAmountInputDataJsonObject := DiscountAmountInputDataJsonToken.AsObject();
                    LineDiscountAmount := i95WebserviceExecuteCU.ProcessJsonTokenasDecimal('discountAmount', DiscountAmountInputDataJsonObject);
                end;
                IF typeid = 'simple' then
                    CreateSalesOrderLines(SalesHeader);
            end;


            If (ShippingAmount <> 0) and (i95Setup."i95 Shipping Charge G/L Acc" <> '') then
                CreateShippingChargeSalesOrderLine(SalesHeader, ShippingAmount);

            SourceRecordID := SalesHeader.RecordId();
            SalesHeader.Seti95PullRequestAPICall(true);
            SalesHeader."i95 Last Modification DateTime" := CurrentDateTime();
            SalesHeader."i95 Last Modified By" := copystr(UserId(), 1, 80);
            SalesHeader."i95 Last Sync DateTime" := CurrentDateTime();
            SalesHeader."i95 Sync Status" := SalesHeader."i95 Sync Status"::"Waiting for Response";
            SalesHeader."i95 Last Modification Source" := SalesHeader."i95 Last Modification Source"::i95;
            SalesHeader."i95 Reference ID" := SalesOrderNo;
            SalesHeader.Modify(false);

        end else
            i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"No Response", LogStatus::Cancelled, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);

    end;


    procedure CreateSalesOrderLines(SalHdr: Record "Sales Header")
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        i95Setup.get();

        SalesLine.init();
        SalesLine.Validate("Document Type", SalesLine."Document Type"::Order);
        SalesLine.validate("Document No.", SalHdr."No.");
        SalesLine.Validate("Sell-to Customer No.", SalHdr."Sell-to Customer No.");
        SalesLine.validate("Line No.", LineNo + 10000);
        SalesLine.insert();
        SalesLine.validate(Type, SalesLine.Type::Item);

        if (ParentSku <> '') and (strpos(ItemNo, i95Setup."i95 Item Variant Seperator") <> 0) then begin
            ParentSku := copystr(CopyStr(ItemNo, 1, StrPos(ItemNo, i95Setup."i95 Item Variant Seperator") - 1), 1, 20);
            RetailVariantId := copystr(CopyStr(ItemNo, StrPos(ItemNo, i95Setup."i95 Item Variant Seperator") + 1), 1, 20);
            ItemVariant.Reset();
            ItemVariant.SetRange(ItemVariant."Item No.", ParentSku);
            ItemVariant.SetRange(ItemVariant.Code, RetailVariantId);
            If ItemVariant.FindFirst() then begin
                SalesLine.Validate("No.", ItemVariant."Item No.");
                SalesLine.Validate("Variant Code", ItemVariant.Code);
            end else begin
                ItemVariant.Reset();
                ItemVariant.SetCurrentKey("i95 Reference ID");
                ItemVariant.SetRange(ItemVariant."i95 Reference ID", ParentSku);
                If ItemVariant.FindFirst() then begin
                    SalesLine.Validate("No.", ItemVariant."Item No.");
                    SalesLine.Validate("Variant Code", ItemVariant.Code);
                end else
                    If Item.get(ItemNo) then
                        SalesLine.validate("No.", ItemNo)
                    else begin
                        If ItemNo <> '' then begin
                            Item.reset();
                            Item.SetRange(Item."i95 Reference ID", ItemNo);
                            If Item.FindFirst() then
                                ItemNo := Item."No.";
                        end;
                        SalesLine.validate("No.", ItemNo);
                    end;
            end;
        end else
            If Item.get(ItemNo) then
                SalesLine.validate("No.", ItemNo)
            else begin
                If ItemNo <> '' then begin
                    Item.reset();
                    Item.SetRange(Item."i95 Reference ID", ItemNo);
                    If Item.FindFirst() then
                        ItemNo := Item."No.";
                end;
                SalesLine.validate("No.", ItemNo);
            end;

        SalesLine.validate(Quantity, QuantityOrdered);

        /* if i95Setup."i95 Default Warehouse" <> '' then
             SalesLine.Validate("Location Code", i95Setup."i95 Default Warehouse");*/

        i95Setup.Get();
        IF not (i95Setup."i95 Enable MultiWarehouse" = true) then begin
            if i95Setup."i95 Default Warehouse" <> '' then
                SalesLine.Validate("Location Code", i95Setup."i95 Default Warehouse");
        end else begin
            SalesLine.Validate("Location Code", WarehouseCode);
        end;

        If SpecialPrice = 0 then
            SalesLine.validate("Unit Price", ItemPrice)
        else
            SalesLine.validate("Unit Price", SpecialPrice);

        If LineDiscountAmount <> 0 then
            SalesLine.validate("Line Discount Amount", LineDiscountAmount);

        SalesLine.i95SetAPIUpdateCall(true);

        LineNo := SalesLine."Line No.";

        SalesLine.Modify(false);
    end;


    procedure CreateShippingChargeSalesOrderLine(SalHdr: Record "Sales Header"; ShippingChargeAmount: Decimal)
    var
        SalesLine: Record "Sales Line";
        GLAcc: Record "G/L Account";
    begin
        i95Setup.get();

        SalesLine.init();
        SalesLine.Validate("Document Type", SalesLine."Document Type"::Order);
        SalesLine.validate("Document No.", SalHdr."No.");
        SalesLine.Validate("Sell-to Customer No.", SalHdr."Sell-to Customer No.");
        SalesLine.validate("Line No.", LineNo + 10000);
        SalesLine.insert();
        SalesLine.validate(Type, SalesLine.Type::"G/L Account");

        If GLAcc.get(i95Setup."i95 Shipping Charge G/L Acc") then
            SalesLine.validate("No.", i95Setup."i95 Shipping Charge G/L Acc");

        SalesLine.validate(Quantity, 1);

        if i95Setup."i95 Default Warehouse" <> '' then
            SalesLine.Validate("Location Code", i95Setup."i95 Default Warehouse");

        SalesLine.validate("Unit Price", ShippingChargeAmount);
        SalesLine.i95SetAPIUpdateCall(true);

        LineNo := SalesLine."Line No.";

        SalesLine.Modify(false);
    end;

    procedure SetSaleOrderValues(var i95WebServiceExecuteCUP: Codeunit "i95 Webservice Execute"; var SalesHeaderP: Record "Sales Header"; Var SalesInputDataJsonArrayP: JsonArray; var SalesInputJsonTokenP: JsonToken; var SalesInputDataJsonTokenP: JsonToken; var SalesInputDataJsonObjectP: JsonObject; var i95SyncLogEntryP: Record "i95 Sync Log Entry")
    begin
        SalesHeader := SalesHeaderP;
        SalesInputDataJsonToken := SalesInputDataJsonTokenP;
        SalesInputJsonToken := SalesInputJsonTokenP;
        SalesInputDataJsonArray := SalesInputDataJsonArrayP;
        i95SyncLogEntry := i95SyncLogEntryP;
        i95WebServiceExecuteCU := i95WebServiceExecuteCUP;
        SalesInputDataJsonObject := SalesInputDataJsonObjectP;
    end;

    procedure Getvalues(var SalesHeaderP: Record "Sales Header"; var SourceRecordIDP: RecordId; Var i95SyncLogEntryP: Record "i95 Sync Log Entry"; var SourceIDP: Code[20]; var MessageIDP: Integer; Var SalesOrderNoP: code[20])
    begin
        SalesHeaderP := SalesHeader;
        SourceRecordIDP := SourceRecordID;
        i95SyncLogEntryP := i95SyncLogEntry;
        SourceIDP := SourceID;
        MessageIDP := MessageID;
        SalesOrderNoP := SalesHeader."No.";

    end;



    var
        SalesHeader: Record "Sales Header";
        SourceRecordID: RecordId;
        i95SyncLogEntry: Record "i95 Sync Log Entry";
        i95Setup: Record "i95 Setup";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        DetailedSyncLogEntry: Record "i95 Detailed Sync Log Entry";
        i95WebServiceExecuteCU: Codeunit "i95 Webservice Execute";
        MessageID: Integer;
        SourceID: code[20];
        StatusID: Option "Request Received","Request Inprocess","Error","Response Received","Response Transferred","Complete";
        APIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerID,ReaccureToken;
        SyncStatus: Option "Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete","No Response";
        LogStatus: Option " ",New,"In-Progress",Completed,Error,Cancelled;
        SyncSource: Option "","Business Central",i95;
        SalesInputDataJsonArray: JsonArray;
        SalesInputJsonToken: JsonToken;
        SalesInputDataJsonToken: JsonToken;
        SalesInputDataJsonObject: JsonObject;
        SOAddressJsonObject: JsonObject;
        SOAddressJsonToken: JsonToken;
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
        SalesOrderNo: Code[20];
        typeid: Text;
        WarehouseCode: Code[20];

}