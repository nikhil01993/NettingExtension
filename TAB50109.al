table 50109 "Netting Setup"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1;"Primary Key";Code [10])
        {
            CaptionML = ENU= 'Primary Key' , SVE= 'Primärnyckel';            
            DataClassification = ToBeClassified;
        }
        field(2;"Export Path";Text [250])
        {
            CaptionML = ENU = 'Export Path' , SVE = 'Sökväg export';
            DataClassification = ToBeClassified;
        }
        field(3;"Customer Posting Group";Code [10])
        {
            TableRelation = "Customer Posting Group";
            CaptionML = ENU = 'Customer Posting Group' , SVE = 'Kundbokföringsmall';
            DataClassification = ToBeClassified;
        }
        field(4;"Vendor Posting Group";Code [10])
        {
            TableRelation = "Vendor Posting Group";
            CaptionML = ENU = 'Vendor Posting Group' , SVE = 'Leverantörsbokföringsmall';
            DataClassification = ToBeClassified;
        }
        field(5;"Import Path";Text [250])
        {            
            CaptionML = ENU = 'Import Path' , SVE='Sökväg import';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK;"Primary Key")
        {
            Clustered = true;
        }
    }
}