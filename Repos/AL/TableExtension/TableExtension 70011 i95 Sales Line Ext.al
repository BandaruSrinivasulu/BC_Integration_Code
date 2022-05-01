Tableextension 70011 "i95 Sales Line Ext" extends "Sales Line"
{
    fields
    {
        field(70005; "i95 Created By"; Code[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Created By';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';
        }
        field(70006; "i95 Created DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created DateTime';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';
        }

        field(70007; "i95 Creation Source"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Creation Source';
            OptionMembers = " ","Business Central","i95";
            OptionCaption = ' ,"Business Central","i95Dev"';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';
        }
        field(70008; "i95 Last Modified By"; Code[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Last Modified By';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';
        }
        field(70009; "i95 Last Modification DateTime"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Modification DateTime';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';
        }
        field(70010; "i95 Last Modification Source"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ","Business Central","i95";
            OptionCaption = ' ,"Business Central","i95Dev"';
            Caption = 'Last Modification Source';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';
        }
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
            Caption = 'Last Sync DateTime';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';
        }
        field(70013; "i95 Reference ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Reference ID';
            Editable = false;
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';
        }
        field(70014; "i95 Sales Line Modified"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Line Modified';
            Editable = false;
        }
    }

    trigger OnAfterInsert()
    begin
        "i95 Sales Line Modified" := true;
        UpdateEditOrderSyncStatus();
    end;

    trigger OnAfterModify()
    var
        SalesHeader: Record "Sales Header";
        i95SyncLogEntry: Record "i95 Sync Log Entry";
    begin

        if (xRec.Quantity = Rec.Quantity) and ((xRec."Qty. to Ship" <> Rec."Qty. to Ship") or (xRec."Qty. to Invoice" <> Rec."Qty. to Invoice")) then
            exit;
        SalesHeader.get(Rec."Document Type", Rec."Document No.");
        if ((not i95SyncLogEntry.IsCancelledSalesOrder(SalesHeader.RecordId()) or i95SyncLogEntry.IsCancelledSalesQuote(SalesHeader.RecordId())) and (not CalledFromSalesPost)) then begin
            "i95 Sales Line Modified" := true;
            UpdateEditOrderSyncStatus();
        end;
    end;

    trigger OnBeforeDelete()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        i95SyncLogEntry: Record "i95 Sync Log Entry";
    begin
        SalesHeader.get(Rec."Document Type", Rec."Document No.");

        if ((not i95SyncLogEntry.IsCancelledSalesOrder(SalesHeader.RecordId()) or i95SyncLogEntry.IsCancelledSalesQuote(SalesHeader.RecordId()))) then begin
            SalesLine.SetRange("Document Type", "Document Type");
            SalesLine.SetRange("Document No.", "Document No.");
            SalesLine.SetFilter("Line No.", '<>%1', Rec."Line No.");
            if SalesLine.FindSet() then
                SalesLine.ModifyAll("i95 Sales Line Modified", true);

            UpdateEditOrderSyncStatus();
        end;
    end;

    procedure UpdateEditOrderSyncStatus()
    var
        SalesHeader: Record "Sales Header";
        i95PushWebServiceCU: Codeunit "i95 Push Webservice";
    begin
        SalesHeader.Reset();
        IF "Document Type" = "Document Type"::Quote then
            SalesHeader.SetRange(SalesHeader."Document Type", SalesHeader."Document Type"::Quote)
        else
            SalesHeader.SetRange(SalesHeader."Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange(SalesHeader."No.", Rec."Document No.");
        If SalesHeader.FindFirst() then
            If (SalesHeader."i95 Reference ID" <> '') then begin
                i95EntityMapping.Reset();
                IF i95EntityMapping.FindSet() then;
                IF i95EntityMapping."Allow ESalesOrder Oubound Sync" = true then
                    SalesHeader."i95 EditOrder Sync Status" := SalesHeader."i95 EditOrder Sync Status"::"Waiting for Sync";
                SalesHeader."i95 Order Status" := SalesHeader."i95 Order Status"::Edited;
                SalesHeader."i95 EditOrder Updated DateTime" := CurrentDateTime();
                SalesHeader.Modify(false);
            end else begin
                IF "Document Type" = "Document Type"::Order then begin
                    SalesHeader.CheckIfi95SyncAllowed;
                    i95EntityMapping.Reset();
                    IF i95EntityMapping.FindSet() then;
                    IF i95EntityMapping."Allow SalesOrder Oubound Sync" = true then
                        IF SalesHeader."i95 Sync Message" = '' then begin
                            SalesHeader."i95 Last Modification DateTime" := CurrentDateTime();
                            SalesHeader."i95 Last Modified By" := copystr(UserId(), 1, 80);
                            SalesHeader."i95 Last Sync DateTime" := CurrentDateTime();
                            SalesHeader."i95 Sync Status" := SalesHeader."i95 Sync Status"::"Waiting for Sync";
                            SalesHeader."i95 Last Modification Source" := SalesHeader."i95 Last Modification Source"::"Business Central";
                            SalesHeader.Modify(false);
                        end;

                end else begin
                    SalesHeader.CheckIfi95SyncAllowed;
                    i95EntityMapping.Reset();
                    IF i95EntityMapping.FindSet() then;
                    IF i95EntityMapping."Allow SalesQuote Outbound Sync" = true then
                        IF SalesHeader."i95 Sync Message" = '' then begin
                            SalesHeader."i95 Last Modification DateTime" := CurrentDateTime();
                            SalesHeader."i95 Last Modified By" := copystr(UserId(), 1, 80);
                            SalesHeader."i95 Last Sync DateTime" := CurrentDateTime();
                            SalesHeader."i95 Sync Status" := SalesHeader."i95 Sync Status"::"Waiting for Sync";
                            SalesHeader."i95 Last Modification Source" := SalesHeader."i95 Last Modification Source"::"Business Central";
                            SalesHeader.Modify(false);

                        end;


                end;

            end;

    end;

    procedure i95SetAPIUpdateCall(APICall: Boolean)
    begin
        UpdatedFromi95 := APICall;
    end;

    procedure SetCalledFromPosting(Flag: Boolean)
    begin
        CalledFromSalesPost := Flag;
    end;

    var
        UpdatedFromi95: Boolean;
        CalledFromSalesPost: Boolean;
        i95EntityMapping: Record "i95 Entity Mapping";
}