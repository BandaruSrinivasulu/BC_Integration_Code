codeunit 70014 "i95 Update Customer"
{
    trigger OnRun()
    begin
        CreateCustomer();
    end;



    Procedure CreateCustomer()
    var

        ShiptoAddress: Record "Ship-to Address";
        SourceNo: Code[20];
        Email: Text;
        FirstName: Text;
        LastName: text;
        CustFirstName: Text;
        CustLastName: text;
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
        CustCustomerType: Text;
        ContactCustomerType: Text;
        i95DevSetupG: Record "i95 Setup";
        TargetParentId: Code[30];
        ContactAlternateAddress: Record "Contact Alt. Address";
        ContactAddress: text[50];
        ContactAddress2: text[50];
        ContactCity: text[30];
        ContactPhoneNo: text[30];
        ContactRegionCode: Code[10];
        ContactCountryCode: Code[10];
        ContactPostCode: code[20];
        ContactEmail: Text;
        ContactFirstName: Text;
        ContactLastName: text;
        ContactSourceNo: Code[50];
        ContactAddressSourceNo: Code[50];
        ContactIsDefaultBilling: Boolean;
        ContactIsDefaultShipping: Boolean;
        MarketingSetup: Record "Marketing Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        ContactResultjsonObject: JsonObject;
        CompanySourceNo: Code[20];
        GetSourceJsonObject: JsonObject;
        GetSourceJsontoken: JsonToken;
        CompanyNoL: Code[50];
        CustomerNoL: Code[50];
        CustomerL: Record Customer;
        ContactL: Record Contact;
        ContactlinkNoL: Code[50];
        CompanyContact: Record Contact;
        PaymentTermsCode: Code[20];
        SalesPersonCode: Code[20];
        EntityMapping: Record "i95 Entity Mapping";

    begin
        Clear(Email);
        Clear(SourceNo);
        MessageID := 0;
        TargetID := '';
        SourceID := '';




        ResultDataJsonObject := ResultDataJsonToken.AsObject();
        ContactResultjsonObject := ResultDataJsonToken.AsObject();
        GetSourceJsonObject := ResultDataJsonToken.AsObject();
        i95DevSetupG.Get();
        IF i95DevSetupG."i95 Enable Company" = true then begin
            if GetSourceJsonObject.Contains('inputData') then begin
                GetSourceJsonObject.get('inputData', GetSourceJsontoken);
                GetSourceJsonObject := GetSourceJsontoken.AsObject();
                SourceNo := i95WebServiceExecuteCU.ProcessJsonTokenasCode('sourceId', GetSourceJsonObject);
                SourceID := i95WebServiceExecuteCU.ProcessJsonTokenasCode('sourceId', GetSourceJsonObject);
            end;
        end else begin
            SourceNo := i95WebserviceExecuteCU.ProcessJsonTokenasCode('sourceId', ResultDataJsonObject);
            SourceID := i95WebServiceExecuteCU.ProcessJsonTokenasCode('sourceId', ResultDataJsonObject);
        end;
        ResultDataJsonObject := ResultDataJsonToken.AsObject();
        TargetID := i95WebserviceExecuteCU.ProcessJsonTokenasCode('targetId', ResultDataJsonObject);
        MessageID := i95WebServiceExecuteCU.ProcessJsontokenasInteger('messageId', ResultDataJsonObject);
        StatusID := i95WebServiceExecuteCU.ProcessJsonTokenasInteger('statusId', ResultDataJsonObject);
        i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"Waiting for Sync", LogStatus::New, HttpReasonCode, ResponseResultText, ResponseMessageText, MessageID, SourceID, StatusID, SyncSource::i95);
        if ResultDataJsonObject.Contains('inputData') then begin
            ResultDataJsonObject.get('inputData', ResultDataJsonToken);
            ResultDataJsonObject := ResultDataJsonToken.AsObject();

            Email := i95WebserviceExecuteCU.ProcessJsonTokenasText('email', ResultDataJsonObject);

            CustFirstName := i95WebserviceExecuteCU.ProcessJsonTokenasText('firstName', ResultDataJsonObject);
            CustLastName := i95WebserviceExecuteCU.ProcessJsonTokenasText('lastName', ResultDataJsonObject);
            CustPriceGroup := i95WebserviceExecuteCU.ProcessJsonTokenasCode('customerGroup', ResultDataJsonObject);
            //Company Account
            i95DevSetupG.Get();
            IF i95DevSetupG."i95 Enable Company" = true then begin
                CustCustomerType := i95WebServiceExecuteCU.ProcessJsonTokenasText('customerType', ResultDataJsonObject);
                FirstName := i95WebServiceExecuteCU.ProcessJsonTokenasText('companyName', ResultDataJsonObject);
                LastName := i95WebServiceExecuteCU.ProcessJsonTokenasText('legalName', ResultDataJsonObject);
                // CompanySourceNo := i95WebServiceExecuteCU.ProcessJsonTokenasCode('sourceId', ResultDataJsonObject);
            end;
            //Company Account
            CustPriceGroup := i95WebserviceExecuteCU.ProcessJsonTokenasCode('customerGroup', ResultDataJsonObject);

        end;


        clear(SourceRecordID);
        clear(SecSourceRecordID);
        SalesReceivablesSetup.get();
        i95Setup.get();
        If (SourceNo <> '') then begin
            NewCustomer.reset();
            NewCustomer.SetCurrentKey("i95 Reference ID");
            /*  i95DevSetupG.Get();
              IF i95DevSetupG."i95 Enable Company" = true then begin
                  IF CustCustomerType = 'Customer' then
                      NewCustomer.SetRange("i95 Reference ID", SourceNo)
                  else
                      if CustCustomerType = 'Company' then
                          NewCustomer.SetRange("i95 Reference ID", CompanySourceNo);
              end else begin*/
            NewCustomer.SetRange("i95 Reference ID", SourceNo);
            // end;
            If not NewCustomer.FindFirst() then begin
                NewCustomer.init();
                If i95Setup."Customer Nos." <> '' then
                    NewCustomer.validate("No.", NoSeriesMgt.GetNextNo(i95Setup."Customer Nos.", 0D, true))
                else
                    NewCustomer.validate("No.", NoSeriesMgt.GetNextNo(SalesReceivablesSetup."Customer Nos.", 0D, true));
                NewCustomer."i95 Created By" := 'i95';
                NewCustomer."i95 Created DateTime" := CurrentDateTime();
                NewCustomer."i95 Creation Source" := NewCustomer."i95 Creation Source"::i95;
                NewCustomer.insert();
            end;

            //Company account 
            i95DevSetupG.Get();
            IF (i95DevSetupG."i95 Enable Company" = true) then begin
                if CustCustomerType = ' ' then
                    NewCustomer.Validate("i95 Customer Type", NewCustomer."i95 Customer Type"::" ")
                else
                    if (CustCustomerType = 'Customer') or (CustCustomerType = '') then
                        NewCustomer.Validate("i95 Customer Type", NewCustomer."i95 Customer Type"::Customer)
                    else
                        if CustCustomerType = 'Company' then
                            NewCustomer.Validate("i95 Customer Type", NewCustomer."i95 Customer Type"::Company);
            end else begin
                NewCustomer.Validate("i95 Customer Type", NewCustomer."i95 Customer Type"::Customer);
            end;

            //Company account

            NewCustomer."E-Mail" := Email;
            IF CustCustomerType = 'Company' then
                NewCustomer.validate(Name, FirstName)
            else
                NewCustomer.validate(Name, copystr(CustFirstName + ' ' + CustLastName, 1, 100));

            // NewCustomer.validate(Name, copystr(FirstName + ' ' + LastName, 1, 100));
            /* i95DevSetupG.Get();
             IF i95DevSetupG."i95 Enable Company" = true then begin
                 IF CustCustomerType = 'Customer' then
                     NewCustomer.validate("i95 Reference ID", SourceNo)
                 else
                     if CustCustomerType = 'Company' then
                         NewCustomer.validate("i95 Reference ID", CompanySourceNo);
             end else begin*/
            NewCustomer.validate("i95 Reference ID", SourceNo);
            // end;
            NewCustomer.validate("Customer Posting Group", i95Setup."i95 Customer Posting Group");
            NewCustomer.validate("Gen. Bus. Posting Group", i95Setup."i95 Gen. Bus. Posting Group");
            NewCustomer.validate(NewCustomer."Customer Price Group", CustPriceGroup);

            PaymentTermsCode := i95WebserviceExecuteCU.ProcessJsonTokenasCode('netTermsId', ResultDataJsonObject);
            NewCustomer.validate(NewCustomer."Payment Terms Code", PaymentTermsCode);
            SalesPersonCode := i95WebserviceExecuteCU.ProcessJsonTokenasCode('salesPersonId', ResultDataJsonObject);
            IF SalesPersonCode <> '' then
                NewCustomer.validate("Salesperson Code", SalesPersonCode);

            IF (CustCustomerType = 'Customer') or (CustCustomerType = '') then begin
                if ResultDataJsonObject.Contains('addresses') then begin
                    ResultDataJsonObject.get('addresses', ResultDataJsonToken);
                    ResultDataJsonArray := ResultDataJsonToken.AsArray();
                end;
            end else
                if CustCustomerType = 'Company' then begin
                    if ResultDataJsonObject.Contains('address') then begin
                        ResultDataJsonObject.get('address', ResultDataJsonToken);
                        ResultDataJsonArray := ResultDataJsonToken.AsArray();
                    end;
                end;

            foreach ResultDataJsonToken in ResultDataJsonArray do begin
                ResultDataJsonObject := ResultDataJsonToken.AsObject();

                SourceAddressID := i95WebserviceExecuteCU.ProcessJsonTokenasCode('sourceId', ResultDataJsonObject);
                ShipToFirstName := i95WebserviceExecuteCU.ProcessJsonTokenasText('firstName', ResultDataJsonObject);
                ShipToLastName := i95WebserviceExecuteCU.ProcessJsonTokenasText('lastName', ResultDataJsonObject);
                Address := copystr(i95WebserviceExecuteCU.ProcessJsonTokenasText('street', ResultDataJsonObject), 1, 50);
                Address2 := copystr(i95WebserviceExecuteCU.ProcessJsonTokenasText('street2', ResultDataJsonObject), 1, 50);
                RegionCode := copystr(i95WebserviceExecuteCU.ProcessJsonTokenasCode('regionId', ResultDataJsonObject), 1, 10);
                City := i95WebserviceExecuteCU.ProcessJsonTokenasCode('city', ResultDataJsonObject);
                CountryCode := copystr(i95WebserviceExecuteCU.ProcessJsonTokenasCode('countryId', ResultDataJsonObject), 1, 10);
                PostCode := i95WebserviceExecuteCU.ProcessJsonTokenasCode('postcode', ResultDataJsonObject);
                PhoneNo := copystr(i95WebserviceExecuteCU.ProcessJsonTokenasText('telephone', ResultDataJsonObject), 1, 30);
                IsDefaultBilling := i95WebserviceExecuteCU.ProcessJsonTokenasBoolean('isDefaultBilling', ResultDataJsonObject);
                IsDefaultShipping := i95WebserviceExecuteCU.ProcessJsonTokenasBoolean('isDefaultShipping', ResultDataJsonObject);

                If IsDefaultBilling then begin
                    NewCustomer.validate(Address, Address);
                    NewCustomer.validate("Address 2", Address2);
                    NewCustomer.validate(City, City);
                    NewCustomer.validate("Phone No.", PhoneNo);
                    NewCustomer.validate(County, RegionCode);
                    NewCustomer.validate("Country/Region Code", CountryCode);
                    NewCustomer.validate("Phone No.", PhoneNo);
                    NewCustomer.validate(City, City);
                    NewCustomer.validate("Post Code", PostCode);
                    NewCustomer.County := RegionCode;
                end;

                If not IsDefaultBilling then begin
                    If not ShiptoAddress.get(NewCustomer."No.", SourceAddressID) then begin
                        ShiptoAddress.init();
                        ShiptoAddress.validate("Customer No.", NewCustomer."No.");
                        ShiptoAddress.validate(Code, SourceAddressID);
                        ShiptoAddress."i95 Created By" := 'i95';
                        ShiptoAddress."i95 Created DateTime" := CurrentDateTime();
                        ShiptoAddress."i95 Creation Source" := ShiptoAddress."i95 Creation Source"::i95;
                        ShiptoAddress.insert();
                    end;

                    IF CustCustomerType = 'Company' then begin
                        ShiptoAddress.Validate(Name, FirstName)
                    end
                    else begin
                        ShiptoAddress.Validate(Name, CopyStr(ShipToFirstName + ' ' + ShipToLastName, 1, 100));
                    end;
                    ShiptoAddress.validate(Address, Address);
                    ShiptoAddress.validate("Address 2", Address2);
                    ShiptoAddress.validate(City, City);
                    ShiptoAddress.validate("Phone No.", PhoneNo);
                    ShiptoAddress.validate(County, RegionCode);
                    ShiptoAddress.validate("Country/Region Code", CountryCode);
                    ShiptoAddress.validate(City, City);
                    ShiptoAddress.validate(County, RegionCode);
                    ShiptoAddress.validate("Post Code", PostCode);
                    ShiptoAddress.validate("Phone No.", PhoneNo);
                    ShiptoAddress.County := RegionCode;
                    SecSourceRecordID := ShiptoAddress.RecordId();
                    ShiptoAddress."i95 Is Default Shipping" := IsDefaultShipping;
                    ShiptoAddress."i95 Last Modification DateTime" := CurrentDateTime();
                    ShiptoAddress."i95 Last Modified By" := copystr(UserId(), 1, 80);
                    ShiptoAddress."i95 Last Sync DateTime" := CurrentDateTime();
                    ShiptoAddress."i95 Last Modification Source" := ShiptoAddress."i95 Last Modification Source"::i95;
                    ShiptoAddress.County := RegionCode;
                    ShiptoAddress.Modify(false);
                end else begin
                    If not ShiptoAddress.get(NewCustomer."No.", 'I95DEFAULT') then begin
                        ShiptoAddress.init();
                        ShiptoAddress.validate("Customer No.", NewCustomer."No.");
                        ShiptoAddress.validate(Code, 'I95DEFAULT');
                        ShiptoAddress."i95 Created By" := 'i95';
                        ShiptoAddress."i95 Created DateTime" := CurrentDateTime();
                        ShiptoAddress."i95 Creation Source" := ShiptoAddress."i95 Creation Source"::i95;
                        ShiptoAddress.insert();
                    end;

                    IF CustCustomerType = 'Company' then begin
                        ShiptoAddress.Validate(Name, FirstName)
                    end
                    else begin
                        ShiptoAddress.Validate(Name, CopyStr(ShipToFirstName + ' ' + ShipToLastName, 1, 100));
                    end;
                    ShiptoAddress.validate(Address, Address);
                    ShiptoAddress.validate("Address 2", Address2);
                    ShiptoAddress.validate(City, City);
                    ShiptoAddress.validate("Phone No.", PhoneNo);
                    ShiptoAddress.validate(County, RegionCode);
                    ShiptoAddress.validate("Country/Region Code", CountryCode);
                    ShiptoAddress.validate(City, City);
                    ShiptoAddress.validate(County, RegionCode);
                    ShiptoAddress.validate("Post Code", PostCode);
                    ShiptoAddress.validate("Phone No.", PhoneNo);
                    ShiptoAddress."E-Mail" := Email;
                    ShiptoAddress.County := RegionCode;
                    SecSourceRecordID := ShiptoAddress.RecordId();
                    ShiptoAddress."i95 Is Default Shipping" := IsDefaultShipping;
                    ShiptoAddress."i95 Last Modification DateTime" := CurrentDateTime();
                    ShiptoAddress."i95 Last Modified By" := copystr(UserId(), 1, 80);
                    ShiptoAddress."i95 Last Sync DateTime" := CurrentDateTime();
                    ShiptoAddress."i95 Last Modification Source" := ShiptoAddress."i95 Last Modification Source"::i95;
                    ShiptoAddress.County := RegionCode;
                    ShiptoAddress.Modify(false);
                end;
            end;
            // Start Company Account
            i95DevSetupG.Get();
            IF i95DevSetupG."i95 Enable Company" = true then begin
                if ContactResultjsonObject.Contains('inputData') then begin
                    ContactResultjsonObject.get('inputData', ContactResultDataJsonToken);
                    ContactResultDataJsonObject := ContactResultDataJsonToken.AsObject();

                    IF ContactResultDataJsonObject.Contains('contactInfo') then begin
                        ContactResultDataJsonObject.get('contactInfo', ContactResultDataJsonToken);
                        //ContactResultDataJsonArray := ContactResultDataJsonToken.AsArray();
                        ResultDataJsonObject := ContactResultDataJsonToken.AsObject();


                        Clear(ContactCustomerType);
                        Clear(TargetParentId);
                        Clear(ContactSourceNo);
                        Clear(ContactEmail);

                        ContactCustomerType := i95WebServiceExecuteCU.ProcessJsonTokenasText('customerType', ResultDataJsonObject);
                        TargetParentId := i95WebServiceExecuteCU.ProcessJsonTokenasCode('targetParentId', ResultDataJsonObject);
                        ContactSourceNo := i95WebServiceExecuteCU.ProcessJsonTokenasCode('sourceId', ResultDataJsonObject);
                        ContactEmail := i95WebServiceExecuteCU.ProcessJsonTokenasText('email', ResultDataJsonObject);
                        ContactFirstName := i95WebServiceExecuteCU.ProcessJsonTokenasText('firstName', ResultDataJsonObject);
                        ContactLastName := i95WebServiceExecuteCU.ProcessJsonTokenasText('lastName', ResultDataJsonObject);


                        NewContact.reset();
                        NewContact.SetCurrentKey("i95 Reference ID");
                        NewContact.SetRange("i95 Reference ID", ContactSourceNo);
                        If not NewContact.FindFirst() then begin
                            NewContact.init();
                            If i95Setup."i95 Contact Nos." <> '' then
                                NewContact.validate("No.", NoSeriesMgt.GetNextNo(i95Setup."i95 Contact Nos.", 0D, true))
                            else
                                NewContact.validate("No.", NoSeriesMgt.GetNextNo(MarketingSetup."Contact Nos.", 0D, true));

                            NewContact."i95 Created By" := 'i95';
                            NewContact."i95 Created DateTime" := CurrentDateTime();
                            NewContact."i95 Creation Source" := NewContact."i95 Creation Source"::i95;
                            NewContact.insert(true);
                        end;


                        NewContact.Validate("i95 Reference ID", ContactSourceNo);
                        NewContact."E-Mail" := ContactEmail;
                        NewContact.Name := copystr(ContactFirstName + ' ' + ContactLastName, 1, 100);
                        NewContact."Company Name" := copystr(FirstName + ' ' + LastName, 1, 100);

                        IF ContactCustomerType = 'User' then
                            NewContact.Validate(Type, NewContact.Type::Person)
                        else
                            IF ContactCustomerType = 'Admin' then
                                NewContact.Validate(Type, NewContact.Type::Company);

                        Clear(CustomerNoL);
                        CustomerL.Reset();
                        CustomerL.SetRange("i95 Reference ID", SourceNo);
                        IF CustomerL.FindFirst() then
                            CustomerNoL := CustomerL."No."
                        else
                            CustomerNoL := NewCustomer."No.";


                        Clear(ContactlinkNoL);

                        ContactL.reset();
                        ContactL.SetCurrentKey("i95 Reference ID");
                        ContactL.SetRange("i95 Reference ID", ContactSourceNo);
                        IF ContactL.FindFirst() then
                            ContactlinkNoL := ContactL."No."
                        else
                            ContactlinkNoL := NewContact."No.";

                        IF (CustomerNoL <> '') and (not (ContactCustomerType = 'Admin')) then begin
                            ContactBusinessRelation.Reset();
                            ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                            ContactBusinessRelation.SetRange("No.", CustomerNoL);
                            IF ContactBusinessRelation.FindFirst() then begin
                                repeat
                                    Clear(CompanyNoL);
                                    CompanyNoL := ContactBusinessRelation."Contact No.";
                                    CompanyContact.Reset();
                                    CompanyContact.SetRange("Company No.", CompanyNoL);
                                    IF CompanyContact.FindFirst() then begin
                                        //IF CompanyContact.GETFILTER(CompanyContact."Company No.") <> '' THEN BEGIN
                                        NewContact."Company No." := CompanyContact."Company No.";
                                        NewContact.Type := NewContact.Type::Person;
                                        // NewContact.GET(NewContact."Company No.");
                                        // InheritCompanyToPersonData(Contact);
                                        NewContact.Modify(false);
                                    END;
                                until ContactBusinessRelation.Next() = 0;
                            end;
                        end;


                        If ContactCustomerType = 'User' then
                            NewContact.Type := NewContact.Type::Person
                        else
                            if ContactCustomerType = 'Admin' then
                                NewContact.Type := NewContact.Type::Company;

                        NewContact.Modify(false);

                        if ResultDataJsonObject.Contains('addresses') then begin
                            ResultDataJsonObject.get('addresses', ContactAddressResultDataJsonToken);
                            ContactAddressResultDataJsonArray := ContactAddressResultDataJsonToken.AsArray();
                        end;
                        foreach ContactAddressResultDataJsonToken in ContactAddressResultDataJsonArray do begin
                            ContactAddressResultDataJsonObject := ContactAddressResultDataJsonToken.AsObject();
                            Clear(ContactFirstName);
                            Clear(ContactLastName);
                            Clear(ContactAddress);
                            Clear(ContactAddress2);
                            Clear(ContactCity);
                            Clear(ContactCountryCode);
                            Clear(ContactPostCode);
                            Clear(ContactIsDefaultBilling);
                            Clear(ContactIsDefaultShipping);
                            Clear(ContactPhoneNo);
                            Clear(ContactAddressSourceNo);


                            ContactFirstName := i95WebServiceExecuteCU.ProcessJsonTokenasText('firstName', ContactAddressResultDataJsonObject);
                            ContactLastName := i95WebServiceExecuteCU.ProcessJsonTokenasText('lastName', ContactAddressResultDataJsonObject);
                            ContactAddress := i95WebserviceExecuteCU.ProcessJsonTokenastext('street', ContactAddressResultDataJsonObject);
                            ContactAddress2 := i95WebserviceExecuteCU.ProcessJsonTokenastext('street2', ContactAddressResultDataJsonObject);
                            ContactCity := i95WebserviceExecuteCU.ProcessJsonTokenasCode('city', ContactAddressResultDataJsonObject);
                            ContactCountryCode := i95WebServiceExecuteCU.ProcessJsonTokenasCode('countryId', ContactAddressResultDataJsonObject);
                            ContactPostCode := i95WebServiceExecuteCU.ProcessJsonTokenasCode('postcode', ContactAddressResultDataJsonObject);
                            ContactIsDefaultBilling := i95WebServiceExecuteCU.ProcessJsonTokenasBoolean('isDefaultBilling', ContactAddressResultDataJsonObject);
                            ContactIsDefaultShipping := i95WebServiceExecuteCU.ProcessJsonTokenasBoolean('isDefaultShipping', ContactAddressResultDataJsonObject);
                            ContactRegionCode := i95WebServiceExecuteCU.ProcessJsonTokenasCode('regionId', ContactAddressResultDataJsonObject);
                            ContactPhoneNo := i95WebServiceExecuteCU.ProcessJsonTokenasText('telephone', ContactAddressResultDataJsonObject);
                            ContactAddressSourceNo := i95WebServiceExecuteCU.ProcessJsonTokenasCode('sourceId', ContactAddressResultDataJsonObject);

                            If ContactIsDefaultBilling then begin
                                NewContact.Name := copystr(ContactFirstName + ' ' + ContactLastName, 1, 100);
                                NewContact.Address := ContactAddress;
                                NewContact."Address 2" := ContactAddress2;
                                NewContact.City := ContactCity;
                                NewContact."E-Mail" := ContactEmail;
                                NewContact."Phone No." := ContactPhoneNo;
                                NewContact.County := ContactRegionCode;
                                NewContact."Country/Region Code" := CountryCode;
                                NewContact."Post Code" := ContactPostCode;
                                NewContact.Modify(false);
                            end;
                            IF not ContactIsDefaultBilling then begin
                                IF not ContactAlternateAddress.get(NewContact."No.", ContactAddressSourceNo) then begin
                                    ContactAlternateAddress.Init();
                                    ContactAlternateAddress.Validate("Contact No.", NewContact."No.");
                                    ContactAlternateAddress.Validate(Code, ContactAddressSourceNo);
                                    ContactAlternateAddress."i95 Created By" := 'i95';
                                    ContactAlternateAddress."i95 Created DateTime" := CurrentDateTime;
                                    ContactAlternateAddress."i95 Creation Source" := ContactAlternateAddress."i95 Creation Source"::i95;
                                    ContactAlternateAddress.Insert();
                                end;
                                ContactAlternateAddress.Validate("Company Name", copystr(ContactFirstName + ' ' + ContactLastName, 1, 100));
                                ContactAlternateAddress.Validate(Address, ContactAddress);
                                ContactAlternateAddress.Validate("Address 2", ContactAddress2);
                                ContactAlternateAddress.Validate(City, ContactCity);
                                ContactAlternateAddress.Validate("Post Code", ContactPostCode);
                                ContactAlternateAddress.Validate(County, ContactRegionCode);
                                ContactAlternateAddress.Validate("Phone No.", ContactPhoneNo);
                                ContactAlternateAddress."E-Mail" := ContactEmail;
                                ContactAlternateAddress.Validate("Country/Region Code", ContactCountryCode);
                                ContactAlternateAddress."i95 Last Modification DateTime" := CurrentDateTime();
                                ContactAlternateAddress."i95 Last Modified By" := copystr(UserId(), 1, 80);
                                ContactAlternateAddress."i95 Last Sync DateTime" := CurrentDateTime();
                                ContactAlternateAddress."i95 Last Modification Source" := ContactAlternateAddress."i95 Last Modification Source"::i95;
                                ContactAlternateAddress."i95 Creation Source" := ContactAlternateAddress."i95 Creation Source"::i95;
                                ContactAlternateAddress.Modify(false);
                            end else begin
                                If not ContactAlternateAddress.get(NewContact."No.", 'I95DEFAULT') then begin
                                    ContactAlternateAddress.init();
                                    ContactAlternateAddress.validate("Contact No.", NewContact."No.");
                                    ContactAlternateAddress.validate(Code, 'I95DEFAULT');
                                    ContactAlternateAddress."i95 Created By" := 'i95';
                                    ContactAlternateAddress."i95 Created DateTime" := CurrentDateTime();
                                    ContactAlternateAddress."i95 Creation Source" := ContactAlternateAddress."i95 Creation Source"::i95;
                                    ContactAlternateAddress.insert();
                                end;

                                ContactAlternateAddress.Validate("Company Name", copystr(ContactFirstName + ' ' + ContactLastName, 1, 100));
                                ContactAlternateAddress.validate(Address, ContactAddress);
                                ContactAlternateAddress.validate("Address 2", ContactAddress2);
                                ContactAlternateAddress.validate(City, ContactCity);
                                ContactAlternateAddress.validate("Phone No.", ContactPhoneNo);
                                ContactAlternateAddress.validate(County, ContactRegionCode);
                                ContactAlternateAddress.validate("Country/Region Code", ContactCountryCode);
                                ContactAlternateAddress.validate("Post Code", ContactPostCode);
                                SecSourceRecordID := ContactAlternateAddress.RecordId();
                                ContactAlternateAddress."i95 Last Modification DateTime" := CurrentDateTime();
                                ContactAlternateAddress."i95 Last Modified By" := copystr(UserId(), 1, 80);
                                ContactAlternateAddress."i95 Last Sync DateTime" := CurrentDateTime();
                                ContactAlternateAddress."i95 Last Modification Source" := ContactAlternateAddress."i95 Last Modification Source"::i95;
                                ContactAlternateAddress.County := RegionCode;
                                ContactAlternateAddress.Modify(false);
                            end;
                        end;

                        ContactBusinessRelation.Reset();
                        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
                        ContactBusinessRelation.SetRange("No.", CustomerNoL);
                        ContactBusinessRelation.SetRange("Contact No.", ContactlinkNoL);
                        IF not ContactBusinessRelation.FindFirst() then begin
                            ContactBusinessRelation.Init();
                            ContactBusinessRelation."Contact No." := NewContact."No.";
                            ContactBusinessRelation."Business Relation Code" := 'CUST';
                            ContactBusinessRelation."Link to Table" := ContactBusinessRelation."Link to Table"::Customer;
                            ContactBusinessRelation."No." := NewCustomer."No.";
                            ContactBusinessRelation."Business Relation Description" := 'Customer';
                            ContactBusinessRelation."Contact Name" := NewContact.Name;
                            ContactBusinessRelation.Insert();
                        end else begin
                            ContactL.Get(ContactlinkNoL);
                            ContactBusinessRelation."Contact No." := ContactL."No.";
                            ContactBusinessRelation."Business Relation Code" := 'CUST';
                            ContactBusinessRelation."Link to Table" := ContactBusinessRelation."Link to Table"::Customer;
                            ContactBusinessRelation."No." := CustomerNoL;
                            ContactBusinessRelation."Business Relation Description" := 'Customer';
                            ContactBusinessRelation."Contact Name" := ContactL.Name;
                            ContactBusinessRelation.Modify();
                        end;
                        NewContact.Seti95APIUpdateCall(true);
                        NewContact."i95 Last Modification DateTime" := CurrentDateTime();
                        NewContact."i95 Last Modified By" := copystr(UserId(), 1, 80);
                        NewContact."i95 Last Modification Source" := NewContact."i95 Last Modification Source"::i95;
                        NewContact."i95 Reference ID" := ContactSourceNo;
                        NewContact."i95 Enable Forward Sync" := true;
                        NewContact."i95 Last Sync DateTime" := CurrentDateTime();
                        NewContact.Modify(false);
                    end;
                end;
            end;

            SourceRecordID := NewCustomer.RecordId();
            NewCustomer.validate("i95 ShiptoAddress Code", ShiptoAddress.Code);
            NewCustomer.Seti95APIUpdateCall(true);
            IF ContactCustomerType = 'Admin' then begin
                NewCustomer.Validate("Primary Contact No.", NewContact."No.");
            end;
            NewCustomer."i95 Last Modification DateTime" := CurrentDateTime();
            NewCustomer."i95 Last Modified By" := copystr(UserId(), 1, 80);
            NewCustomer."i95 Last Sync DateTime" := CurrentDateTime();
            NewCustomer."i95 Sync Status" := NewCustomer."i95 Sync Status"::"Waiting for Response";
            NewCustomer."i95 Last Modification Source" := NewCustomer."i95 Last Modification Source"::i95;
            /* IF i95DevSetupG."i95 Enable Company" = true then begin
                 IF CustCustomerType = 'Customer' then
                     NewCustomer."i95 Reference ID" := SourceNo
                 else
                     if CustCustomerType = 'Company' then
                         NewCustomer."i95 Reference ID" := CompanySourceNo;
             end else begin*/
            NewCustomer."i95 Reference ID" := SourceNo;
            //end;

            NewCustomer.County := RegionCode;
            NewCustomer."E-Mail" := Email;
            NewCustomer.Modify(false);
        end else
            i95SyncLogEntry.UpdateSyncLogEntry(SyncStatus::"No Response", LogStatus::Cancelled, i95SyncLogEntry."Http Response Code", i95SyncLogEntry."Response Result", i95SyncLogEntry."Response Message", i95SyncLogEntry."Message ID", i95SyncLogEntry."i95 Source ID", i95SyncLogEntry."Status ID", SyncSource::i95);

    end;

    Procedure GetCustomerValues(Var SourceRecordIDP: RecordId; Var CustomerNoP: code[20]; Var CusdescriptionP: Text; Var SecSourceRecordIDP: RecordId; Var i95SyncLogEntryP: Record "i95 Sync Log Entry"; Var SourceIDP: Code[20]; var MessageIDP: Integer; var ContactNo: Code[20])
    begin
        SourceRecordIDP := SourceRecordID;
        CustomerNoP := NewCustomer."No.";
        CusdescriptionP := NewCustomer.Name;
        SecSourceRecordIDP := SecSourceRecordID;
        i95SyncLogEntryP := i95SyncLogEntry;
        SourceIDP := SourceID;
        MessageIDP := MessageID;
        ContactNo := NewContact."No.";
    end;

    procedure SetCustomerValues(var i95WebServiceExecuteCUP: Codeunit "i95 Webservice Execute"; var NoSeriesMgtP: Codeunit NoSeriesManagement; var SourceRecordIDP: RecordId; var SecSourceRecordIDP: RecordId; var WebServiceJsonObjectP: JsonObject;
        var ResultDataJsonArrayP: JsonArray; var ResultJsonTokenP: JsonToken; var ResultDataJsonTokenP: JsonToken; var ResultDataJsonObjectP: JsonObject; var HttpReasonCodeP: text[100];
        var ResponseResultTextP: Text[30]; var ResponseMessageTextP: Text[100]; i95SyncLogEntryP: Record "i95 Sync Log Entry";
       Var i95SetupP: Record "i95 Setup"; var SyncSourceP: Option "","Business Central",i95; var SalesReceivablesSetupP: Record "Sales & Receivables Setup")
    begin
        i95WebServiceExecuteCU := i95WebServiceExecuteCUP;
        NoSeriesMgt := NoSeriesMgtP;
        SourceRecordID := SourceRecordIDP;
        WebServiceJsonObject := WebServiceJsonObjectP;
        ResultDataJsonArray := ResultDataJsonArrayP;
        ResultJsonToken := ResultJsonTokenP;
        ResultDataJsonToken := ResultDataJsonTokenP;
        ResultDataJsonObject := ResultDataJsonObjectP;
        HttpReasonCode := HttpReasonCodeP;
        ResponseResultText := ResponseResultTextP;
        ResponseMessageText := ResponseMessageTextP;
        i95SyncLogEntry := i95SyncLogEntryP;
        i95Setup := i95SetupP;
        SyncSource := SyncSourceP;
        SalesReceivablesSetup := SalesReceivablesSetupP;

    end;

    var
        NewCustomer: Record customer;
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
        TargetID: Code[20];
        StatusID: Option "Request Received","Request Inprocess","Error","Response Received","Response Transferred","Complete";
        LogStatus: Option " ",New,"In-Progress",Completed,Error,Cancelled;
        SyncStatus: Option "Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete","No Response";
        HttpReasonCode: text[100];
        ResponseResultText: Text[30];
        ResponseMessageText: Text[100];
        i95SyncLogEntry: Record "i95 Sync Log Entry";
        i95Setup: Record "i95 Setup";

        SyncSource: Option "","Business Central",i95;
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        ContactAddressResultDataJsonArray: JsonArray;
        ContactAddressResultJsonToken: JsonToken;
        ContactAddressResultDataJsonToken: JsonToken;
        ContactAddressResultDataJsonObject: JsonObject;

        ContactResultDataJsonArray: JsonArray;
        ContactResultJsonToken: JsonToken;
        ContactResultDataJsonToken: JsonToken;
        ContactResultDataJsonObject: JsonObject;
        NewContact: Record Contact;
}