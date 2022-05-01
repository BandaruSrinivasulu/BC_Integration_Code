Table 70007 "i95 API Call Log Entry"
{
    Caption = 'i95Dev API Call Log Entry';
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
        field(3; "Sync DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Sync Date/Time';
        }
        field(4; "API Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'API Type';
            OptionMembers = " ","Product","Customer","CustomerGroup","Inventory","SalesOrder","Shipment","Invoice","TierPrices","CancelOrder","EditOrder","TaxBusPostingGroup","TaxProductPostingGroup","TaxPostingSetup","ConfigurableProduct","CustomerDiscountGroup","ItemDiscountGroup","DiscountPrice","ShippingAgent","PaymentMethod","EntityManagement","PaymentJournal","PaymentTerm","SalesQuote","CancelQuote","AccountRecievable","financeCharge","SalesPerson","SalesReturn","SalesCreditMemo","Warehouse","ProductAttributeMapping","SchedulerId","ReaccureToken";
            OptionCaption = ' ,Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerId,ReaccureToken';
        }
        field(5; "Scheduler Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Scheduler Type';
            OptionMembers = " ",PushData,PullResponse,PullResponseACK,PullData,PushResponse;
            OptionCaption = ' ,Push Data, Pull Response, Pull Response ACK, Pull Data, Push Response';
        }
        field(6; "Sync Source"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Sync Source';
            OptionMembers = "","Business Central",i95;
            OptionCaption = ' ,Business Central,i95Dev';
        }
        field(7; "Http Response Code"; Text[200])
        {
            DataClassification = CustomerContent;
            Caption = 'Http Response Code';
        }
        field(8; "Error Message"; Text[300])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Message';
        }

        field(9; "i95 API Request"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Sync Request Content';
        }
        field(10; "i95 API Result"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Sync Result Content';
        }
        field(11; "i95 Sync Datetime in Sec"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'i95 Sync Datetime in Sec';
        }
    }

    keys
    {
        key(Key1; "Entry No")
        { }
        key(Key2; "Sync Log Entry No")
        { }
        key(Key3; "API Type", "Sync Log Entry No")
        { }
    }

    procedure WriteToBlobField(BlobTextData: Text; CalledByAPI: Option "i95 API Request","i95 API Result");
    var
        OutStreamL: OutStream;
    begin
        if BlobTextData = '' then
            exit;

        BlobTextData := BlobTextData.Replace('\', '');

        case CalledByAPI of
            CalledByAPI::"i95 API Request":
                begin
                    Clear("i95 API Request");
                    "i95 API Request".CreateOutStream(OutStreamL, TextEncoding::Windows);
                    OutStreamL.WriteText(BlobTextData);
                end;
            CalledByAPI::"i95 API Result":
                begin
                    Clear("i95 API Result");
                    "i95 API Result".CreateOutStream(OutStreamL, TextEncoding::Windows);
                    OutStreamL.WriteText(BlobTextData);
                END;
        end;
        modify();
    end;

    procedure ReadFromBlobField(APIDataToRead: Option "i95 API Request","i95 API Result"): Text
    var
        TypeHelper: Codeunit "Type Helper";
        CarriageReturn: Char;
        InStreamL: InStream;
    begin
        CarriageReturn := 10;
        case APIDataToRead of
            APIDataToRead::"i95 API Request":
                begin
                    if not "i95 API Request".HasValue() then
                        exit('');

                    CalcFields("i95 API Request");
                    "i95 API Request".CreateInStream(InStreamL, TextEncoding::Windows);
                end;
            APIDataToRead::"i95 API Result":
                begin
                    if not "i95 API Result".HasValue() then
                        exit('');

                    CalcFields("i95 API Result");
                    "i95 API Result".CreateInStream(InStreamL, TextEncoding::Windows);
                end;
        end;

        exit(TypeHelper.ReadAsTextWithSeparator(InStreamL, CarriageReturn));
    end;

    procedure InsertApiCallLogEntry(SyncLogEntryNo: Integer; APIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerId,ReaccureToken;
        SchedulerType: Option " ",PushData,PullResponse,PullResponseACK,PullData,PushResponse; SyncSource: Option "","Business Central",i95): Integer;
    var
        SyncLogEntry: Record "i95 Sync Log Entry";
        APILogEntry: Record "i95 API Call Log Entry";
        EntryNo: Integer;
        DatetimeL: DateTime;
    begin
        APILogEntry.Reset();
        If APILogEntry.FindLast() then
            EntryNo := APILogEntry."Entry No"
        else
            EntryNo := 0;

        if SyncLogEntry.Get(SyncLogEntryNo) then begin
            init();
            "Entry No" := EntryNo + 1;
            "Sync Log Entry No" := SyncLogEntryNo;
            "Sync DateTime" := CurrentDateTime();
            "i95 Sync Datetime in Sec" := FORMAT(CURRENTDATETIME, 0, '<Month,2><Day,2><Year4><Hours24,2><Minutes,2><Seconds,2>');
            "API Type" := APIType;
            "Scheduler Type" := SchedulerType;
            "Sync Source" := SyncSource;
            Insert();
        end;

        exit("Entry No");
    end;

    Procedure UpdateAPILogEntry(HttpReasonCode: Text; ErrorMessagee: Text);
    begin
        "Http Response Code" := copystr(HttpReasonCode, 1, 100);
        "Error Message" := copystr(ErrorMessagee, 1, 100);
        Modify();
    end;
}
