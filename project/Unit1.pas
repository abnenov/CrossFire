unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Math,
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
    Timer3: TTimer;
    ep1: TImage;
    enemyMove: TTimer;
    ep2: TImage;
    procedure FormCreate(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    function inHorizontalCorridor(): boolean;
    function inVerticalCorridor(): boolean;
    function enemyInHorizontalCorridor(enemy: integer): boolean;
    function enemyInVerticalCorridor(enemy: integer): boolean;
    procedure Timer1Timer(Sender: TObject);
    procedure Timer3Timer(Sender: TObject);
    procedure enemyMoveTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

Const
  imgHeight = 100;
  imgWidth = 100;
  horizontalBlockStep = 60;
  verticalBlockStep = 60;
  leftImageOffset = 80;
  topImageOffset = 60;
  gridImageTimerInterval = 70;
  shipHeight = 82;
  shipWidth = 82;

var
  Form1: TForm1;
  gridBlocks: array [0 .. 5, 0 .. 6] of TImage;
  shipX, shipY: integer;
  ep: array [0 .. 10] of TImage;
  epX: array [0 .. 10] of integer;
  epY: array [0 .. 10] of integer;
  lastMove: array [0 .. 10] of integer;
  moveLeft, moveRight, moveLeft1, moveRight1, moveUp, moveDown: Char;
  shotLeft, shotRight, shotUp, shotDown, moveStop: Char;
  lastMoveKey, lastShotKey, currentMoveKey: Char;
  verticalCorridors: array [0 .. 5] of integer;
  horizontalCorridors: array [0 .. 4] of integer;
  endLeft, endRight, endUp, endDown, moveStep: integer;
  appPath: String;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);

var
  row, column, blockNumber, i: integer;
  pic: string;
begin
  appPath := ExtractFileDir(ExtractFilePath(ParamStr(0)));
  pic := appPath + '\images\block\block.gif';
  Ship.Height := shipHeight;
  Ship.Width := shipWidth;
  moveLeft1 := 'j';
  moveRight1 := 'l';
  moveLeft := 'j';
  moveRight := 'l';
  moveUp := 'i';
  moveDown := 'k';
  shotLeft := 'j';
  shotRight := 'l';
  shotUp := 'i';
  shotDown := 'k';
  moveStop := chr(32);

  blockNumber := 0;
  for row := 0 to 5 do
  begin
    for column := 0 to 6 do
    begin
      gridBlocks[row, column] := TImage.Create(self);
      gridBlocks[row, column].Parent := self;
      gridBlocks[row, column].SendToBack;
      gridBlocks[row, column].AutoSize := FALSE;
      gridBlocks[row, column].Height := imgHeight;
      gridBlocks[row, column].Width := imgWidth;
      gridBlocks[row, column].Top := topImageOffset + row *
        (gridBlocks[row, column].Height + verticalBlockStep);
      gridBlocks[row, column].Left := leftImageOffset + column *
        (gridBlocks[row, column].Width + horizontalBlockStep);
      gridBlocks[row, column].Stretch := true;
      gridBlocks[row, column].Proportional := true;
      gridBlocks[row, column].Name := 'block' + inttostr(blockNumber);
      blockNumber := blockNumber + 1;
      gridBlocks[row, column].Picture.LoadFromFile(pic);
      // // imgs[c].OnClick := imgClick;
      gridBlocks[row, column].Picture.LoadFromFile(pic);
      gridBlocks[row, column].Visible := true;
      gridBlocks[row, column].Refresh;
    end;
  end;
  for i := 0 to 5 do
  begin
    verticalCorridors[i] :=
      round(gridBlocks[5, i].Left +
      ((2 * gridBlocks[5, i].Width + verticalBlockStep) / 2) - (shipWidth / 2));
  end;
  for i := 0 to 4 do
  begin
    horizontalCorridors[i] :=
      round(gridBlocks[i, 4].Top +
      ((2 * gridBlocks[i, 4].Width + horizontalBlockStep) / 2) -
      (shipWidth / 2));
  end;
  endLeft := verticalCorridors[0];
  endRight := verticalCorridors[5];
  endUp := horizontalCorridors[0];
  endDown := horizontalCorridors[4];
  moveStep := 5;
  ep[0] := ep1;
  ep[1] := ep2;
  (Ship.Picture.Graphic as TGIFImage).Animate := true;
  (ep[0].Picture.Graphic as TGIFImage).Animate := true;
  (ep[1].Picture.Graphic as TGIFImage).Animate := true;
  shipX := verticalCorridors[3];
  shipY := horizontalCorridors[4];
  Ship.Left := shipX;
  Ship.Top := shipY;
  epX[0] := verticalCorridors[3];
  epY[0] := horizontalCorridors[4];
  epX[1] := verticalCorridors[1];
  epY[1] := horizontalCorridors[4];
  Timer1.Enabled := true;
  // Timer2.Enabled := true;
