tableextension 70031 "i95 Sales CreditMemoheader Ext" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(70001; "i95 Sync Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Sync Status';
            OptionMembers = "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete";
            OptionCaption = 'InComplete Data,Waiting for Sync,Waiting for Response,Waiting for Acknowledgement,Sync Complete';
            Editable = false;
        }
        field(70002; "i95 Last Sync DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Sync Date/Time';
            Editable = false;
        }
        field(70003; "i95 Reference ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Reference ID';
            Editable = false;
        }
        field(70004; "i95 Created Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date Time';
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


}