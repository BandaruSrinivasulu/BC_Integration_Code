tableextension 70029 "i95 Finance Charge Extension" extends "Issued Fin. Charge Memo Header"
{

    // Add changes to table fields here
    fields
    {
        field(70005; "i95 Sync Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Sync Status';
            OptionMembers = "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete";
            OptionCaption = 'InComplete Data,Waiting for Sync,Waiting for Response,Waiting for Acknowledgement,Sync Complete';
            Editable = true;
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
    }

    keys
    {
        key(Key2; "i95 Reference ID")
        { }
    }

    var
        i95EntityMapping: Record "i95 Entity Mapping";
}