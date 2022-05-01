table 70009 "i95 Product Attribute Mapping"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            DataClassification = CustomerContent;
        }

        field(2; BCAttribute; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(3; MagentoAttribute; text[100])
        {
            DataClassification = CustomerContent;
        }
        field(4; IsEcommerceDefault; Boolean)
        {
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';
        }
        field(5; IsErpDefault; Boolean)
        {
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Field not in use';
        }
    }

    keys
    {
        key(Entryno; "Entry No")
        {
            Clustered = true;
        }

        key(PK; BCAttribute)
        {

        }
        key(MagentoAttribute; MagentoAttribute)
        {

        }
    }

}