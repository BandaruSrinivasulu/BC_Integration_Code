tableextension 70021 "i95 Customer Disc Group Ext" extends "Customer Discount Group"
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
        field(70007; "i95 Last Modification DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Modification DateTime';
            Editable = false;
        }
        field(70008; "i95 Sync Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Sync Status';
            OptionMembers = "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete";
            OptionCaption = 'InComplete Data,Waiting for Sync,Waiting for Response,Waiting for Acknowledgement,Sync Complete';
            Editable = false;
        }
        field(70009; "i95 Last Sync DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Sync DateTime';
            Editable = false;
        }
        field(70010; "i95 Reference ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Reference ID';
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
    trigger OnbeforeInsert()
    begin
        "i95 Created By" := copystr(UserId(), 1, 80);
        "i95 Created DateTime" := CurrentDateTime();

        i95EntityMapping.Reset();
        IF i95EntityMapping.FindSet() then;
        IF i95EntityMapping."Allow CustDiscG Oubound Sync" = true then begin
            If i95MandatoryFieldsExists() then
                "i95 Sync Status" := "i95 Sync Status"::"Waiting for Sync";
        end;
    end;

    trigger OnBeforeModify()
    begin
        if (not UpdatedFromi95) and (i95MandatoryFieldsExists()) then begin
            "i95 Last Modification DateTime" := CurrentDateTime();
            "i95 Last Sync DateTime" := CurrentDateTime();

            i95EntityMapping.Reset();
            IF i95EntityMapping.FindSet() then;
            IF i95EntityMapping."Allow CustDiscG Oubound Sync" = true then
                "i95 Sync Status" := "i95 Sync Status"::"Waiting for Sync";
        end;
    end;

    procedure Updatei95SyncStatus(SyncSource: Option " ","Business Central","i95"; SyncStatus: Option "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete"; ReferenceID: Code[20])
    begin
        "i95 Last Modification DateTime" := CurrentDateTime();
        "i95 Last Sync DateTime" := CurrentDateTime();
        "i95 Sync Status" := SyncStatus;
        "i95 Reference ID" := ReferenceID;
        Modify(false);
    end;

    procedure i95MandatoryFieldsExists(): Boolean
    begin
        If (Rec.Code = '') or (Rec.Description = '') then begin
            rec."i95 Sync Status" := rec."i95 Sync Status"::"InComplete Data";
            exit(false);
        end else
            exit(true);
    end;

    var
        UpdatedFromi95: Boolean;
        i95EntityMapping: Record "i95 Entity Mapping";

}