end;

procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
 Form1.Caption := moveUp + ' ' + moveDown + ' ' + moveLeft + ' ' + moveRight;
  if (Key = moveLeft1) then
  begin
    lastMoveKey := moveLeft1;
  end;
  if (Key = moveRight1) then
  begin
    lastMoveKey := moveRight1;
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
  i: integer;
begin
  randomize;
  ((FindComponent('block' + inttostr(Random(42))) As TImage)
    .Picture.Graphic as TGIFImage).Animate := true;
  Timer1.Tag := 1;
  for i := 0 to 41 do
  begin
    if (((FindComponent('block' + inttostr(i)) As TImage)
      .Picture.Graphic as TGIFImage).Animate = FALSE) then
    begin
      Timer1.Tag := 0;
      break;
    end;
  end;
  if Timer1.Tag = 1 then
    Timer1.Enabled := FALSE;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  if (currentMoveKey = moveLeft1) and (shipX > endLeft) and
    inHorizontalCorridor() then
  begin
    shipX := shipX - moveStep;
  end;
  if (currentMoveKey = moveRight1) and (shipX < endRight) and
    inHorizontalCorridor() then
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
  if ((lastMoveKey = moveLeft1) or (lastMoveKey = moveRight1)) and
    inHorizontalCorridor() then
  begin
    currentMoveKey := lastMoveKey;
  end;
  if ((lastMoveKey = moveUp) or (lastMoveKey = moveDown)) and
    inVerticalCorridor() then
  begin
    currentMoveKey := lastMoveKey;
  end;
  if (lastMoveKey = moveStop) and inHorizontalCorridor() and inVerticalCorridor()
  then
  begin
    currentMoveKey := lastMoveKey;
  end;
  Ship.Left := shipX;
  Ship.Top := shipY;
  // Form1.Caption := inttostr(shipX) + ' / ' + inttostr(shipY);
end;

procedure TForm1.Timer3Timer(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to 1 do
  begin
    if (ep[i].Tag = 1) and (epX[i] > endLeft) and { left }
      enemyInHorizontalCorridor(i) then
    begin
      epX[i] := epX[i] - moveStep;
    end;
    if (ep[i].Tag = 2) and (epX[i] < endRight) and { right }
      enemyInHorizontalCorridor(i) then
    begin
      epX[i] := epX[i] + moveStep;
    end;
    if (ep[i].Tag = 3) and (epY[i] > endUp) and
      enemyInVerticalCorridor(i) { up }
    then
    begin
      epY[i] := epY[i] - moveStep;
    end;
    if (ep[i].Tag = 4) and (epY[i] < endDown) and
      enemyInVerticalCorridor(i) { down }
    then
    begin
      epY[i] := epY[i] + moveStep;
    end;
    if ((lastMove[i] = 1) or (lastMove[i] = 2)) and enemyInHorizontalCorridor(i)
    then
    begin
      ep[i].Tag := lastMove[i];
    end;
    if ((lastMove[i] = 3) or (lastMove[i] = 4)) and enemyInVerticalCorridor(i)
    then
    begin
      ep[i].Tag := lastMove[i];
    end;
    if (lastMove[i] = 5) and enemyInHorizontalCorridor(i) and
      enemyInVerticalCorridor(i) then
    begin
      ep[i].Tag := lastMove[i];
    end;
    ep[i].Left := epX[i];
    ep[i].Top := epY[i];
    // Form1.Caption := inttostr(shipX) + ' / ' + inttostr(shipY);
  end;
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
    else
      inHorizontalCorridor := FALSE;
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
    else
      inVerticalCorridor := FALSE;
  end;

end;

function TForm1.enemyInHorizontalCorridor(enemy: integer): boolean;
var
  i: integer;
begin
  for i := 0 to 4 do
  begin
    if epY[enemy] = horizontalCorridors[i] then
    begin
      enemyInHorizontalCorridor := true;
      break;
    end
    else
      enemyInHorizontalCorridor := FALSE;
  end;
end;

function TForm1.enemyInVerticalCorridor(enemy: integer): boolean;

var
  i: integer;
begin
  for i := 0 to 5 do
  begin
    if epX[enemy] = verticalCorridors[i] then
    begin
      enemyInVerticalCorridor := true;
      break;
    end
    else
      enemyInVerticalCorridor := FALSE;
  end;

end;

procedure TForm1.enemyMoveTimer(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to 11 do
  begin
    randomize;
    lastMove[i] := 1 + Random(4);
  end;
end;

end.
