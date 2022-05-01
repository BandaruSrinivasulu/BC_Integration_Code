PageExtension 70008 "i95 User Setup Ext" extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("i95 Show i95 Data"; Rec."i95 Show i95 Data")
            {
                ApplicationArea = All;
                Caption = 'Show i95Dev Details';
                ToolTip = 'Specifies if the user can view i95Dev fields';
            }
        }
    }
}
