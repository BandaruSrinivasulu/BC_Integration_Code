Table 70003 "i95 Sync Log Entry"
{
    Caption = 'i95Dev Sync Log';
    fields
    {
        field(1; "Entry No"; integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No';
            AutoIncrement = true;
        }
        field(2; "Sync DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Sync Date/Time';
        }
        field(3; "API Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'API Type';
            OptionMembers = " ","Product","Customer","CustomerGroup","Inventory","SalesOrder","Shipment","Invoice","TierPrices","CancelOrder","EditOrder","TaxBusPostingGroup","TaxProductPostingGroup","TaxPostingSetup","ConfigurableProduct","CustomerDiscountGroup","ItemDiscountGroup","DiscountPrice","ShippingAgent","PaymentMethod","EntityManagement","PaymentJournal","PaymentTerm","SalesQuote","CancelQuote","AccountRecievable","financeCharge","SalesPerson","SalesReturn","SalesCreditMemo","Warehouse","ProductAttributeMapping","SchedulerID","ReaccureToken";
            OptionCaption = ' ,Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerID,ReaccureToken';
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
        field(7; "Response Result"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Response Result';
        }
        field(8; "Response Message"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Response Message';
        }
        field(9; "Message ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Message ID';
        }
        field(10; "Source ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Source ID';
            ObsoleteState = Removed;
            ObsoleteReason = 'Data Type changed to Code[20]';
        }
        field(11; "i95 Sync Request"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Sync Request Content';
        }
        field(12; "i95 Sync Result"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Sync Result Content';
        }
        field(13; "i95 Response Request"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Response Request Content';
        }
        field(14; "i95 Response Result"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Response Result Content';
        }
        field(15; "i95 Acknowledgement Request"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Acknowledgement Request Content';
        }
        field(16; "i95 Acknowledgement Result"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Acknowledgement Result Content';
        }
        field(17; "Status ID"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Status ID';
            OptionMembers = "","Request Received","Request Inprocess","Error","Response Received","Response Transferred","Complete";
            OptionCaption = ' ,Request Received,Request Inprocess,Error,Response Received,Response Transferred,Complete';
        }
        field(18; "Sync Source"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Sync Source';
            OptionMembers = "","Business Central",i95;
            OptionCaption = ' ,Business Central,i95Dev';
        }
        field(19; "Source Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'Source Record ID';
        }
        field(20; "Secondary Source Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'Secondary Source Record ID';
        }
        field(21; "PullData Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'PullData Status';
            OptionMembers = "","Data Received","Data Updated";
            OptionCaption = ' ,Data Received,Data Updated';
        }
        field(22; "Error Message"; Text[300])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Message';
        }
        field(23; "No. Of Records"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("i95 Detailed Sync Log Entry" where("Sync Log Entry No" = field("Entry No")));

        }
        field(24; "Waiting For Push/Pull"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("i95 Detailed Sync Log Entry" where("Sync Status" = const("Waiting for Sync"), "Sync Log Entry No" = field("Entry No")));

        }
        field(25; "Waiting For Response"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("i95 Detailed Sync Log Entry" where("Sync Status" = const("Waiting for Response"), "Sync Log Entry No" = field("Entry No")));
        }
        field(26; "Waiting For Acknowledgement"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("i95 Detailed Sync Log Entry" where("Sync Status" = const("Waiting for Acknowledgement"), "Sync Log Entry No" = field("Entry No")));

        }
        field(27; "Sync Completed"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("i95 Detailed Sync Log Entry" where("Sync Status" = const("Sync Complete"), "Sync Log Entry No" = field("Entry No")));
        }
        field(28; "No. Of Errors"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = count("i95 Detailed Sync Log Entry" where("Log Status" = const(Error), "Sync Log Entry No" = field("Entry No")));
        }
        field(29; "i95 Source ID"; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Source ID';
        }

    }

    keys
    {
        key(Key1; "Entry No")
        { }
        key(key2; "Sync Source", "API Type", "Sync Status")
        { }
        key(Key3; "API Type", "Source Record ID")
        { }
    }

    procedure WriteToBlobField(BlobTextData: Text; CalledByAPI: Option "i95 Sync Request","i95 Sync Result","i95 Response Request","i95 Response Result","i95 Acknowledgement Request","i95 Acknowledgement Result");
    var
        OutStreamL: OutStream;
    begin
        if BlobTextData = '' then
            exit;

        BlobTextData := BlobTextData.Replace('\', '');

        case CalledByAPI of
            CalledByAPI::"i95 Sync Request":
                begin
                    Clear("i95 Sync Request");
                    "i95 Sync Request".CreateOutStream(OutStreamL, TextEncoding::Windows);
                    OutStreamL.WriteText(BlobTextData);
                end;
            CalledByAPI::"i95 Sync Result":
                begin
                    Clear("i95 Sync Result");
                    "i95 Sync Result".CreateOutStream(OutStreamL, TextEncoding::Windows);
                    OutStreamL.WriteText(BlobTextData);
                END;
            CalledByAPI::"i95 Response Request":
                begin
                    Clear("i95 Response Request");
                    "i95 Response Request".CreateOutStream(OutStreamL, TextEncoding::Windows);
                    OutStreamL.WriteText(BlobTextData);
                END;
            CalledByAPI::"i95 Response Result":
                begin
                    Clear("i95 Response Result");
                    "i95 Response Result".CreateOutStream(OutStreamL, TextEncoding::Windows);
                    OutStreamL.WriteText(BlobTextData);
                END;
            CalledByAPI::"i95 Acknowledgement Request":
                begin
                    Clear("i95 Acknowledgement Request");
                    "i95 Acknowledgement Request".CreateOutStream(OutStreamL, TextEncoding::Windows);
                    OutStreamL.WriteText(BlobTextData);
                END;
            CalledByAPI::"i95 Acknowledgement Result":
                begin
                    Clear("i95 Acknowledgement Result");
                    "i95 Acknowledgement Result".CreateOutStream(OutStreamL, TextEncoding::Windows);
                    OutStreamL.WriteText(BlobTextData);
                END;
        end;
        modify();
    end;

    procedure ReadFromBlobField(APIDataToRead: Option "i95 Sync Request","i95 Sync Result","i95 Response Request","i95 Response Result","i95 Acknowledgement Request","i95 Acknowledgement Result"): Text
    var
        TypeHelper: Codeunit "Type Helper";
        CarriageReturn: Char;
        InStreamL: InStream;
    begin
        CarriageReturn := 10;
        case APIDataToRead of
            APIDataToRead::"i95 Sync Request":
                begin
                    if not "i95 Sync Request".HasValue() then
                        exit('');

                    CalcFields("i95 Sync Request");
                    "i95 Sync Request".CreateInStream(InStreamL, TextEncoding::Windows);
                end;
            APIDataToRead::"i95 Sync Result":
                begin
                    if not "i95 Sync Result".HasValue() then
                        exit('');

                    CalcFields("i95 Sync Result");
                    "i95 Sync Result".CreateInStream(InStreamL, TextEncoding::Windows);
                end;
            APIDataToRead::"i95 Response Request":
                begin
                    if not "i95 Response Request".HasValue() then
                        exit('');

                    CalcFields("i95 Response Request");
                    "i95 Response Request".CreateInStream(InStreamL, TextEncoding::Windows);
                end;
            APIDataToRead::"i95 Response Result":
                begin
                    if not "i95 Response Result".HasValue() then
                        exit('');

                    CalcFields("i95 Response Result");
                    "i95 Response Result".CreateInStream(InStreamL, TextEncoding::Windows);
                end;
            APIDataToRead::"i95 Acknowledgement Request":
                begin
                    if not "i95 Acknowledgement Request".HasValue() then
                        exit('');

                    CalcFields("i95 Acknowledgement Request");
                    "i95 Acknowledgement Request".CreateInStream(InStreamL, TextEncoding::Windows);
                end;
            APIDataToRead::"i95 Acknowledgement Result":
                begin
                    if not "i95 Acknowledgement Result".HasValue() then
                        exit('');

                    CalcFields("i95 Acknowledgement Result");
                    "i95 Acknowledgement Result".CreateInStream(InStreamL, TextEncoding::Windows);
                end;
        end;

        exit(TypeHelper.ReadAsTextWithSeparator(InStreamL, CarriageReturn));
    end;

    procedure InsertSyncLogEntry(APIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerID,ReaccureToken;
    SyncStatus: Option "Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete","No Response";
    LogStatus: Option " ",New,"In Progress",Completed,Error,Cancelled; SyncSource: Option "","Business Central",i95): Integer
    var
        SyncLogEntry: Record "i95 Sync Log Entry";
        EntryNo: Integer;
    begin
        SyncLogEntry.Reset();
        If SyncLogEntry.FindLast() then
            EntryNo := SyncLogEntry."Entry No"
        else
            EntryNo := 0;
        init();
        "Entry No" := EntryNo + 1;
        "Sync DateTime" := CurrentDateTime();
        "API Type" := APIType;
        "Sync Status" := SyncStatus;
        "Log Status" := LogStatus;
        "Sync Source" := SyncSource;
        Insert();
        exit("Entry No");
    end;

    procedure UpdateSyncLogEntry(SyncStatus: Option "Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete","No Response";
         LogStatus: Option " ",New,"In Progress",Completed,Error,Cancelled; HttpReasonCode: Text; ResponseResultText: Text; ResponseMessage: Text; MessageId: Integer; SourceId: code[20]; StatusID: Integer; SyncSource: Option "","Business Central",i95);
    begin
        "Sync Status" := SyncStatus;
        "Log Status" := LogStatus;
        "Http Response Code" := copystr(HttpReasonCode, 1, 100);
        "Response Result" := copystr(ResponseResultText, 1, 30);
        "Response Message" := copystr(ResponseMessage, 1, 100);
        "Message ID" := MessageId;
        "i95 Source ID" := SourceId;
        "Status ID" := StatusID;
        "Sync Source" := SyncSource;
        Modify();
    end;

    procedure SetSourceRecordID(SourceRecordID: RecordId)
    begin
        "Source Record ID" := SourceRecordID;
        Modify();
    end;

    procedure SetSecondarySourceRecordID(SecSourceRecordID: RecordId)
    begin
        "Secondary Source Record ID" := SecSourceRecordID;
        Modify();
    end;

    procedure UpdateDataStatus(DataStatus: Option "","Data Received","Data Updated")
    begin
        "PullData Status" := DataStatus;
        Modify();
    end;

    procedure IsCancelledSalesOrder(SourceRecordId: RecordId): Boolean
    var
        SyncLogEntry: Record "i95 Sync Log Entry";
    begin
        SyncLogEntry.Reset();
        SyncLogEntry.SetCurrentKey(SyncLogEntry."API Type", SyncLogEntry."Source Record ID");
        SyncLogEntry.SetRange(SyncLogEntry."API Type", SyncLogEntry."API Type"::CancelOrder);
        SyncLogEntry.SetRange(SyncLogEntry."Source Record ID", SourceRecordId);
        exit(not SyncLogEntry.IsEmpty());
    end;

    procedure IsCancelledSalesQuote(SourceRecordId: RecordId): Boolean
    var
        SyncLogEntry: Record "i95 Sync Log Entry";
    begin
        SyncLogEntry.Reset();
        SyncLogEntry.SetCurrentKey(SyncLogEntry."API Type", SyncLogEntry."Source Record ID");
        SyncLogEntry.SetRange(SyncLogEntry."API Type", SyncLogEntry."API Type"::CancelQuote);
        SyncLogEntry.SetRange(SyncLogEntry."Source Record ID", SourceRecordId);
        exit(not SyncLogEntry.IsEmpty());
    end;



}