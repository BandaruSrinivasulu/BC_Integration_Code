Codeunit 70001 "i95 Webservice Execute"
{
    trigger OnRun()
    var
        WebServiceClient: HttpClient;
        WebServiceContent: HttpContent;
        WebServiceHeaders: HttpHeaders;
        WebServiceRequestMessage: HttpRequestMessage;
        WebServiceResponseMessage: HttpResponseMessage;
        Text70328076Txt: Label 'Webservice call failed!\Status Code : %1\Reason : %2';
        WebServiceJsonObject: JsonObject;
    begin
        if not TestMode then begin
            Clear(APIResponseMessageText);
            Clear(APIResponseResultText);
            Clear(SourceID);
            Clear(TargetID);
            Clear(Reference);
            Clear(ResultMessageID);
            Clear(ResultMessageText);
            Clear(StatusID);
            Clear(SchedulerID);
            Clear(ContactSourceID);
            Clear(ContactTargetID);

            WebServiceRequestMessage.Method := RequestType;
            WebServiceRequestMessage.SetRequestUri(WebServiceURL);
            WebServiceRequestMessage.GetHeaders(WebServiceHeaders);

            WebServiceContent.Clear();
            WebServiceContent.WriteFrom(BodyContent);
            WebServiceContent.GetHeaders(WebServiceHeaders);

            WebServiceHeaders.Remove('Content-Type');
            WebServiceHeaders.Add('Content-Type', ContentType);
            WebServiceContent.GetHeaders(WebServiceHeaders);
            WebServiceRequestMessage.Content := WebServiceContent;
            WebServiceClient.DefaultRequestHeaders().Add('Authorization', Authorization);
            if WebServiceClient.Post(WebServiceURL, WebServiceContent, WebServiceResponseMessage) then begin
                WebServiceResponseMessage.Content().ReadAs(WebServiceResponseText);
                WebServiceResponseText := WebServiceResponseText.Replace('\', '');
                WebServiceResponseText := WebServiceResponseText.Replace('"inputData":"', '"inputData":');
                WebServiceResponseText := WebServiceResponseText.Replace('","messageId":', ',"messageId":');

                WebServiceJsonObject.ReadFrom(WebServiceResponseText);

                IF WebservicePullDataSource in [WebservicePullDataSource::EntityManagement] then
                    ProcessJsonResponseforEntityManagement(WebServiceJsonObject)
                else
                    if WebservicePullDataSource IN [WebservicePullDataSource::SchedulerID] then
                        ProcessJsonResponseforSchedulerIDPull(WebServiceJsonObject)
                    else
                        IF WebservicePullDataSource in [WebservicePullDataSource::ReaccureToken] then
                            ProcessJsonResponseforReccuretokenPull(WebServiceJsonObject)
                        else
                            if WebservicePullDataSource IN [WebservicePullDataSource::Customer, WebservicePullDataSource::CustomerGroup, WebservicePullDataSource::SalesOrder, WebservicePullDataSource::Product, WebservicePullDataSource::PaymentJournal, WebservicePullDataSource::SalesQuote, WebservicePullDataSource::AccountRecievable, WebservicePullDataSource::SalesReturn] then
                                ProcessJsonResponseforPullData(WebServiceJsonObject)
                            else
                                ProcessJsonResponseforPushData(WebServiceJsonObject);
            end else
                error(Text70328076Txt, WebServiceResponseMessage.HttpStatusCode(), WebServiceResponseMessage.ReasonPhrase());
        end else begin
            WebServiceJsonObject.ReadFrom(WebServiceResponseText);

            IF WebservicePullDataSource in [WebservicePullDataSource::EntityManagement] then
                ProcessJsonResponseforEntityManagement(WebServiceJsonObject)
            else
                if WebservicePullDataSource IN [WebservicePullDataSource::SchedulerID] then
                    ProcessJsonResponseforSchedulerIDPull(WebServiceJsonObject)
                else
                    IF WebservicePullDataSource in [WebservicePullDataSource::ReaccureToken] then
                        ProcessJsonResponseforReccuretokenPull(WebServiceJsonObject)
                    else
                        if WebservicePullDataSource IN [WebservicePullDataSource::Customer, WebservicePullDataSource::CustomerGroup, WebservicePullDataSource::SalesOrder, WebservicePullDataSource::Product, WebservicePullDataSource::PaymentJournal, WebservicePullDataSource::SalesQuote, WebservicePullDataSource::AccountRecievable, WebservicePullDataSource::SalesReturn] then
                            ProcessJsonResponseforPullData(WebServiceJsonObject)
                        else
                            ProcessJsonResponseforPushData(WebServiceJsonObject);
        end;
        ResponseStatusCode := format(WebServiceResponseMessage.HttpStatusCode()) + '-' + WebServiceResponseMessage.ReasonPhrase();
    end;

    procedure GetAPIResponseMessageText(): Text
    begin
        exit(APIResponseMessageText);
    end;

    procedure GetAPIResponseResultText(): Text
    begin
        exit(APIResponseResultText);
    end;

    procedure GetAPIUrl(webserviceAPIType: Option " ",Product,Customer,CustomerGroup,Inventory,SalesOrder,Shipment,Invoice,TierPrices,CancelOrder,EditOrder,TaxBusPostingGroup,TaxProductPostingGroup,TaxPostingSetup,ConfigurableProduct,CustomerDiscountGroup,ItemDiscountGroup,DiscountPrice,ShippingAgent,PaymentMethod,EntityManagement,PaymentJournal,PaymentTerm,SalesQuote,CancelQuote,AccountRecievable,financeCharge,SalesPerson,SalesReturn,SalesCreditMemo,Warehouse,ProductAttributeMapping,SchedulerID,ReaccureToken; webserviceSchedulerType: Option " ",PushData,PullResponse,PullResponseAck,PullData,PushResponse)
    var
        i95Setup: Record "i95 Setup";
        i95Configuration: Record "i95 API Configuration";
        I95SetupErrorTxt: Label 'Please enter I95 Setup.';
        I95APIConfigurationErrorTxt: Label 'Please enter I95 API Configuration for %1.';
    begin
        clear(BaseUrl);
        clear(Authorization);
        clear(ContentType);
        clear(RequestType);
        clear(WebServiceURL);
        If i95Setup.get() then begin
            i95Setup.TestField(i95Setup.Authorization);
            i95Setup.TestField(i95Setup."Base Url");
            Authorization := i95Setup.GetAuthorizationToken();
            evaluate(ContentType, format(i95Setup."Content Type"));
            BaseUrl := i95Setup."Base Url";
        end else
            error(I95SetupErrorTxt);
        i95Configuration.Reset();
        i95Configuration.SetRange(i95Configuration."API Type", webserviceAPIType);
        if i95Configuration.FindFirst() then begin
            evaluate(RequestType, format(i95Configuration."Request Type"));
            case webserviceSchedulerType of
                webserviceSchedulerType::PushData:
                    begin
                        i95Configuration.TestField(i95Configuration."PushData Url");
                        WebServiceURL := BaseUrl + i95Configuration."PushData Url";
                    end;
                webserviceSchedulerType::PullResponse:
                    begin
                        i95Configuration.TestField(i95Configuration."PullResponse Url");
                        WebServiceURL := BaseUrl + i95Configuration."PullResponse Url";
                    end;
                webserviceSchedulerType::PullResponseAck:
                    begin
                        i95Configuration.TestField(i95Configuration."PullResponseAck Url");
                        WebServiceURL := BaseUrl + i95Configuration."PullResponseAck Url";
                    end;
                webserviceSchedulerType::PullData:
                    begin
                        i95Configuration.TestField(i95Configuration."PullData Url");
                        WebServiceURL := BaseUrl + i95Configuration."PullData Url";
                    end;
                webserviceSchedulerType::PushResponse:
                    begin
                        i95Configuration.TestField(i95Configuration."PushResponse Url");
                        WebServiceURL := BaseUrl + i95Configuration."PushResponse Url";
                    end;
            end;
        end else
            error(I95APIConfigurationErrorTxt, webserviceAPIType);
    end;

    procedure GetResponseStatusCode(): Text
    begin
        exit(ResponseStatusCode);
    end;

    procedure GetResultDataJsonArray(): JsonArray
    begin
        exit(ResultDataJsonArray);
    end;

    procedure GetResultDataJsonObject(): JsonObject
    begin
        exit(ResultDataJsonObject);
    end;

    procedure GetResultDataJsonToken(): JsonToken
    begin
        exit(ResultDataJsonToken);
    end;

    procedure GetResultJsonToken(): JsonToken
    begin
        exit(ResultJsonToken);
    end;

    procedure GetResultMessageID(): Integer
    begin
        exit(ResultMessageID);
    end;

    procedure GetSourceID(): Code[20]
    begin
        exit(SourceID);
    end;

    procedure GetContactSourceID(): Code[20]
    var
    begin
        exit(ContactSourceID);
    end;

    procedure GetContactTargetID(): Code[20]
    begin
        exit(ContactTargetID);
    end;


    procedure GetStatusID(): Integer
    begin
        exit(StatusID);
    end;

    procedure GetTargetId(): Code[20]
    begin
        exit(TargetID);
    end;

    procedure GetWebServiceResponseJson(): Text
    begin
        exit(WebServiceResponseText);
    end;

    procedure ProcessJsonResponseforPullData(WebServiceJsonObject: JsonObject)
    begin
        APIResponseResultText := ProcessJsonTokenasText('result', WebServiceJsonObject);
        APIResponseMessageText := ProcessJsonTokenasText('message', WebServiceJsonObject);

        if WebServiceJsonObject.Contains('resultData') then begin
            WebServiceJsonObject.get('resultData', ResultDataJsonToken);
            ResultDataJsonArray := ResultDataJsonToken.AsArray();

            foreach ResultDataJsonToken in ResultDataJsonArray do begin
                ResultDataJsonObject := ResultDataJsonToken.AsObject();
                SourceID := ProcessJsonTokenasCode('sourceId', ResultDataJsonObject);
                TargetID := ProcessJsonTokenasCode('targetId', ResultDataJsonObject);
                Reference := ProcessJsonTokenasText('reference', ResultDataJsonObject);
                ResultMessageID := ProcessJsontokenasInteger('messageId', ResultDataJsonObject);
                ResultMessageText := ProcessJsonTokenasText('message', ResultDataJsonObject);
                StatusID := ProcessJsonTokenasInteger('statusId', ResultDataJsonObject);
            end;
        end;
    end;

    procedure ProcessJsonResponseforPushData(WebServiceJsonObject: JsonObject)
    begin
        APIResponseResultText := ProcessJsonTokenasText('result', WebServiceJsonObject);
        APIResponseMessageText := ProcessJsonTokenasText('message', WebServiceJsonObject);

        if WebServiceJsonObject.Contains('resultData') then begin
            WebServiceJsonObject.get('resultData', ResultDataJsonToken);
            ResultDataJsonArray := ResultDataJsonToken.AsArray();
        end;

        foreach ResultDataJsonToken in ResultDataJsonArray do begin
            ResultDataJsonObject := ResultDataJsonToken.AsObject();
            SourceID := ProcessJsonTokenasCode('sourceId', ResultDataJsonObject);
            TargetID := ProcessJsonTokenasCode('targetId', ResultDataJsonObject);
            Reference := ProcessJsonTokenasText('reference', ResultDataJsonObject);
            ResultMessageID := ProcessJsontokenasInteger('messageId', ResultDataJsonObject);
            ResultMessageText := ProcessJsonTokenasText('message', ResultDataJsonObject);
            StatusID := ProcessJsonTokenasInteger('statusId', ResultDataJsonObject);
            I95DevSetup.Get();
            IF I95DevSetup."i95 Enable Company" = true then begin
                IF ResultDataJsonObject.Contains('inputData') then begin
                    IF ResultDataJsonObject.Get('inputData', InputDataJsonToken) then
                        IF InputDataJsonToken.isObject() then
                            InputDataJsonObject := InputDataJsonToken.AsObject();
                end;
                IF InputDataJsonObject.Contains('contactInfo') then begin
                    InputDataJsonObject.Get('contactInfo', ContactDataJsonToken);
                    IF ContactDataJsonToken.IsObject then
                        ContactDataJsonObject := ContactDataJsonToken.AsObject();
                    ContactSourceID := ProcessJsonTokenasCode('sourceId', ContactDataJsonObject);
                    ContactTargetID := ProcessJsonTokenasCode('targetId', ContactDataJsonObject);
                end;

            end;
        end;
    end;

    procedure ProcessJsonResponseforSchedulerIDPull(WebServiceJsonObject: JsonObject)
    begin
        APIResponseResultText := ProcessJsonTokenasText('result', WebServiceJsonObject);
        APIResponseMessageText := ProcessJsonTokenasText('message', WebServiceJsonObject);
        SchedulerID := copystr(ProcessJsonTokenasText('schedulerId', WebServiceJsonObject), 1, 50);
        ResultDataJsonObject := WebServiceJsonObject;
    end;

    procedure ProcessJsonResponseforReccuretokenPull(WebServiceJsonObject: JsonObject)
    begin
        APIResponseResultText := ProcessJsonTokenasText('result', WebServiceJsonObject);
        APIResponseMessageText := ProcessJsonTokenasText('message', WebServiceJsonObject);

        if WebServiceJsonObject.Contains('accessToken') then begin
            WebServiceJsonObject.get('accessToken', ResultDataJsonToken);

            // ResultDataJsonArray := ResultDataJsonToken.AsArray();

            // foreach ResultDataJsonToken in ResultDataJsonArray do begin
            ResultDataJsonObject := ResultDataJsonToken.AsObject();
            Accesstoken := ProcessJsonTokenasText('token', ResultDataJsonObject);
            AccessExpiretime := ProcessJsonTokenasText('expiryTime', ResultDataJsonObject);
            // end;
        end;
        Clear(ResultDataJsonObject);
        Clear(ResultDataJsonArray);
        Clear(ResultDataJsonToken);

        if WebServiceJsonObject.Contains('refreshToken') then begin
            WebServiceJsonObject.get('refreshToken', ResultDataJsonToken);
            // ResultDataJsonArray := ResultDataJsonToken.AsArray();

            // foreach ResultDataJsonToken in ResultDataJsonArray do begin
            ResultDataJsonObject := ResultDataJsonToken.AsObject();
            RefreshToken := ProcessJsonTokenasText('token', ResultDataJsonObject);
            RefreshExpiretime := ProcessJsonTokenasText('expiryTime', ResultDataJsonObject);
            // end;
        end;

        ResultDataJsonObject := WebServiceJsonObject;
    end;

    procedure ProcessJsonTokenasBoolean(JsonTag: text; SourceJsonObject: JsonObject): Boolean
    var
        ReturnJsonValue: JsonValue;
        SourceJsonToken: JsonToken;
    begin
        if not SourceJsonObject.Contains(JsonTag) then
            exit(false);
        SourceJsonObject.get(JsonTag, SourceJsonToken);
        ReturnJsonValue := SourceJsonToken.AsValue();
        if not ReturnJsonValue.IsNull() then
            exit(ReturnJsonValue.AsBoolean());
    end;

    procedure ProcessJsonTokenasCode(JsonTag: Text; SourceJsonObject: JsonObject): Code[20]
    var
        ReturnJsonValue: JsonValue;
        SourceJsonToken: JsonToken;
    begin

        if not SourceJsonObject.Contains(JsonTag) then
            exit('');
        SourceJsonObject.get(JsonTag, SourceJsonToken);
        ReturnJsonValue := SourceJsonToken.AsValue();
        if not ReturnJsonValue.IsNull() then
            exit(copystr(ReturnJsonValue.AsCode(), 1, 20));
    end;

    procedure ProcessJsonTokenasDate(JsonTag: text; SourceJsonObject: JsonObject): Date
    var
        ReturnJsonValue: JsonValue;
        SourceJsonToken: JsonToken;
    begin
        if not SourceJsonObject.Contains(JsonTag) then
            exit(0D);
        SourceJsonObject.get(JsonTag, SourceJsonToken);
        ReturnJsonValue := SourceJsonToken.AsValue();
        if not ReturnJsonValue.IsNull() then
            exit(ReturnJsonValue.AsDate());
    end;

    procedure ProcessJsonTokenasDecimal(JsonTag: text; SourceJsonObject: JsonObject): Decimal
    var
        ReturnJsonValue: JsonValue;
        SourceJsonToken: JsonToken;
    begin
        if not SourceJsonObject.Contains(JsonTag) then
            exit(0);
        SourceJsonObject.get(JsonTag, SourceJsonToken);
        ReturnJsonValue := SourceJsonToken.AsValue();
        if not ReturnJsonValue.IsNull() then
            exit(ReturnJsonValue.AsDecimal());
    end;

    procedure ProcessJsonTokenasInteger(JsonTag: text; SourceJsonObject: JsonObject): Integer
    var
        ReturnJsonValue: JsonValue;
        SourceJsonToken: JsonToken;
    begin
        if not SourceJsonObject.Contains(JsonTag) then
            exit(0);
        SourceJsonObject.get(JsonTag, SourceJsonToken);
        ReturnJsonValue := SourceJsonToken.AsValue();
        if not ReturnJsonValue.IsNull() then
            exit(ReturnJsonValue.AsInteger());
    end;


    procedure ProcessJsonResponseforEntityManagement(WebServiceJsonObject: JsonObject)
    begin
        APIResponseResultText := ProcessJsonTokenasText('result', WebServiceJsonObject);
        APIResponseMessageText := ProcessJsonTokenasText('message', WebServiceJsonObject);

        if WebServiceJsonObject.Contains('resultData') then begin
            WebServiceJsonObject.get('resultData', ResultDataJsonToken);
            ResultDataJsonArray := ResultDataJsonToken.AsArray();

            foreach ResultDataJsonToken in ResultDataJsonArray do begin
                ResultDataJsonObject := ResultDataJsonToken.AsObject();
                Entityid := ProcessJsonTokenasInteger('entityId', WebServiceJsonObject);
                EntityName := ProcessJsonTokenasText('entityName', WebServiceJsonObject);
                IsInboundActive := ProcessJsonTokenasBoolean('isInboundActive', WebServiceJsonObject);
                IsOutboundActive := ProcessJsonTokenasBoolean('isOutboundActive', WebServiceJsonObject);

            end;

        end;

    end;


    procedure ProcessJsonTokenasText(JsonTag: text; SourceJsonObject: JsonObject): Text
    var
        ReturnJsonValue: JsonValue;
        SourceJsonToken: JsonToken;
    begin
        if not SourceJsonObject.Contains(JsonTag) then
            exit('');
        SourceJsonObject.get(JsonTag, SourceJsonToken);
        ReturnJsonValue := SourceJsonToken.AsValue();
        if not ReturnJsonValue.IsNull() then
            exit(ReturnJsonValue.AsText());
    end;

    procedure SetMockResponseText(MockResponseText: Text)
    begin
        WebServiceResponseText := MockResponseText;
    end;

    procedure SetPullDataSource(PullDataSource: Option " ",Customer,CustomerGroup,SalesOrder,Product,EntityManagement,PaymentJournal,SalesQuote,AccountRecievable,SalesReturn,ProductAttributeMapping,SchedulerID,ReaccureToken)
    begin
        WebservicePullDataSource := PullDataSource;
    end;

    procedure SetTestMode(TestModeFlag: Boolean)
    begin
        TestMode := TestModeFlag;
    end;

    procedure SetWebRequestData(pBodyContent: text)
    begin
        BodyContent := pBodyContent;
    end;

    var
        WebServiceURL: text;
        RequestType: text;
        Authorization: text;
        ContentType: Text;
        BodyContent: text;
        WebServiceResponseText: text;
        APIResponseResultText: text;
        APIResponseMessageText: Text;
        TargetID: Code[20];
        //Reference: Code[20];
        Reference: Text;
        SourceID: code[20];
        StatusID: Integer;
        ResultMessageID: Integer;
        ResultMessageText: text;
        ResponseStatusCode: text;
        WebservicePullDataSource: Option " ",Customer,CustomerGroup,SalesOrder,Product,EntityManagement,PaymentJournal,SalesQuote,AccountRecievable,SalesPerson,SalesReturn,ProductAttributeMapping,SchedulerID,ReaccureToken;
        ResultDataJsonArray: JsonArray;
        ResultJsonToken: JsonToken;
        ResultDataJsonToken: JsonToken;
        ResultDataJsonObject: JsonObject;
        BaseUrl: Text;
        TestMode: Boolean;
        SchedulerID: Text[50];
        Entityid: Integer;
        EntityName: Text;
        IsInboundActive: Boolean;
        IsOutboundActive: Boolean;
        RefreshToken: Text;
        Accesstoken: Text;
        RefreshExpiretime: Text;
        AccessExpiretime: Text;
        InputDataJsonObject: JsonObject;
        InputDataJsonArray: JsonArray;
        InputJsonToken: JsonToken;
        InputDataJsonToken: JsonToken;
        ContactJsonToken: JsonToken;
        ContactDataJsonObject: JsonObject;
        ContactDataJsonArray: JsonArray;
        ContactDataJsonToken: JsonToken;
        I95DevSetup: Record "i95 Setup";
        ContactTargetID: Code[20];
        ContactSourceID: code[20];
        Inputdata: Text;
}

