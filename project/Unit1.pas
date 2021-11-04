unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.GIFImg,
  Vcl.StdCtrls, Vcl.Imaging.pngimage, Vcl.Imaging.jpeg;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Ship: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Timer2: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

Const
  imgHeight = 116;
  imgWidth = 100;
  horizontalImageStep = 60;
  verticalImageStep = 45;
  leftImageOffset = 80;
  topImageOffset = 60;
  gridImageTimerInterval = 70;
  shipHeight = 55;
  shipWidth = 55;
  endLeft = 174;
  endRight = 975;
  endUp = 166;
  endDown = 810;
  moveStep = 1;

var
  Form1: TForm1;
  gridImages: array [0 .. 5, 0 .. 6, 0 .. 78] of TImage;
  imgTimers: array [0 .. 5, 0 .. 6] of integer;
  shipX, shipY: integer;
  moveLeft, moveRight, moveUp, moveDown: Char;
  shotLeft, shotRight, shotUp, shotDown,moveStop: Char;
  lastMoveKey, lastShotKey: Char;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  row, column, image: integer;
  pic: string;
begin
  moveLeft := 'j';
  moveRight := 'l';
  moveUp := 'i';
  moveDown := 'k';
  shotLeft := 'j';
  shotRight := 'l';
  shotUp := 'i';
  shotDown := 'k';
  moveStop:=chr(32);
  for row := 0 to 5 do
  begin
    for column := 0 to 6 do
    begin
      randomize;
      imgTimers[row, column] := random(39);
      Timer1.Interval := gridImageTimerInterval;
      for image := 0 to 39 do
      begin
        gridImages[row, column, image] := TImage.Create(self);
        gridImages[row, column, image].Parent := self;
        gridImages[row, column, image].SendToBack;
        gridImages[row, column, image].AutoSize := FALSE;
        gridImages[row, column, image].Height := imgHeight;
        gridImages[row, column, image].Width := imgWidth;
        gridImages[row, column, image].Top := topImageOffset + row *
          (gridImages[row, column, image].Height + verticalImageStep);
        gridImages[row, column, image].Left := leftImageOffset + column *
          (gridImages[row, column, image].Width + horizontalImageStep);
        gridImages[row, column, image].Visible := true;
        gridImages[row, column, image].Stretch := true;
        gridImages[row, column, image].Proportional := true;
        gridImages[row, column, image].Name := 'image' + inttostr(row) +
          inttostr(column) + inttostr(image);
        pic := 'C:\Users\ANenov\Documents\CrossFire\frames\' +
          inttostr(image) + '.gif';
        gridImages[row, column, image].Picture.LoadFromFile(pic);
        // imgs[c].OnClick := imgClick;
        gridImages[row, column, image].Refresh;
        gridImages[row, column, image].Picture.LoadFromFile(pic);
        gridImages[row, column, image].Visible := true;
        gridImages[row, column, image].Refresh;
      end;
    end;
  end;
  // (Image1.Picture.Graphic as TGIFImage).Animate := True;
  shipX := 664;
  shipY := 810;
  Timer1.Enabled := true;
  Timer2.Enabled := true;
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = moveLeft) then
  begin
    lastMoveKey := moveLeft;
  end;
  if (Key = moveRight) then
  begin
    lastMoveKey := moveRight;
  end;
  if (Key = moveUp) then
  begin
    lastMoveKey := moveUp;
  end;
  if (Key = moveDown) then
  begin
    lastMoveKey := moveDown;
  end;
  if (Key = moveStop) then
  begin
    lastMoveKey := moveStop;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  row, column, image: integer;
begin
  for row := 0 to 5 do
  begin
    for column := 0 to 6 do
    begin
      for image := 0 to 39 do
      begin
        if image <> imgTimers[row, column] then
        begin
          gridImages[row, column, image].Visible := FALSE;
          gridImages[row, column, image].Refresh;
        end
        else
        begin
          gridImages[row, column, image].Visible := true;
          gridImages[row, column, imgTimers[row, column]].Refresh;
        end;
      end;
      if imgTimers[row, column] = 39 then
        imgTimers[row, column] := 1
      else
        imgTimers[row, column] := imgTimers[row, column] + 1;
    end;
  end;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  if (lastMoveKey = moveLeft) and (shipX > endLeft) then
  begin
    shipX := shipX - moveStep;
  end;
  if (lastMoveKey = moveRight) and (shipX < endRight) then
  begin
    shipX := shipX + moveStep;
  end;
  if (lastMoveKey = moveUp) and (shipY > endUp) then
  begin
    shipY := shipY - moveStep;
  end;
  if (lastMoveKey = moveDown) and (shipY < endDown) then
  begin
    shipY := shipY + moveStep;
  end;
  Ship.Left := shipX;
  Ship.Top := shipY;
  Form1.Caption := 'X=' + inttostr(shipX) + ' Y=' + inttostr(shipY);
end;

end.
