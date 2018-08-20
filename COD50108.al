codeunit 50108 "Export Netting"
{
    // version CHG-9136

    // SHTOMA DR-302 New Codeunit


    trigger OnRun();
    begin
        IF StenaSetup.GET THEN;
        IF CompanyInformation.GET THEN;
        IF GeneralLedgerSetup.GET THEN;

        ExportCustomerLedgerEntry;
        ExportVendorLedgerEntry;

        IF GUIALLOWED THEN
         MESSAGE(Text300);
    end;

    var
        F : File;
        Str : Text[1024];
        StenaSetup : Record 50109;
        CompanyInformation : Record 79;
        GeneralLedgerSetup : Record 98;
        Text100 : TextConst ENU='VAT Registration No is missing, customer %1,',SVE='Momsregistreringsnr för kund %1 saknas!';
        Text200 : TextConst ENU='VAT Registration No is missing, vendor %1.',SVE='Momsregistreringsnr för leverantör %1 saknas!';
        Text300 : TextConst ENU='Netting file is created.',SVE='Netting fil är skapad.';

    local procedure ExportCustomerLedgerEntry();
    var
        CustLedgerEntry : Record 21;
        Customer_rec : Record 18;
        CurrencyCode : Code[10];
    begin
        F.WRITEMODE(TRUE);
        F.TEXTMODE(TRUE);

        F.CREATE(StenaSetup."Export Path" + 'AR-'+CompanyInformation.Name+'-'+
                     FORMAT(TODAY,0,'<Year4><Month,2><Day,2>')+'-'+FORMAT(TIME,0,'<Hours24><Minutes,2><Seconds,2>')+'.txt');

        //Export Customer Ledger Entry AR
        CustLedgerEntry.RESET;
        CustLedgerEntry.SETCURRENTKEY(Open,"Due Date");
        CustLedgerEntry.SETRANGE(Open,TRUE);
        CustLedgerEntry.SETFILTER("Document Type",'%1|%2',CustLedgerEntry."Document Type"::Invoice,
                                                          CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SETRANGE("Customer Posting Group",StenaSetup."Customer Posting Group");
        IF CustLedgerEntry.FIND('-') THEN
          REPEAT
            CustLedgerEntry.CALCFIELDS("Remaining Amount");
            IF CustLedgerEntry."Currency Code" = '' THEN
              CurrencyCode := GeneralLedgerSetup."LCY Code"
            ELSE
              CurrencyCode := CustLedgerEntry."Currency Code";
            Customer_rec.RESET;
            IF Customer_rec.GET(CustLedgerEntry."Customer No.") THEN BEGIN
              IF Customer_rec.Netting THEN BEGIN
                IF Customer_rec."VAT Registration No." = '' THEN
                  ERROR(Text100,Customer_rec."No.");
                IF CustLedgerEntry."External Document No." = '' THEN BEGIN
                  Str := 'INV_AR' + ';' + '' + ';' + CustLedgerEntry."Document No." + ';' + Customer_rec."VAT Registration No." + ';' +
                          CompanyInformation."VAT Registration No." + ';' + CurrencyCode + ';' +
                           FORMAT(CustLedgerEntry."Remaining Amount",0,'<Precision,2><Sign><Integer><Decimals>') + ';' +
                            FORMAT(CustLedgerEntry."Posting Date",0,'<Year4><Month,2><Day,2>') + ';' +
                             FORMAT(CustLedgerEntry."Due Date",0,'<Year4><Month,2><Day,2>') +
                              ';' + '' + ';' + '' + ';' + '' + ';' + '' + ';' + CustLedgerEntry."Document No." +
                                ';' + '' + ';' + '' + ';' + '' + ';' + '' + ';' + 'R';
                  F.Write(Str);
                END ELSE BEGIN
                  Str := 'INV_AR' + ';' + '' + ';' + CustLedgerEntry."External Document No." + ';' + Customer_rec."VAT Registration No." + ';' +
                        CompanyInformation."VAT Registration No." + ';' + CurrencyCode + ';' +
                         FORMAT(CustLedgerEntry."Remaining Amount",0,'<Precision,2><Sign><Integer><Decimals>') + ';' +
                          FORMAT(CustLedgerEntry."Posting Date",0,'<Year4><Month,2><Day,2>') + ';' +
                           FORMAT(CustLedgerEntry."Due Date",0,'<Year4><Month,2><Day,2>') +
                            ';' + '' + ';' + '' + ';' + '' + ';' + '' + ';' + CustLedgerEntry."Document No." +
                              ';' + '' + ';' + '' + ';' + '' + ';' + '' + ';' + 'S';
                  F.WRITE(Str);
                END;
              END;
            END;
          UNTIL CustLedgerEntry.NEXT = 0;

        F.CLOSE;
    end;

    local procedure ExportVendorLedgerEntry();
    var
        VendorLedgerEntry : Record 25;
        Vendor_rec : Record 23;
        CurrencyCode : Code[10];
    begin

        F.WRITEMODE(TRUE);
        F.TEXTMODE(TRUE);

        F.CREATE(StenaSetup."Export Path" + 'AP-'+CompanyInformation.Name+'-'+
                     FORMAT(TODAY,0,'<Year4><Month,2><Day,2>')+'-'+FORMAT(TIME,0,'<Hours24><Minutes,2><Seconds,2>')+'.txt');

        //Export Vendor Ledger Entry AP
        VendorLedgerEntry.RESET;
        VendorLedgerEntry.SETCURRENTKEY(Open,"Due Date");
        VendorLedgerEntry.SETRANGE(Open,TRUE);
        VendorLedgerEntry.SETFILTER("Document Type",'%1|%2',VendorLedgerEntry."Document Type"::Invoice,
                                                          VendorLedgerEntry."Document Type"::"Credit Memo");
        VendorLedgerEntry.SETRANGE("Vendor Posting Group",StenaSetup."Vendor Posting Group");
        IF VendorLedgerEntry.FIND('-') THEN
          REPEAT
            VendorLedgerEntry.CALCFIELDS("Remaining Amount");
            IF VendorLedgerEntry."Currency Code" = '' THEN
              CurrencyCode := GeneralLedgerSetup."LCY Code"
            ELSE
              CurrencyCode := VendorLedgerEntry."Currency Code";
            Vendor_rec.RESET;
            IF Vendor_rec.GET(VendorLedgerEntry."Vendor No.") THEN BEGIN
              IF Vendor_rec.Netting THEN BEGIN
                IF Vendor_rec."VAT Registration No." = '' THEN
                  ERROR(Text200,Vendor_rec."No.");

               Str := 'INV_AP' + ';' + '' + ';' + VendorLedgerEntry."External Document No." + ';' +
                       CompanyInformation."VAT Registration No." + ';' + Vendor_rec."VAT Registration No." + ';' + CurrencyCode + ';' +
                        FORMAT((VendorLedgerEntry."Remaining Amount" * -1),0,'<Precision,2><Sign><Integer><Decimals>') + ';' +
                         FORMAT(VendorLedgerEntry."Posting Date",0,'<Year4><Month,2><Day,2>') + ';' +
                          FORMAT(VendorLedgerEntry."Due Date",0,'<Year4><Month,2><Day,2>') +
                          ';' + '' + ';' + '' + ';' + '' + ';' + VendorLedgerEntry."Document No." + ';' + '' + ';' + '' + ';' +
                           '' + ';' + '' + ';' + '' + ';' + '';
              F.WRITE(Str);
              END;
            END;
          UNTIL VendorLedgerEntry.NEXT = 0;

        F.CLOSE;
    end;
}

