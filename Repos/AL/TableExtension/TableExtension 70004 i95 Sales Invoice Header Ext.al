Tableextension 70004 "i95 Sales Invoice Header Ext" extends "Sales Invoice Header"
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
    }
    keys
    {
        key(Key2; "i95 Reference ID")
        { }
        key(key3; "i95 Sync Status")
        { }
    }
    /*  procedure Updatei95SyncStatus(SyncStatus: Option "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete"; ReferenceID: Code[20])
      begin
          "i95 Last Sync DateTime" := CurrentDateTime();
          "i95 Sync Status" := SyncStatus;

          if ReferenceID <> '' then
              "i95 Reference ID" := ReferenceID;

          Modify()
      end;*/
}