tableextension 50000 Customer_Net extends Customer 
{
    fields
    {
        field(50121;Netting;Boolean)
        {
            CaptionML = ENU= 'Netting' , SVE= 'Netting'; 
            Description = 'Netting_Ext';
        }       
    }
}

