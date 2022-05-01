Tableextension 70010 "i95 Sales Header Ext" extends "Sales Header"
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

        field(70007; "i95 Creation Source"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Creation Source';
            OptionMembers = " ","Business Central","i95";
            OptionCaption = ' ,"Business Central","i95Dev"';
            Editable = false;
        }
        field(70008; "i95 Last Modified By"; Code[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Last Modified By';
            Editable = false;
        }
        field(70009; "i95 Last Modification DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Modification DateTime';
            Editable = false;
        }
        field(70010; "i95 Last Modification Source"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ","Business Central","i95";
            OptionCaption = ' ,"Business Central","i95Dev"';
            Caption = 'Last Modification Source';
            Editable = false;
        }
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
            Caption = 'Last Sync DateTime';
            Editable = false;
        }
        field(70013; "i95 Reference ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Reference ID';
            Editable = false;
        }
        field(70015; "i95 Sync Message"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Sync Message';
            Editable = false;
        }
        field(70016; "i95 Order Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'i95Dev Order Status';
            OptionMembers = " ",Updated,Edited;
            OptionCaption = ' ,Updated,Edited';
            Editable = false;
        }
        field(70017; "i95 EditOrder Sync Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Edit Order Sync Status';
            OptionMembers = " ","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete";
            OptionCaption = ' ,Waiting for Sync,Waiting for Response,Waiting for Acknowledgement,Sync Complete';
            Editable = false;
        }
        field(70018; "i95 EditOrd Last SyncDateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Edit Order Last Sync DateTime';
            Editable = false;
        }
        field(70019; "i95 EditOrder Updated DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Edit Order Last Updated DateTime';
            Editable = false;
        }

        //For charge logic
        field(70020; "CL-TransactionNumber"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Transaction Number';
            Editable = false;
        }
        field(70021; "i95 IsManualReopen"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'i95 IsManualReopen"';
            Editable = false;
        }

    }
    keys
    {
        key(Key2; "i95 Reference ID")
        { }
        key(key3; "i95 Sync Status")
        { }
        key(key4; "i95 EditOrder Sync Status")
        { }
    }


    trigger OnBeforeInsert()
    begin
        CheckIfi95SyncAllowed();
        "i95 Created By" := copystr(UserId(), 1, 80);
        "i95 Created DateTime" := CurrentDateTime();
        "i95 Creation Source" := "i95 Creation Source"::"Business Central";
        i95EntityMapping.Reset();
        IF i95EntityMapping.FindSet() then;
        IF i95EntityMapping."Allow SalesOrder Oubound Sync" = true then Begin
            If i95MandatoryFieldsUpdated() then
                "i95 Sync Status" := "i95 Sync Status"::"Waiting for Sync";
        End;
    end;

    trigger OnBeforeModify()
    Begin

        CheckIfi95SyncAllowed();
        if ((not UpdatedFromi95PullRequest) and i95MandatoryFieldsUpdated() and (not CalledFromSalesPost) and (not Invoice) and (not Ship)) then
            If (rec."i95 Reference ID" <> '') then begin
                If "i95 Order Status" <> "i95 Order Status"::Edited then
                    "i95 Order Status" := "i95 Order Status"::Updated;

                i95EntityMapping.Reset();
                IF i95EntityMapping.FindSet() then;
                IF i95EntityMapping."Allow ESalesOrder Oubound Sync" = true then
                    "i95 EditOrder Sync Status" := "i95 EditOrder Sync Status"::"Waiting for Sync";

                "i95 EditOrder Updated DateTime" := CurrentDateTime();
            end else begin
                "i95 Last Modification DateTime" := CurrentDateTime();
                "i95 Last Modified By" := copystr(UserId(), 1, 80);
                "i95 Last Sync DateTime" := CurrentDateTime();

                i95EntityMapping.Reset();
                IF i95EntityMapping.FindSet() then;
                IF i95EntityMapping."Allow SalesOrder Oubound Sync" = true then
                    "i95 Sync Status" := "i95 Sync Status"::"Waiting for Sync";

                "i95 Last Modification Source" := "i95 Last Modification Source"::"Business Central";
            end;

        IF ("Document Type" = "Document Type"::Quote) or ("Document Type" = "Document Type"::"Return Order") then begin
            IF i95MandatoryFieldsUpdated() and (Rec.Status = rec.Status::Released) then begin
                i95EntityMapping.Reset();
                IF i95EntityMapping.FindSet() then;
                IF (i95EntityMapping."Allow SalesQuote Outbound Sync" = true) or (i95EntityMapping."Allow SalesReturn Ob Sync" = true) then
                    "i95 Sync Status" := "i95 Sync Status"::"Waiting for Sync";
                "i95 Last Modification Source" := "i95 Last Modification Source"::"Business Central";

            end;
        end;


        //  i95SkipOnDelete := false;
    End;

    procedure Updatei95SyncStatus(SyncSource: Option " ","Business Central","i95"; SyncStatus: Option "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete"; ReferenceID: Code[20])
    begin
        "i95 Last Modification DateTime" := CurrentDateTime();
        "i95 Last Modified By" := copystr(UserId(), 1, 80);
        "i95 Last Sync DateTime" := CurrentDateTime();
        "i95 Sync Status" := SyncStatus;
        "i95 Last Modification Source" := SyncSource;

        if ReferenceID <> '' then
            "i95 Reference ID" := ReferenceID;

        Modify(false);

        Reseti95SalesLineModificationFlag();
    end;

    procedure Updatei95SyncStatusforEditOrder(SyncSource: Option " ","Business Central","i95"; SyncStatus: Option "InComplete Data","Waiting for Sync","Waiting for Response","Waiting for Acknowledgement","Sync Complete"; ReferenceID: Code[20])
    begin
        "i95 EditOrder Sync Status" := SyncStatus;
        "i95 EditOrd Last SyncDateTime" := CurrentDateTime();

        if ReferenceID <> '' then
            "i95 Reference ID" := ReferenceID;

        if "i95 EditOrder Sync Status" = "i95 EditOrder Sync Status"::"Sync Complete" then
            "i95 Order Status" := "i95 Order Status"::" ";

        Modify(false);

        Reseti95SalesLineModificationFlag();
    end;

    procedure Seti95PullRequestAPICall(APICall: Boolean)
    begin
        UpdatedFromi95PullRequest := APICall;
    end;

    procedure i95MandatoryFieldsUpdated(): Boolean
    begin
        if "i95 Sync Message" <> '' then begin
            "i95 Sync Status" := "i95 Sync Status"::"InComplete Data";
            exit(false);
        end else
            exit(true);
    end;

    procedure i95SalesLineExists(): Boolean
    var
        salesLine: Record "Sales Line";
    begin
        SalesLine.reset();
        SalesLine.setrange("Document Type", "Document Type");
        salesLine.SetRange("Document No.", "No.");
        exit(not salesLine.IsEmpty());
    end;

    procedure i95SalesLineModificationExists(): Boolean
    var
        salesLine: Record "Sales Line";
    begin
        SalesLine.reset();
        SalesLine.setrange("Document Type", "Document Type");
        salesLine.SetRange("Document No.", "No.");
        salesLine.SetRange("i95 Sales Line Modified", true);
        exit(not salesLine.IsEmpty());
    end;

    procedure Reseti95SalesLineModificationFlag(): Boolean
    var
        salesLine: Record "Sales Line";
    begin
        SalesLine.reset();
        SalesLine.setrange("Document Type", "Document Type");
        salesLine.SetRange("Document No.", "No.");
        salesLine.SetRange("i95 Sales Line Modified", true);
        if salesLine.Findset() then
            salesLine.ModifyAll("i95 Sales Line Modified", false);

        Rec."i95 EditOrder Sync Status" := Rec."i95 EditOrder Sync Status"::" ";
        Rec."i95 Order Status" := Rec."i95 Order Status"::" ";
    end;

    procedure CheckIfi95SyncAllowed()
    var
        ShippingAgentMapping: Record "i95 Shipping Agent Mapping";
        PaymentMethodsMapping: Record "i95 Payment Methods Mapping";
        SalesLine: Record "Sales Line";
        Item: Record item;
        ItemVariant: Record "Item Variant";
        PaymentMethodErrorExists: Boolean;
        i95BilltoAddressErrorTxt: Label 'Bill-to Address cannot be blank';
        i95BilltoAddress2ErrorTxt: Label 'Bill-to Address 2 cannot be blank';
        i95BilltoCityErrorTxt: Label 'Bill-to City cannot be blank';
        i95BilltoPostCodeErrorTxt: Label 'Bill-to Post Code cannot be blank';
        i95ShippingAgentErrorTxt: Label 'Shipping Agent does not exist for  %1';
        i95ShippingAgentServiceErrorTxt: Label 'Shipping Agent Service does not exist for  %1';
        i95PaymentMethodErrorTxt: Label 'Payment Method does not exist for  %1';
        i95SalesLineErrorTxt: Label 'Sales Line does not exists';
        i95SalesQuoteStatusText: Label 'Sales Quote Status should be Released';
        i95ExternalDocumentNotext: Label 'External Document Does not Exist for %1';
    begin
        "i95 Sync Message" := '';
        If UpdatedFromi95PullRequest then
            exit;
        IF not (Rec."Document Type" = Rec."Document Type"::Quote) then begin
            Case true of
                "Sell-to Customer No." = '':
                    "i95 Sync Message" := copystr(StrSubstNo(i95SyncErrorTxt, FieldCaption("Sell-to Customer No.")), 1, 250);

                "Sell-to Address" = '':
                    "i95 Sync Message" := copystr(StrSubstNo(i95SyncErrorTxt, FieldCaption("Sell-to Address")), 1, 250);
                /* "Sell-to Address 2" = '':
                     "i95 Sync Message" := copystr(StrSubstNo(i95SyncErrorTxt, FieldCaption("Sell-to Address 2")), 1, 250);*/
                "Sell-to City" = '':
                    "i95 Sync Message" := copystr(StrSubstNo(i95SyncErrorTxt, FieldCaption("Sell-to City")), 1, 250);
                "Sell-to Country/Region Code" = '':
                    "i95 Sync Message" := copystr(StrSubstNo(i95SyncErrorTxt, FieldCaption("Sell-to Country/Region Code")), 1, 250);
                "Sell-to Post Code" = '':
                    "i95 Sync Message" := copystr(StrSubstNo(i95SyncErrorTxt, FieldCaption("Sell-to Post Code")), 1, 250);
                /*  "Sell-to Phone No." = '':
                      "i95 Sync Message" := copystr(StrSubstNo(i95SyncErrorTxt, FieldCaption("Sell-to Phone No.")), 1, 250);*/
                "Sell-to E-Mail" = '':
                    "i95 Sync Message" := copystr(StrSubstNo(i95SyncErrorTxt, FieldCaption("Sell-to E-Mail")), 1, 250);
                "Bill-to Customer No." = '':
                    "i95 Sync Message" := copystr(StrSubstNo(i95SyncErrorTxt, FieldCaption("Bill-to Customer No.")), 1, 250);
                "Bill-to Address" = '':
                    "i95 Sync Message" := copystr(i95BilltoAddressErrorTxt, 1, 250);
                /* "Bill-to Address 2" = '':
                     "i95 Sync Message" := copystr(i95BilltoAddress2ErrorTxt, 1, 250);*/
                "Bill-to City" = '':
                    "i95 Sync Message" := copystr(i95BilltoCityErrorTxt, 1, 250);
                "Bill-to Post Code" = '':
                    "i95 Sync Message" := copystr(i95BilltoPostCodeErrorTxt, 1, 250);
                "Shipping Agent Code" = '':
                    "i95 Sync Message" := copystr(StrSubstNo(i95SyncErrorTxt, FieldCaption("Shipping Agent Code")), 1, 250);
                "Payment Method Code" = '':
                    "i95 Sync Message" := copystr(StrSubstNo(i95SyncErrorTxt, FieldCaption("Payment Method Code")), 1, 250);

            end;
        end;

        /*  //Check Mapping Fields
          If ((Rec."Shipping Agent Code" <> '') or (Rec."Shipping Agent Service Code" <> '')) and ("i95 Sync Message" = '') then begin
              ShippingAgentMapping.Reset();
              ShippingAgentMapping.SetRange(ShippingAgentMapping."BC Shipping Agent Code", Rec."Shipping Agent Code");
              If Rec."Shipping Agent Service Code" <> '' then
                  ShippingAgentMapping.setrange(ShippingAgentMapping."BC Shipping Agent Service Code", Rec."Shipping Agent Service Code");
              If ShippingAgentMapping.IsEmpty() then
              Rec."i95 Sync Message" := copystr(StrSubstNo(i95ShippingAgentErrorTxt, Rec."Shipping Agent Code"), 1, 250)

          end;*/
        IF not (Rec."Document Type" = Rec."Document Type"::Quote) then
            If (not (Rec."Shipping Agent Code" <> '')) and ("i95 Sync Message" = '') then
                Rec."i95 Sync Message" := copystr(StrSubstNo(i95ShippingAgentErrorTxt, Rec."Shipping Agent Code"), 1, 250);

        IF not (Rec."Document Type" = Rec."Document Type"::Quote) then
            IF (not (Rec."Shipping Agent Service Code" <> '')) and ("i95 Sync Message" = '') then
                Rec."i95 Sync Message" := copystr(StrSubstNo(i95ShippingAgentServiceErrorTxt, Rec."Shipping Agent Code"), 1, 250);

        IF (Rec."Document Type" = Rec."Document Type"::Quote) then
            IF (Rec.Status <> Rec.Status::Released) and ("i95 Sync Message" = '') then
                Rec."i95 Sync Message" := copystr(StrSubstNo(i95SalesQuoteStatusText), 1, 250);

        IF "Document Type" = "Document Type"::"Return Order" then begin
            IF "Applies-to Doc. No." = '' then
                IF "External Document No." = '' then begin
                    Rec."i95 Sync Message" := CopyStr(StrSubstNo(i95ExternalDocumentNotext), 1, 250);
                end;


        end;

        /*  If (Rec."Payment Method Code" <> '') and ("i95 Sync Message" = '') then begin
              PaymentMethodsMapping.Reset();
              PaymentMethodsMapping.SetRange(PaymentMethodsMapping."BC Payment Method Code", Rec."Payment Method Code");
              PaymentMethodsMapping.SetRange(PaymentMethodsMapping."BC to Ecommerce Default", true);
              If PaymentMethodsMapping.FindFirst() then
                  PaymentMethodErrorExists := false
              else begin
                  PaymentMethodsMapping.SetRange(PaymentMethodsMapping."BC to Ecommerce Default");
                  If not paymentMethodsMapping.IsEmpty() then
                      PaymentMethodErrorExists := false
                  else
                      PaymentMethodErrorExists := true;
              end;
              if PaymentMethodErrorExists then
          end;*/
        IF not (Rec."Document Type" = Rec."Document Type"::Quote) then
            If (not (Rec."Payment Method Code" <> '')) and ("i95 Sync Message" = '') then
                Rec."i95 Sync Message" := copystr(StrSubstNo(i95PaymentMethodErrorTxt, Rec."Payment Method Code"), 1, 250);

        if ("i95 Sync Message" = '') then
            if not i95SalesLineExists() then
                Rec."i95 Sync Message" := copystr(i95SalesLineErrorTxt, 1, 250);

        //Check Sales Lines
        if ("i95 Sync Message" = '') then begin
            SalesLine.Reset();
            SalesLine.SetRange(SalesLine."Document Type", Rec."Document Type");
            SalesLine.SetRange(SalesLine."Document No.", rec."No.");
            If SalesLine.FindSet() then
                repeat
                    case true of
                        SalesLine."No." = '':
                            "i95 Sync Message" := copystr(StrSubstNo(i95SyncSalesLineErrorTxt, salesline.FieldCaption(SalesLine."No."), SalesLine.TableCaption()), 1, 250);
                        SalesLine.Quantity = 0:
                            "i95 Sync Message" := copystr(StrSubstNo(i95SyncSalesLineErrorTxt, salesline.FieldCaption(SalesLine.Quantity), SalesLine.TableCaption()), 1, 250);
                        SalesLine."Unit Price" = 0:
                            "i95 Sync Message" := copystr(StrSubstNo(i95SyncSalesLineErrorTxt, SalesLine.FieldCaption(SalesLine."Unit Price"), SalesLine.TableCaption()), 1, 250);
                    end;

                    If Item.get(SalesLine."No.") then begin
                        ItemVariant.Reset();
                        ItemVariant.SetRange(ItemVariant."Item No.", item."No.");
                        If not ItemVariant.IsEmpty() then
                            If SalesLine."Variant Code" = '' then
                                "i95 Sync Message" := copystr(StrSubstNo(i95SyncSalesLineErrorTxt, salesline.FieldCaption(SalesLine."Variant Code"), SalesLine.TableCaption()), 1, 250);
                    end;
                until SalesLine.Next() = 0;
        end;
    end;

    procedure SetCalledFromPosting(Flag: Boolean)
    begin
        CalledFromSalesPost := Flag;
    end;

    var
        UpdatedFromi95PullRequest: Boolean;
        i95SyncErrorTxt: Label '%1 cannot be blank';
        i95SyncSalesLineErrorTxt: Label '%1 cannot be blank on %2';
        CalledFromSalesPost: Boolean;
        i95EntityMapping: Record "i95 Entity Mapping";
}