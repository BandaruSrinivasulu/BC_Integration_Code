tableextension 70032 "I95 Location Extension" extends Location
{
    fields
    {
        field(70005; "i95 Sync Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Sync Status';
            OptionMembers = "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete";
            OptionCaption = 'InComplete Data,Waiting for Sync,Waiting for Response,Waiting for Acknowledgement,Sync Complete';
            Editable = false;
        }
        field(70006; "i95 Last Sync DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Sync Date/Time';
            Editable = false;
        }
        field(70007; "i95 Reference ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Reference ID';
            Editable = false;
        }
        field(70008; "i95 Created By"; Code[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Created By';
            Editable = false;
        }
        field(70009; "i95 Created DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created DateTime';
            Editable = false;
        }

        field(70010; "i95 Creation Source"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Creation Source';
            OptionMembers = " ","Business Central","i95";
            OptionCaption = ' ,"Business Central","i95Dev"';
            Editable = false;
        }

    }
    keys
    {
        key(Key2; "i95 Reference ID")
        { }
    }
    trigger OnBeforeInsert()
    begin
        "i95 Created By" := copystr(UserId(), 1, 80);
        "i95 Created DateTime" := CurrentDateTime();
        "i95 Creation Source" := "i95 Creation Source"::"Business Central";
        i95EntityMapping.Reset();
        //IF i95EntityMapping.FindSet() then;
        //  IF i95EntityMapping."Allow Warehouse Ob Sync" = true then begin
        //If i95MandatoryFieldsUpdated() then
        "i95 Sync Status" := "i95 Sync Status"::"Waiting for Sync";
        // end;
    end;

    trigger OnBeforeModify()
    begin
        //If (not UpdatedFromi95) and (i95MandatoryFieldsUpdated()) then begin
        If (i95MandatoryFieldsUpdated()) then begin
            "i95 Last Sync DateTime" := CurrentDateTime();
            //  i95EntityMapping.Reset();
            // IF i95EntityMapping.FindSet() then;
            // IF i95EntityMapping."Allow Warehouse Ob Sync" = true then
            "i95 Sync Status" := "i95 Sync Status"::"Waiting for Sync";
        end;
    end;

    procedure Seti95APIUpdateCall(APICall: Boolean)
    begin
        UpdatedFromi95 := APICall;
    end;

    procedure i95MandatoryFieldsUpdated(): Boolean
    begin
        If (Rec.Code = '') or (Rec.Name = '') then begin
            "i95 Sync Status" := "i95 Sync Status"::"InComplete Data";
            exit(false);
        end else
            exit(true);
    end;

    procedure Updatei95SyncStatus(SyncSource: Option " ","Business Central","i95"; SyncStatus: Option "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete"; ReferenceID: Code[20])
    begin

        "i95 Sync Status" := SyncStatus;
        if ReferenceID <> '' then
            "i95 Reference ID" := ReferenceID;
        Modify(false);

    end;

    var
        i95EntityMapping: Record "i95 Entity Mapping";
        UpdatedFromi95: Boolean;



}