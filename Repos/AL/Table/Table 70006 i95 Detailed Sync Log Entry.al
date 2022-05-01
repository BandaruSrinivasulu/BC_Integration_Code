Table 70006 "i95 Detailed Sync Log Entry"
{
    Caption = 'i95 Detailed Sync Log Entry';
    DrillDownPageId = "i95 Detailed Sync Log Entries";
    fields
    {
        field(1; "Entry No"; integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No';
            AutoIncrement = true;
        }
        field(2; "Sync Log Entry No"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Sync Log Entry No';
        }
        field(3; "API Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'API Type';
            OptionMembers = " ","Product","Customer","CustomerGroup","Inventory","SalesOrder","Shipment","Invoice","TierPrices","CancelOrder","EditOrder","TaxBusPostingGroup","TaxProductPostingGroup","TaxPostingSetup","ConfigurableProduct","CustomerDiscountGroup","ItemDiscountGroup","DiscountPrice","ShippingAgent","PaymentMethod","EntityManagement","PaymentJournal","PaymentTerm","SalesQuote","CancelQuote","AccountRecievable","financeCharge","SalesPerson","SalesReturn","SalesCreditMemo","Warehouse","ProductAttributeMapping","SchedulerId","ReaccureToken";
            OptionCaption = ' ,Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerId,ReaccureToken';
        }
        field(4; "Sync Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Sync Status';
            OptionMembers = "Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete","No Response";
            OptionCaption = 'Waiting for Sync,Waiting for Response,Waiting for Acknowledgement,Sync Complete,No Response';
        }
        field(5; "Log Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Log Status';
            OptionMembers = " ",New,"In-Progress",Completed,Error,Cancelled;
            OptionCaption = ' ,New,In-Progress,Completed,Error,Cancelled';
        }
        field(6; "Http Response Code"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Http Response Code';
        }
        field(7; "API Response Result"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Response Result';
        }
        field(8; "API Response Message"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Response Message';
        }
        field(9; "Source ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Source ID';
            ObsoleteState = Removed;
            ObsoleteReason = 'Data Type changed to Code[20]';
        }
        field(10; "Message ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Message ID';
        }
        field(11; "Message Text"; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Message';
        }
        field(12; "Status ID"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Status ID';
            OptionMembers = "","Request Received","Request Inprocess","Error","Response Received","Response Transferred","Complete";
            OptionCaption = ' ,Request Received,Request Inprocess,Error,Response Received,Response Transferred,Complete';
        }
        field(13; "Target ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Target ID';
        }
        field(14; "Sync Source"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Sync Source';
            OptionMembers = "","Business Central",i95;
            OptionCaption = ' ,Business Central,i95Dev';
        }
        field(15; "Source Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'Source Record ID';
        }
        field(16; "Error Message"; Text[300])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Message';
        }
        field(17; "Table ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table ID';
        }
        field(18; "Table Caption"; Text[250])
        {
            Caption = 'Table Caption';
            FieldClass = FlowField;
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table), "Object ID" = FIELD("Table ID")));
        }
        field(19; "Field 1"; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Field 1';
        }
        field(20; "Field 2"; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Field 2';
        }
        field(21; "Field 3"; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Field 3';
        }
        field(22; "i95 Source Id"; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Source ID';
        }
    }

    keys
    {
        key(Key1; "Entry No")
        { }
        key(Key2; "Sync Log Entry No")
        { }
        key(Key3; "API Type", "Sync Log Entry No", "Sync Status")
        { }
        key(Key4; "Source Record ID")
        { }
    }

    procedure InsertDetailSyncLogEntry(APIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerId,ReaccureToken;
        SyncStatus: Option "Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete","No Response";
        LogStatus: Option " ",New,"In Progress",Completed,Error,Cancelled; SyncSource: Option "","Business Central",i95; SyncLogEntryNo: Integer;
        FieldData1: Text[150]; FieldData2: Text[150]; FieldData3: Text[150]; SourceRecordID: RecordId; TableId: Integer);
    var
        SyncLogEntry: Record "i95 Sync Log Entry";
        DetailLedEntries: Record "i95 Detailed Sync Log Entry";
        EntryNo: Integer;
    begin
        DetailLedEntries.Reset();
        If DetailLedEntries.FindLast() then
            EntryNo := DetailLedEntries."Entry No"
        else
            EntryNo := 0;

        if SyncLogEntry.Get(SyncLogEntryNo) then begin
            init();
            "Entry No" := EntryNo + 1;
            "Sync Log Entry No" := SyncLogEntryNo;
            "Http Response Code" := SyncLogEntry."Http Response Code";
            "Message ID" := SyncLogEntry."Message ID";
            "i95 Source ID" := SyncLogEntry."i95 Source ID";
            "API Type" := APIType;
            "Sync Status" := SyncStatus;
            "Log Status" := LogStatus;
            "Sync Source" := SyncSource;
            "Field 1" := FieldData1;
            "Field 2" := FieldData2;
            "Field 3" := FieldData3;
            "Source Record ID" := SourceRecordID;
            "Table ID" := TableId;
            Insert();
        end;
    end;

    procedure UpdateSyncLogEntry(SyncStatus: Option "Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete","No Response";
         LogStatus: Option " ",New,"In Progress",Completed,Error,Cancelled; HttpReasonCode: Text; APIResponseResultText: Text; APIResponseMessage: Text;
         SourceId: Code[20]; MessageId: Integer; MessageTxt: Text; StatusID: Integer; TargetID: Code[20]; SyncSource: Option "","Business Central",i95);
    begin
        "Sync Status" := SyncStatus;
        "Log Status" := LogStatus;
        "Http Response Code" := copystr(HttpReasonCode, 1, 100);
        "API Response Result" := copystr(APIResponseResultText, 1, 30);
        "API Response Message" := copystr(APIResponseMessage, 1, 100);
        "i95 Source ID" := SourceId;
        "Message ID" := MessageId;
        "Target ID" := TargetID;
        "Message Text" := copystr(MessageTxt, 1, 100);
        "Status ID" := StatusID;
        "Sync Source" := SyncSource;
        Modify();
    end;

    procedure UpdateErrorMessage(ErrorText: Text[300])
    begin
        "Error Message" := ErrorText;
        Modify();
    end;
}