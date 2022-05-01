Tableextension 70002 "i95 Sales Shipment Header Ext" extends "Sales Shipment Header"
{
    fields
    {
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
            Caption = 'Last Sync Date/Time';
            Editable = false;
        }
        field(70013; "i95 Reference ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Reference ID';
            Editable = false;
        }
        field(70014; "i95 Created Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date Time';
            Editable = false;
        }
        field(70015; "i95 Sync Message"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Sync Message';
            Editable = false;
        }
    }
    keys
    {
        key(Key2; "i95 Reference ID")
        { }
        key(key3; "i95 Sync Status")
        { }
    }
    /* procedure Updatei95SyncStatus(SyncStatus: Option "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete"; ReferenceID: Code[20])
     begin
         "i95 Last Sync DateTime" := CurrentDateTime();
         "i95 Sync Status" := SyncStatus;

         if ReferenceID <> '' then
             "i95 Reference ID" := ReferenceID;

         Modify();
     end;*/

    procedure i95UpdateSyncMessageField()
    var
        ShippingAgentMapping: Record "i95 Shipping Agent Mapping";
        i95ShippingAgentErrorTxt: Label 'Shipping Agent Mapping not exist for  %1';
    begin
        Rec."i95 Sync Message" := '';

        //Check Mapping Fields
        If (Rec."Shipping Agent Code" <> '') or (Rec."Shipping Agent Service Code" <> '') then begin
            ShippingAgentMapping.Reset();
            ShippingAgentMapping.SetRange(ShippingAgentMapping."BC Shipping Agent Code", Rec."Shipping Agent Code");
            If Rec."Shipping Agent Service Code" <> '' then
                ShippingAgentMapping.setrange(ShippingAgentMapping."BC Shipping Agent Service Code", Rec."Shipping Agent Service Code");
            If ShippingAgentMapping.IsEmpty() then
                Rec."i95 Sync Message" := copystr(StrSubstNo(i95ShippingAgentErrorTxt, Rec."Shipping Agent Code"), 1, 250);
        end;
        Modify();
    end;

    procedure i95CheckMappingData()
    var
        ShippingAgentMapping: Record "i95 Shipping Agent Mapping";
        i95ShippingAgentErrorTxt: Label 'Shipping Agent Mapping not exist for  %1';
    begin
        if (Rec."Shipping Agent Code" <> '') or (Rec."Shipping Agent Service Code" <> '') then begin
            ShippingAgentMapping.Reset();
            ShippingAgentMapping.SetRange(ShippingAgentMapping."BC Shipping Agent Code", Rec."Shipping Agent Code");
            If Rec."Shipping Agent Service Code" <> '' then
                ShippingAgentMapping.setrange(ShippingAgentMapping."BC Shipping Agent Service Code", Rec."Shipping Agent Service Code");
            If ShippingAgentMapping.IsEmpty() then begin
                Rec."i95 Sync Message" := copystr(StrSubstNo(i95ShippingAgentErrorTxt, Rec."Shipping Agent Code"), 1, 250);
                Modify();
            end;
        end;
    end;

    procedure Updatei95Fields()
    begin
        if "Shipping Agent Code" = '' then begin
            "i95 Last Sync DateTime" := CurrentDateTime();
            "i95 Sync Status" := "i95 Sync Status"::"InComplete Data";
            modify();
        end else
            if ((xrec."Shipping Agent Code" <> rec."Shipping Agent Code") or (xrec."Shipping Agent Service Code" <> rec."Shipping Agent Service Code") or
                (xrec."Package Tracking No." <> rec."Package Tracking No.")) then begin
                //  i95CheckMappingData();
                "i95 Last Sync DateTime" := CurrentDateTime();
                if "i95 Sync Message" = '' then begin
                    i95EntityMapping.Reset();
                    IF i95EntityMapping.FindSet() then;
                    IF i95EntityMapping."Allow Shipment Oubound Sync" = true then begin
                        "i95 Sync Status" := "i95 Sync Status"::"Waiting for Sync"
                    end;
                end else
                    "i95 Sync Status" := "i95 Sync Status"::"InComplete Data";
                modify();
            end;
    end;

    var
        i95EntityMapping: Record "i95 Entity Mapping";
}