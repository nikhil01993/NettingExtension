report 50106 "Import Netting Customer"
{
    UsageCategory = Tasks;
    // version CHG-9136

    // SHTOMA DR-302 New Report

    CaptionML = ENU='Import Netting Customer',
                SVE='Importera Netting Kund';
    ProcessingOnly = true;

    dataset
    {
        dataitem(DataItem1100560000;Integer)
        {
            DataItemTableView = SORTING(Number);

            trigger OnAfterGetRecord();
            var
                lType : Text[2];
                lAmount : Decimal;
                lCurrencyFactor : Decimal;
                GenJnlLine_rec : Record 81;
                TransferAmount_dec : Decimal;
            begin

                IF TextFile.LEN = TextFile.POS THEN
                  CurrReport.BREAK;

                w.UPDATE(1,ROUND(TextFile.POS/TextFile.LEN*10000,1.0));

                //Läs in den semikolonseparerade filen i en array
                TextFile.READ(TextLine);
                importedLines+=1;
                x:=1;
                FOR i:=1 TO STRLEN(TextLine) DO BEGIN
                  IF COPYSTR(TextLine,i,1)<>';' THEN BEGIN
                    IF STRLEN(textdim[x]) < 150 THEN
                      textdim[x] := (textdim[x])+COPYSTR(TextLine,i,1);
                  END
                  ELSE BEGIN
                    x+=1;
                  END;
                END;

                GenJnlLine_rec.INIT;
                GenJnlLine_rec."Journal Template Name" := GenJnlTemplate.Name;
                GenJnlLine_rec."Journal Batch Name" := GenJnlBatch.Name;
                NextLineNo_int := NextLineNo_int + 10000;
                GenJnlLine_rec."Line No." := NextLineNo_int;
                GenJnlLine_rec."Source Code" := GenJnlTemplate."Source Code";
                //NA [1]
                //NA [2]

                //Payment Date [20] Settlement Date
                EVALUATE(PostingDateDate,textdim[20]);
                GenJnlLine_rec.VALIDATE("Posting Date",PostingDateDate);

                //Invoice No. [3] and [13]
                Category := textdim[19];
                IF Category = 'R' THEN BEGIN
                GenJnlLine_rec.VALIDATE("Account Type", GenJnlLine_rec."Account Type"::Customer);
                //ApplyToDocNo_cod := textdim[3];
                ApplyToDocNo_cod := textdim[14];
                IF InvoiceExist_func THEN
                  GenJnlLine_rec.VALIDATE("Applies-to Doc. No.", ApplyToDocNo_cod);
                  IF GenJnlLine_rec."Applies-to Doc. No." = '' THEN BEGIN
                    IF CreditMemoExist_func THEN
                      GenJnlLine_rec.VALIDATE("Applies-to Doc. No.", ApplyToDocNo_cod);
                  END;
                END ELSE BEGIN
                  GenJnlLine_rec.VALIDATE("Account Type", GenJnlLine_rec."Account Type"::Customer);
                  ApplyToDocNo_cod := textdim[14];
                  IF InvoiceExist_func THEN
                    GenJnlLine_rec.VALIDATE("Applies-to Doc. No.", ApplyToDocNo_cod);
                    IF GenJnlLine_rec."Applies-to Doc. No." = '' THEN BEGIN
                      IF CreditMemoExist_func THEN
                        GenJnlLine_rec.VALIDATE("Applies-to Doc. No.", ApplyToDocNo_cod);
                    END;
                END;
                //NA Payer [4]

                //NA Payee [5]

                //NA Currency [6]

                //Amount [7]
                EVALUATE(TransferAmount_dec, textdim[7]);
                GenJnlLine_rec.VALIDATE(Amount, (TransferAmount_dec * -1));
                IF GenJnlLine_rec.Amount > 0 THEN BEGIN
                  GenJnlLine_rec.VALIDATE(Description,GenJnlLine_rec."Applies-to Doc. No." + ' ' + BA001);
                END ELSE BEGIN
                  GenJnlLine_rec.VALIDATE(Description,GenJnlLine_rec."Applies-to Doc. No." + ' ' + BA002);
                  //DR-254 170411 >>
                  CustLedgerEntry_rec.CALCFIELDS("Remaining Amount");
                  IF CustLedgerEntry_rec."Remaining Amount" <> 0 THEN BEGIN
                    IF ABS(GenJnlLine_rec.Amount) < ABS(CustLedgerEntry_rec."Remaining Amount") THEN
                      GenJnlLine_rec.VALIDATE(Description,ErrAmountLess+GenJnlLine_rec."Applies-to Doc. No.");
                    IF ABS(GenJnlLine_rec.Amount) > ABS(CustLedgerEntry_rec."Remaining Amount" ) THEN
                      GenJnlLine_rec.VALIDATE(Description,ErrAmountMore+GenJnlLine_rec."Applies-to Doc. No.");
                  //DR-254 170411 <<
                  END;
                END;

                //NA Issued Date [8]

                //NA Due Date [9]

                //NA [10]
                //NA [11]
                //NA [12]
                //NA [13]

                //External Document No. [14] UserRef2
                IF Category = 'S' THEN
                  GenJnlLine."External Document No." := textdim[3]
                ELSE
                  GenJnlLine."External Document No." := '';

                //NA [15]
                //NA [16]
                //NA [17]
                //NA [18]

                //Category [19]

                GenJnlLine_rec.VALIDATE("Document No.",DocNo);
                IF GenJnlLine_rec."Applies-to Doc. No." = '' THEN
                  GenJnlLine_rec.VALIDATE(Description,COPYSTR(BA003+ ' ' + ApplyToDocNo_cod,1,50))
                //DR-254 170418 >>
                ELSE
                  IF GenJnlLine_rec."Currency Code" <> SetCurrencyCode(textdim[6]) THEN
                    GenJnlLine_rec.VALIDATE(Description,STRSUBSTNO(BA010,textdim[6],GenJnlLine_rec."Currency Code"));

                IF SetCurrencyCode(textdim[6]) <> GenJnlLine_rec."Currency Code" THEN
                  GenJnlLine_rec.VALIDATE("Currency Code", SetCurrencyCode(textdim[6]));
                //DR-254 170418 <<
                GenJnlLine_rec."Posting No. Series" := GenJnlBatch."Posting No. Series";
                GenJnlLine_rec.INSERT;

                CLEAR(textdim);
            end;

            trigger OnPostDataItem();
            begin
                TextFile.CLOSE;
                w.CLOSE;
            end;

            trigger OnPreDataItem();
            begin
                IF FileName = '' THEN
                  ERROR(BA005);

                //DR-254 170411 >>
                ServerFileName := FileMgt.UploadFileSilent(FileName);
                //DR-254 170411 <<
                CLEAR(TextFile);
                TextFile.TEXTMODE := TRUE;
                //DR-254 170411 >>
                //TextFile.OPEN(FileName);
                TextFile.OPEN(ServerFileName);
                //DR-254 170411 <<
                GenJnlBatch.GET(GenJnlLine."Journal Template Name",GenJnlLine."Journal Batch Name");
                GenJnlTemplate.GET(GenJnlLine."Journal Template Name");
                DocNo := NoSeriesMgt.GetNextNo(GenJnlBatch."No. Series",WORKDATE,FALSE);
                GLSetup.GET;

                GenJnlLine.RESET;
                GenJnlLine.SETRANGE("Journal Template Name",GenJnlLine."Journal Template Name");
                GenJnlLine.SETRANGE("Journal Batch Name",GenJnlLine."Journal Batch Name");
                GenJnlLine.DELETEALL;

                w.OPEN('@1@@@@@@@@@@@@@@@@@@@@@@@@@');
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    field(FileName;FileName)
                    {
                        AssistEdit = true;
                        CaptionML = ENU='File Name',
                                    SVE='Filnamn';

                        trigger OnAssistEdit();
                        begin
                            FileName := CommonDlgMgt.OpenFileDialog(BA008,FileName,BA007);
                        end;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        TextFile : File;
        FileName : Text[250];
        TextLine : Text[1024];
        DocNo : Code[20];
        JnlTemplateName : Code[10];
        JnlBatchName : Code[10];
        GenJnlBatch : Record 232;
        GLSetup : Record 98;
        GenJnlTemplate : Record 80;
        w : Dialog;
        GenJnlLine : Record 81;
        GLAccount : Record 15;
        NoSeriesMgt : Codeunit 396;
        importedLines : Integer;
        textdim : array [25] of Text[150];
        x : Integer;
        i : Integer;
        Radnr : Integer;
        CustLedgerEntry_rec : Record 21;
        ApplyToDocNo_cod : Code[20];
        NextLineNo_int : Integer;
        PostingDateDate : Date;
        StenaSetup : Record 50109;
        Category : Text;
        BA005 : Label 'Enter File Name';
        BA007 : Label 'All files|*.*|TXT-files (*.txt)|*.txt|WRI-files (*.wri)|*.wri';
        BA008 : TextConst ENU='Stena',SVE='Stena';
        BA001 : Label 'Deduction, Credit Memo';
        BA002 : Label 'Payment, Invoice';
        BA003 : Label 'Reference incorrect';
        BA004 : Label 'OCR-payment';
        ErrAmountLess : TextConst ENU='Part payment: ',SVE='Delbetalning: ';
        ErrAmountMore : TextConst ENU='Over payment: ',SVE='Överbetalning: ';
        CommonDlgMgt : Codeunit 419;
        ServerFileName : Text;
        FileMgt : Codeunit 419;
        BA010 : TextConst ENU='Currency % differs from Ledger Entry %2',SVE='Valutakod %1 skiljer sig från reskontran %2';

    procedure SetGenJnlLine(NewGLJnlLine : Record 81);
    begin
        GenJnlLine := NewGLJnlLine;
        JnlTemplateName := GenJnlLine."Journal Template Name";
        JnlBatchName := GenJnlLine."Journal Batch Name";
    end;

    local procedure InvoiceExist_func() : Boolean;
    begin
        CustLedgerEntry_rec.INIT;
        CustLedgerEntry_rec.RESET;
        CustLedgerEntry_rec.SETCURRENTKEY("Document Type","Document No.","Customer No.");
        CustLedgerEntry_rec.SETRANGE("Document Type",CustLedgerEntry_rec."Document Type"::Invoice);
        CustLedgerEntry_rec.SETRANGE("Document No.",ApplyToDocNo_cod);
        CustLedgerEntry_rec.SETRANGE(Open,TRUE);
        IF CustLedgerEntry_rec.FIND('-') THEN BEGIN
          CustLedgerEntry_rec.CALCFIELDS(Amount);
          EXIT(TRUE);
        END ELSE BEGIN
          EXIT(FALSE);
        END;
    end;

    local procedure CreditMemoExist_func() : Boolean;
    begin
        CustLedgerEntry_rec.INIT;
        CustLedgerEntry_rec.RESET;
        CustLedgerEntry_rec.SETCURRENTKEY("Document Type","Document No.","Customer No.");
        CustLedgerEntry_rec.SETRANGE("Document Type", CustLedgerEntry_rec."Document Type"::"Credit Memo");
        CustLedgerEntry_rec.SETRANGE("Document No.",ApplyToDocNo_cod);
        CustLedgerEntry_rec.SETRANGE(Open,TRUE);
        IF CustLedgerEntry_rec.FIND('-') THEN
          EXIT(TRUE)
        ELSE
          EXIT(FALSE);
    end;

    procedure SetCurrencyCode(PCode : Code[30]) : Code[30];
    begin
        GLSetup.TESTFIELD("LCY Code");
        IF PCode = GLSetup."LCY Code" THEN
          EXIT('')
        ELSE
          EXIT(PCode);
    end;
}

