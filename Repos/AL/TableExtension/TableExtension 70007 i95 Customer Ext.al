Tableextension 70007 "i95 Customer Ext" extends Customer
{
    fields
    {
        field(70005; "i95 Created By"; Code[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Created By';
            Editable = false;
        }
        field(70006; "i95 Created DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created DateTime';
            Editable = false;
        }

        field(70007; "i95 Creation Source"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Creation Source';
            OptionMembers = " ","Business Central","i95";
            OptionCaption = ' ,"Business Central","i95Dev"';
            Editable = false;
        }
        field(70008; "i95 Last Modified By"; Code[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Last Modified By';
            Editable = false;
        }
        field(70009; "i95 Last Modification DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Modification DateTime';
            Editable = false;
        }
        field(70010; "i95 Last Modification Source"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ","Business Central","i95";
            OptionCaption = ' ,"Business Central","i95Dev"';
            Caption = 'Last Modification Source';
            Editable = false;
        }
        field(70011; "i95 Sync Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Sync Status';
            OptionMembers = "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete";
            OptionCaption = 'InComplete Data,Waiting for Sync,Waiting for Response,Waiting for Acknowledgement,Sync Complete';
            Editable = false;
        }
        field(70012; "i95 Last Sync DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Sync DateTime';
            Editable = false;
        }
        field(70013; "i95 Reference ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Reference ID';
            Editable = false;
        }
        field(70014; "i95 ShiptoAddress Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev ShiptoAddress Code';
            Editable = false;
        }
        field(70015; "i95 Customer Type"; Option)
        {
            Caption = 'Customer Type';
            DataClassification = CustomerContent;
            OptionMembers = " ",Customer,Company;
            OptionCaption = '  ,Customer,Company';
        }

    }

    keys
    {
        key(Key2; "i95 Reference ID")
        { }
        key(key3; "i95 Sync Status")
        { }
    }

    trigger OnBeforeInsert()
    begin
        "i95 Created By" := copystr(UserId(), 1, 80);
        "i95 Created DateTime" := CurrentDateTime();
        "i95 Creation Source" := "i95 Creation Source"::"Business Central";
        i95EntityMapping.Reset();
        IF i95EntityMapping.FindSet() then;
        IF i95EntityMapping."Allow Customer Oubound Sync" = true then begin
            If i95MandatoryFieldsUpdated() then
                "i95 Sync Status" := "i95 Sync Status"::"Waiting for Sync";
        end;
    end;

    trigger OnBeforeModify()
    Begin
        Createi95DefaultShiptoAddress();

        If (not UpdatedFromi95) and (i95MandatoryFieldsUpdated()) then begin
            "i95 Last Modification DateTime" := CurrentDateTime();
            "i95 Last Modified By" := copystr(UserId(), 1, 80);
            "i95 Last Sync DateTime" := CurrentDateTime();

            i95EntityMapping.Reset();
            IF i95EntityMapping.FindSet() then;
            IF i95EntityMapping."Allow Customer Oubound Sync" = true then
                "i95 Sync Status" := "i95 Sync Status"::"Waiting for Sync";

            "i95 Last Modification Source" := "i95 Last Modification Source"::"Business Central";
            ContactBusinessRelation.Reset();
            ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
            ContactBusinessRelation.SetRange("No.", Rec."No.");
            IF ContactBusinessRelation.FindSet() then begin
                ContactL.Reset();
                ContactL.SetRange("Company No.", ContactBusinessRelation."Contact No.");
                IF ContactL.FindFirst() then
                    repeat
                        ContactV.Reset();
                        ContactV.SetRange("No.", ContactL."No.");
                        ContactV.SetRange(Type, ContactV.Type::Company);
                        IF ContactV.FindFirst() then begin
                            ContactV."i95 Synced" := true;
                            ContactV.Modify(false);
                        end;
                    until ContactL.Next() = 0;

            End;
        end;
    end;

    procedure Updatei95SyncStatus(SyncSource: Option " ","Business Central","i95"; SyncStatus: Option "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete"; ReferenceID: Code[20])
    begin
        "i95 Last Modification DateTime" := CurrentDateTime();
        "i95 Last Modified By" := copystr(UserId(), 1, 80);
        "i95 Last Sync DateTime" := CurrentDateTime();
        "i95 Sync Status" := SyncStatus;
        "i95 Last Modification Source" := SyncSource;

        if ReferenceID <> '' then
            "i95 Reference ID" := ReferenceID;
        Modify(false);

    end;

    procedure Updatei95SyncStatusforSyncComplete(SyncSource: Option " ","Business Central","i95"; SyncStatus: Option "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete")
    begin
        "i95 Last Modification DateTime" := CurrentDateTime();
        "i95 Last Modified By" := copystr(UserId(), 1, 80);
        "i95 Last Sync DateTime" := CurrentDateTime();
        "i95 Sync Status" := "i95 Sync Status"::"Sync Complete";
        "i95 Last Modification Source" := SyncSource;
        Modify(false);
    end;

    procedure Seti95APIUpdateCall(APICall: Boolean)
    begin
        UpdatedFromi95 := APICall;
    end;

    procedure i95MandatoryFieldsUpdated(): Boolean
    begin
        If (Rec.Name = '') or (Rec."E-Mail" = '') or (Rec."i95 Customer Type" = Rec."i95 Customer Type"::" ") then begin
            "i95 Sync Status" := "i95 Sync Status"::"InComplete Data";
            exit(false);
        end else
            exit(true);
    end;

    procedure Createi95DefaultShiptoAddress()
    var
        ShiptoAddress: Record "Ship-to Address";
    begin
        if (Name = xRec.Name) and (Address = xRec.Address) and ("Address 2" = xRec."Address 2") and (City = xRec.City) and
            ("Post Code" = xRec."Post Code") and ("Country/Region Code" = xRec."Country/Region Code") and (County = xRec.County) and ("Phone No." = xRec."Phone No.") and
            ("E-Mail" = xRec."E-Mail") then
            exit;

        If not ShiptoAddress.Get("No.", 'I95DEFAULT') then begin
            ShiptoAddress.Init();
            ShiptoAddress."Customer No." := "No.";
            ShiptoAddress.Code := 'I95DEFAULT';
            ShiptoAddress.Insert();
        end;

        ShiptoAddress.Name := Name;
        ShiptoAddress.Address := Address;
        ShiptoAddress."Address 2" := "Address 2";
        ShiptoAddress.City := City;
        ShiptoAddress."Post Code" := "Post Code";
        ShiptoAddress."Country/Region Code" := "Country/Region Code";
        ShiptoAddress.County := County;
        ShiptoAddress."Phone No." := "Phone No.";
        ShiptoAddress."E-Mail" := "E-Mail";
        ShiptoAddress."i95 Is Default Shipping" := not i95IsDefaultShippingFound();

        if ShiptoAddress."i95 Created By" = '' then begin
            ShiptoAddress."i95 Created By" := copystr(UserId(), 1, 80);
            ShiptoAddress."i95 Created DateTime" := CurrentDateTime();
            ShiptoAddress."i95 Creation Source" := ShiptoAddress."i95 Creation Source"::"Business Central";
        end else begin
            ShiptoAddress."i95 Last Modification DateTime" := CurrentDateTime();
            ShiptoAddress."i95 Last Modified By" := copystr(UserId(), 1, 80);
            ShiptoAddress."i95 Last Sync DateTime" := CurrentDateTime();
            ShiptoAddress."i95 Last Modification Source" := ShiptoAddress."i95 Last Modification Source"::"Business Central";
        end;
        ShiptoAddress.Modify();
    end;

    procedure i95IsDefaultShippingFound(): Boolean
    var
        ShipToAddress: Record "Ship-to Address";
    begin
        ShipToAddress.Reset();
        ShipToAddress.SetRange("Customer No.", "No.");
        ShipToAddress.SetFilter(Code, '<>%1', 'I95DEFAULT');
        ShipToAddress.SetRange("i95 Is Default Shipping", true);
        Exit(not ShipToAddress.IsEmpty())
    end;

    var
        UpdatedFromi95: Boolean;
        i95EntityMapping: Record "i95 Entity Mapping";
        ContactL: Record Contact;
        Customer: Record Customer;
        ContactBusinessRelation: Record "Contact Business Relation";
        ContactV: Record Contact;

}