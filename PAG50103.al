pageextension 50103 Vendor_Card_Net extends "Vendor Card" 
{
    layout
    {
        addlast("Invoicing")
        {
            field(Netting;Netting)
            {
                CaptionML = ENU='Netting',SVE= 'Netting';
            }
        }
    }    
}

