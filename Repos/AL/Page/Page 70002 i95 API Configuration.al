Page 70002 "i95 API Configuration"
{
    Caption = 'i95Dev API Configuration';
    PageType = List;
    SourceTable = "i95 API Configuration";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater("i95 API Configuration")
            {
                field("API Type"; Rec."API Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Type of i95Dev Api';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Description';
                }
                field("Request Type"; Rec."Request Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Type of Request';
                }
                field("PushData Url"; Rec."PushData Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Push Data Url';
                }
                field("PullResponse Url"; Rec."PullResponse Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Pull Response Url';
                }
                field("PullResponseAck Url"; Rec."PullResponseAck Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Pull Response Acknowledgement Url';
                }
                field("PullData Url"; Rec."PullData Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Pull Data Url';
                }
                field("PushResponse Url"; Rec."PushResponse Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Push Response Url';
                }
            }
        }
    }
}
