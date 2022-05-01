Tableextension 70003 "i95 Sales Shipment Line Ext" extends "Sales Shipment Line"
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
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';
        }
        field(70012; "i95 Last Sync DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Sync Date/Time';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';
        }
        field(70013; "i95 Reference ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Reference ID';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';
        }
    }
}