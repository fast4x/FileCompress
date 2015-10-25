unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, process, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, AsyncProcess, ExtCtrls, ComCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    AProcess1: TAsyncProcess;
    Bevel1: TBevel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    chkbak: TCheckBox;
    Image1: TImage;
    Memo1: TMemo;
    Memo2: TMemo;
    Open: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Process1: TProcess;
    opt: TRadioGroup;
    Save: TSaveDialog;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Timer1: TTimer;
    procedure AProcess1Terminate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation
uses about;
{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var a:word;
    mr: tstringlist;
    flist:string;
begin
  button1.Enabled:=false;
  opt.Enabled:=false;
  chkbak.Enabled:=false;
  memo1.Lines.Clear;
  memo2.Lines.Clear;

  if opt.ItemIndex = 0 then begin
  open.Title:='Seleziona uno o più eseguibili da comprimere';
  if open.Execute then begin
//  showmessage(open.Files.CommaText);
    for a:=0 to open.Files.Count-1 do begin
       Panel2.Caption:='Compressione di '+open.Files[a]+' in corso...';
//     save.FileName:=open.FileName;
//      if save.Execute then  begin
//         process1.Executable :='upx';
         process1.CurrentDirectory:=extractfilepath(open.Files[a]);
         //showmessage(open.filename);
         process1.Parameters.Clear;
//         process1.Parameters.Add('-o'+save.FileName);
         if chkbak.Checked = true then  process1.Parameters.Add('--backup');
         process1.Parameters.Add(open.Files[a]);
         process1.Execute;
        // progressbar1.Style:=pbstMarquee;
          mr:=tstringlist.Create;
         while process1.Running do
            begin
                 application.ProcessMessages;
                 mr.LoadFromStream(process1.Output);
                 memo1.Lines.AddStrings(mr);

            end;
//         timer1.Enabled:=true;

         mr.Clear;
         mr.LoadFromStream(process1.Stderr);
          memo2.Lines.AddStrings(mr);

          tabsheet1.Show;
          if memo2.Lines.Count > 0 then tabsheet2.Show;
         mr.Free;


         //showmessage('ok');
//      end;
    end;
    Panel2.Caption:='Compressione completata.';
  end;
  end;

  if opt.ItemIndex = 1 then begin
     open.Title:='Seleziona uno o più eseguibili da decomprimere';
  if open.Execute then begin

     for a:=0 to open.Files.Count-1 do begin
        Panel2.Caption:='Decompressione di '+open.Files[a]+' in corso...';
//     save.FileName:=open.FileName;
//      if save.Execute then  begin
//         process1.Executable :='upx';
         process1.CurrentDirectory:=extractfilepath(open.Files[a]);
         //showmessage(open.filename);
         process1.Parameters.Clear;
         process1.Parameters.Add('-d');
         if chkbak.Checked = true then  process1.Parameters.Add('--backup');
         process1.Parameters.Add(open.Files[a]);
//         process1.Parameters.Add(save.FileName);
         process1.Active:=true;
//         timer1.Enabled:=true;

         application.ProcessMessages;
         mr:=tstringlist.Create;

          while process1.Running do
            begin
                 application.ProcessMessages;
                 mr.LoadFromStream(process1.Output);
                 memo1.Lines.AddStrings(mr);

            end;

         mr.Clear;
         mr.LoadFromStream(process1.Stderr);
          memo2.Lines.AddStrings(mr);

          tabsheet1.Show;
          if memo2.Lines.Count > 0 then tabsheet2.Show;
         mr.Free;


         //showmessage('ok');
//      end;
     end;
  end;
  Panel2.Caption:='Decompressione completata.';
  end;

  if opt.ItemIndex = 2 then begin
     open.Title:='Seleziona uno o più eseguibili da verificare';
   if open.Execute then begin
      for a:=0 to open.Files.Count-1 do begin
         Panel2.Caption:='Verifica di '+open.Files[a]+' in corso...';
//      save.FileName:=open.FileName;
//       if save.Execute then  begin
//          process1.Executable :='upx';
          process1.CurrentDirectory:=extractfilepath(open.Files[a]);
//          showmessage(open.filename);
          process1.Parameters.Clear;
          process1.Parameters.Add('-t');
          process1.Parameters.Add(open.Files[a]);
//          aprocess1.Parameters.Add('-o'+save.FileName);
          process1.Active:=true;
//          timer1.Enabled:=true;

          application.ProcessMessages;
          //showmessage('ok');
         mr:=tstringlist.Create;

         while process1.Running do
                    begin
                         application.ProcessMessages;

                         mr.LoadFromStream(process1.Output);
                         memo1.Lines.AddStrings(mr);

                    end;
         mr.Clear;
         mr.LoadFromStream(process1.Stderr);
          memo2.Lines.AddStrings(mr);

          tabsheet1.Show;
          if memo2.Lines.Count > 0 then tabsheet2.Show;
         mr.Free;

//       end;
      end;
   end;
     Panel2.Caption:='Verifica completata.';
   end;

  button1.Enabled:=true;
  opt.Enabled:=true;
  chkbak.Enabled:=true;


end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  form2.ShowModal;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  {$ifdef Unix}
      {$ifdef CPU32}
       process1.Executable:=extractfilepath(application.ExeName)+'/upx/upx';
      {$endif}
      {$ifdef CPU64}
       process1.Executable:=extractfilepath(application.ExeName)+'/upx/upx_amd64';
      {$endif}
  {$endif}
  {$ifdef Windows}
   process1.Executable:=extractfilepath(application.ExeName)+'\upx\upx.exe';
  {$endif}

end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  application.ProcessMessages;
  if process1.Running = false then begin
     timer1.Enabled:=false;
//  memo1.Lines.add('controllo stato...');

     memo1.Lines.LoadFromStream(process1.Output);
     memo2.Lines.LoadFromStream(process1.Stderr);

     tabsheet1.Show;
     if memo2.Lines.Count > 0 then tabsheet2.Show;

  end;
  application.ProcessMessages;
end;

procedure TForm1.AProcess1Terminate(Sender: TObject);
begin

end;

end.

