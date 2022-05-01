Tableextension 70006 "i95 Customer Ledger Ext" extends "Cust. Ledger Entry"
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
            /* ObsoleteState = Removed;
             ObsoleteReason = 'Field not in use';*/
        }
        field(70006; "i95 Last Sync DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Sync Date/Time';
            Editable = false;
            /*ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';*/
        }
        field(70007; "i95 Reference ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Reference ID';
            Editable = false;
            /* ObsoleteState = Removed;
             ObsoleteReason = 'Field not in use';*/
        }
    }

    keys
    {
        key(Key2; "i95 Reference ID")
        { }
    }
    trigger OnBeforeInsert()
    begin
        /* i95EntityMapping.Reset();
         IF i95EntityMapping.FindSet() then;
         IF i95EntityMapping."Allow AcountRecievable Ob Sync" = true then begin
             end;*/
        "i95 Sync Status" := "i95 Sync Status"::"Waiting for Sync";

    end;

    procedure Updatei95SyncStatus(SyncStatus: Option "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete"; ReferenceID: Code[20])
    begin
        "i95 Last Sync DateTime" := CurrentDateTime();
        "i95 Sync Status" := SyncStatus;

        if ReferenceID <> '' then
            "i95 Reference ID" := ReferenceID;
        Modify();
    end;

    var
        i95EntityMapping: Record "i95 Entity Mapping";
}