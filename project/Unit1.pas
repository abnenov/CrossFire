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
    function inHorizontalCorridor(): boolean;
    function inVerticalCorridor(): boolean;
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
  endLeft = 175;
  endRight = 975;
  endUp = 166;
  endDown = 806;
  moveStep = 10;

var
  Form1: TForm1;
  gridImages: array [0 .. 5, 0 .. 6, 0 .. 78] of TImage;
  imgTimers: array [0 .. 5, 0 .. 6] of integer;
  shipX, shipY: integer;
  moveLeft, moveRight, moveUp, moveDown: Char;
  shotLeft, shotRight, shotUp, shotDown, moveStop: Char;
  lastMoveKey, lastShotKey, currentMoveKey: Char;
  verticalCorridors: array [0 .. 5] of integer;
  horizontalCorridors: array [0 .. 4] of integer;

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
  moveStop := chr(32);
  verticalCorridors[0] := 175;
  verticalCorridors[1] := 335;
  verticalCorridors[2] := 495;
  verticalCorridors[3] := 655;
  verticalCorridors[4] := 815;
  verticalCorridors[5] := 975;
  horizontalCorridors[0] := 166;
  horizontalCorridors[1] := 326;
  horizontalCorridors[2] := 486;
  horizontalCorridors[3] := 646;
  horizontalCorridors[4] := 806;
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
  shipX := verticalCorridors[3];
  shipY := horizontalCorridors[4];
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
  if (currentMoveKey = moveLeft) and (shipX > endLeft) and inHorizontalCorridor()
  then
  begin
    shipX := shipX - moveStep;
  end;
  if (currentMoveKey = moveRight) and (shipX < endRight) and inHorizontalCorridor()
  then
  begin
    shipX := shipX + moveStep;
  end;
  if (currentMoveKey = moveUp) and (shipY > endUp) and inVerticalCorridor() then
  begin
    shipY := shipY - moveStep;
  end;
  if (currentMoveKey = moveDown) and (shipY < endDown) and inVerticalCorridor()
  then
  begin
    shipY := shipY + moveStep;
  end;
  if ((lastMoveKey=moveLeft) or (lastMoveKey=moveRight)) and inHorizontalCorridor() then
  begin
     currentMoveKey:=lastMoveKey;
  end;
  if ((lastMoveKey=moveUp) or (lastMoveKey=moveDown)) and inVerticalCorridor() then
  begin
     currentMoveKey:=lastMoveKey;
  end;
  if (lastMoveKey=moveStop) and inHorizontalCorridor() and inVerticalCorridor() then
  begin
     currentMoveKey:=lastMoveKey;
  end;
  Ship.Left := shipX;
  Ship.Top := shipY;
end;

function TForm1.inHorizontalCorridor(): boolean;
var
  i: integer;
begin
  for i := 0 to 4 do
  begin
    if shipY = horizontalCorridors[i] then
    begin
      inHorizontalCorridor := true;
      break;
    end
    else inHorizontalCorridor:=false;
  end;
end;

function TForm1.inVerticalCorridor(): boolean;
var
  i: integer;
begin
  for i := 0 to 5 do
  begin
    if shipX = verticalCorridors[i] then
    begin
      inVerticalCorridor := true;
      break;
    end
    else  inVerticalCorridor:=false;
  end;

end;

end.
