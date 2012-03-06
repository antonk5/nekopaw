unit GridFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  DBClient, cxGridLevel, cxClasses, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, graberU, dxmdaset,
  cxEditRepositoryItems, common, ComCtrls, cxContainer, cxLabel, dxStatusBar,
  dxBar, cxGridCustomPopupMenu, cxGridPopupMenu, cxExtEditRepositoryItems,
  Delphi.Extensions.VirtualDataset;

type

  TfGrid = class(TFrame)
    GridLevel1: TcxGridLevel;
    Grid: TcxGrid;
    GridLevel2: TcxGridLevel;
    vChilds: TcxGridDBTableView;
    cxEditRepository1: TcxEditRepository;
    iTextEdit: TcxEditRepositoryTextItem;
    vGrid1: TcxGridDBTableView;
    sBar: TdxStatusBar;
    BarManager: TdxBarManager;
    BarControl: TdxBarDockControl;
    TableActions: TdxBar;
    bbColumns: TdxBarButton;
    GridPopup: TcxGridPopupMenu;
    bbFilter: TdxBarButton;
    iPicChecker: TcxEditRepositoryCheckBoxItem;
    iCheckBox: TcxEditRepositoryCheckBoxItem;
    iPBar: TcxEditRepositoryProgressBar;
    vGrid: TcxGridTableView;
    procedure bbColumnsClick(Sender: TObject);
    procedure bbFilterClick(Sender: TObject);
    procedure vGrid1FocusedRecordChanged(Sender: TcxCustomGridTableView;
      APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
      ANewItemRecordFocusingChanged: Boolean);
    procedure vdGetRecordCount(Sender: TCustomVirtualDataset;
      var Count: Integer);
    procedure vdGetFieldValue(Sender: TCustomVirtualDataset; Field: TField;
      Index: Integer; var Value: Variant);
    procedure vdBeforeOpen(DataSet: TDataSet);
    procedure vGridEditValueChanged(Sender: TcxCustomGridTableView;
      AItem: TcxCustomGridTableItem);
  private
    //FList: TList;
//    FFieldList: TStringList;
    FPicChanged: TPictureNotifyEvent;
    FCheckColumn: tcxGridColumn;
    FIdColumn: tcxGridColumn;
    FParentColumn: tcxGridColumn;
    FLabelColumn: tcxGridColumn;
    FProgressColumn: tcxGridColumn;
    FSizeColumn: tcxGridColumn;
    FPosColumn: tcxGridColumn;
    FResColumn: tcxGridColumn;
    FFieldList: TStringList;
    //FStartSender: TObject;
//    FN: Integer;
    //FFirstC: TcxDBGridColumn;
    { Private declarations }
  public
    ResList: TResourceList;
    procedure Reset;
    procedure CreateList;
    procedure OnPicAdd(APicture: TTPicture);
//    procedure CheckField(ch,s: string; value: variant);
    procedure OnStartJob(Sender: TObject; Action: Integer);
//    procedure OnEndJob(Sender: TObject);
    function AddField(s: string; base: boolean = false): TcxGridColumn;
    procedure OnBeginPicList(Sender: TObject);
    procedure OnEndPicList(Sender: TObject);
    procedure Relise;
    procedure SetLang;
    procedure OnListPicChanged(Pic: TTPicture; Changes: TPicChanges);
    procedure SetColWidths;
    procedure updatefocusedrecord;
    property OnPicChanged: TPictureNotifyEvent read FPicChanged write FPicChanged;
    { Public declarations }
  end;

  TcxGridSiteAccess = class(TcxGridSite);
  TcxGridPopupMenuAccess = class(TcxGridPopupMenu);
implementation

uses LangString, utils;

{$R *.dfm}

function TfGrid.AddField(s: string; base: boolean = false): TcxGridColumn;
var
  //f: TField;
  n: string;

begin
{  ;

  if s <> '' then
    case s[1] of
      'i' : f := TIntegerField.Create(vd);
      'l' : f := TLargeIntField.Create(vd);
      'd' : f := TDateTimeField.Create(vd);
      'b' : f := TBooleanField.Create(vd);
      'f','p' : f := TFloatField.Create(vd);
    else
    begin
      f := TStringField.Create(vd);
      f.Size := 256;
    end end
  else
  begin
    f := TStringField.Create(vd);
    f.Size := 256;
  end;
  //f := TStringField.Create(md);
//  f.FieldNo := vd.FieldCount;
  f.FieldName := chu + n;
  f.DisplayLabel := n;

  f.FieldKind := fkData;
  f.DataSet := vd;       }
  n := GetNextS(s,':');

  result := vGrid.CreateColumn;
  result.Caption := n;

  if s <> '' then
    case s[1] of
      'i' : result.DataBinding.ValueType := 'Integer';
      'l' : result.DataBinding.ValueType := 'LargeInt';
      'd' : result.DataBinding.ValueType := 'DateTime';
      'b' : result.DataBinding.ValueType := 'Boolean';
      'f' : result.DataBinding.ValueType := 'Float';
      'p' : result.DataBinding.ValueType := 'Float';
    else
      result.DataBinding.ValueType := 'String';
    end
  else
    result.DataBinding.ValueType := 'String';

  if SameText(s,'b') then
    if base then
      result.RepositoryItem := iPicChecker
    else
      result.RepositoryItem := iCheckBox
  else if SameText(s,'p') then
    result.RepositoryItem := iPBar
  else
    result.RepositoryItem := iTextEdit;
  //result.DataBinding.ValueType := 'String';
end;

procedure TfGrid.bbColumnsClick(Sender: TObject);
begin
  TcxGridPopupMenuAccess(GridPopup).GridOperationHelper.DoShowColumnCustomizing(True);
end;

procedure TfGrid.bbFilterClick(Sender: TObject);
begin
  if bbFilter.Down then
    vGrid.FilterBox.Visible := fvAlways
  else
    vGrid.FilterBox.Visible := fvNonEmpty;
end;

procedure TfGrid.CreateList;
begin
{  if not Assigned(FFieldList) then
    FFieldList := TStringList.Create;      }
  if not Assigned(ResList) then
  begin
    ResList := TResourceList.Create;
    //PDS.Open;
    ResList.PictureList.OnPicChanged := OnListPicChanged;
    ResList.OnJobChanged := OnStartJob;
    ResList.PictureList.OnEndAddList := OnEndPicList;
    FPicChanged := nil;
  end else
    ResList.Clear;
end;

procedure TfGrid.OnBeginPicList(Sender: TObject);
begin

end;

procedure TfGrid.OnEndPicList(Sender: TObject);
var
{  i,j: integer;
  APicture: TTPicture;
  //r,c: integer;
  t: integer;
  n: variant; }
  //FList: TPictureLinkList;
  c,i,j: integer;
  t1,t3: integer;
  n: TListValue;
  clm: TcxGridColumn;
begin
//  if vd.Active then
//  begin
    t1 := GetTickCount;
    //ResList.OnError(Self,''
    vGrid.BeginUpdate;
    try
{    vd.DisableControls;
    c := vd.RecNo;
    vd.RecNo := vGrid.DataController.RecordCount;
    vd.Resync([]);
    vd.RecNo := c;
    vd.EnableControls;
    vGrid.EndUpdate; }

      //FList := Sender as TPictureLinkList;

      c := vgrid.DataController.RecordCount;

       vgrid.DataController.RecordCount := ResList.PictureList.Count;

      with vGrid.DataController,ResList do
        for i := c to RecordCount -1 do
        begin
          Values[i,FCheckColumn.Index] := PictureList[i].Checked;
          Values[i,FIDColumn.Index] := Integer(PictureList[i]);
          Values[i,FParentColumn.Index] := Integer(PictureList[i].Parent);
          Values[i,FResColumn.Index] := PictureList[i].Resource.Name;
          Values[i,FLabelColumn.Index] := PictureList[i].DisplayLabel;
          for j := 0 to PictureList[i].Meta.Count -1 do
          begin
            n := PictureList[i].Meta.Items[j];
            clm := FFieldList.Objects[FFieldList.IndexOf(n.Name)] as tcxGridColumn;
            case clm.DataBinding.ValueType[1] of
              'S': Values[i,clm.Index] := VarToStr(n.Value);
              'B': Values[i,clm.Index] := n.Value;
              'I','L': Values[i,clm.Index] := n.Value;
              'F': Values[i,clm.Index] := n.Value;
              'D': Values[i,clm.Index] := VarToDateTime(n.Value);
            end;
            {Values[i,( as TcxGridColumn).Index]
              := PictureList[i].Meta.Items[j].Value;}
          end;
        end;
    finally
      vGrid.EndUpdate;
      if c = 0 then
        BestFitWidths(vGrid);
    end;

    t3 := GetTickCount;
    sBar.Panels[1].Text := 'TTL ' + IntToStr(vGrid.DataController.RecordCount)
      + ' TBL ' + IntToStr(t3 - t1) + 'ms'
      + ' DBL '  + IntToStr(ResList.PictureList.DoublestickCount) + 'ms';


//  end;
{  FList := Sender as TPictureLinkList;

  vGrid.BeginUpdate;
  n := vd.CurRec;
  t := vgrid.Controller.FocusedRecordIndex - vgrid.Controller.TopRecordIndex;
  md.DisableControls;
  for j := 0 to FList.Count -1 do
  begin
    APicture := FList[j];
    md.Insert;
    try
      //r := vGrid.DataController.InsertRecord(r);
      md.FieldValues['checked'] := APicture.Checked;
      md.FieldValues['resname'] := APicture.Resource.Name;
      md.FieldValues['label'] := APicture.DisplayLabel;
      md.FieldValues['id'] := Integer(APicture.Orig);
      md.FieldValues['parent'] := Integer(Apicture.Orig.Parent);
      for i := 0 to APicture.Meta.Count-1 do
      begin
          md.FieldValues['.' + APicture.Meta.Items[i].Name] := APicture.Meta.Items[i].Value;
      end;
      md.Post;
      APicture.Orig.BookMark := md.RecNo;
    except
      md.Cancel;
    end;
  end;
  md.EnableControls;
  if n > -1 then
    BestFitWidths(vGrid);
  vGrid.EndUpdate;

  if n < 0 then
  begin
    BestFitWidths(vGrid);
    n := 0;
  end;

    vgrid.DataController.FocusedRecordIndex := n;
    vgrid.Controller.TopRecordIndex := vgrid.Controller.FocusedRecordIndex - t;}
  //BestFitWidths(vGrid);
end;

procedure TfGrid.OnPicAdd(APicture: TTPicture);
begin
  //FList.Add(APicture);
end;

procedure TfGrid.OnListPicChanged(Pic: TTPicture; Changes: TPicChanges);
var
  n{,c}: integer;

begin
{  n := ResList.PictureList.IndexOf(Pic);
  vd.RecNo := n + 1;
  vd.Refresh;    }
{  VGrid.BeginUpdate;

  n := ResList.PictureList.IndexOf(Pic);
  if n > -1 then
  begin
    c := vd.RecNo;
    vd.RecNo := n;
    vd.Refresh;
    vd.RecNo := c;
  end;

  vGrid.EndUpdate;   }

{  if vd.Active then
    vd.Resync([]); }

  //(pcProgress,pcSize,pcLabel,pcDeleted,pcChecked)
  //md.CurRec := md. ( 'id',Integer(Pic),[]);
  //md.CurRec := md.GetRecNoByFieldValue(Integer(Pic),'id');



{  if pcDelete in Changes then
  begin
    md.Delete;
    Exit;
  end;   }

{  n := vGrid.DataController.FindRecordIndexByText(0,FIdColumn.Index,
        IntToStr(Integer(pic)),false,false,true); }
{  if Pic.BookMark = 0 then
    Exit;

  vGrid.BeginUpdate;

  n := md.RecNo;

  md.RecNo := Pic.BookMark;

  md.Edit;

  //md.GetCurrentRecord;   }

    n := Pic.BookMark - 1;

    with vGrid.DataController do
    begin
      if pcSize in Changes then
        if Pic.Size = 0 then
          Values[n,FSizeColumn.Index] := ''
        else
          Values[n,FSizeColumn.Index] := GetBTString(Pic.Size);

      if pcProgress in Changes then
      begin
        if Pic.Pos = 0 then
          Values[n,FPosColumn.Index] := ''
        else
          Values[n,FPosColumn.Index] := GetBTString(Pic.Pos);
        if Pic.Size = 0 then
          if Pic.Checked then
            Values[n,FProgressColumn.Index] := 0
          else
            Values[n,FProgressColumn.Index] := 100
        else
          Values[n,FProgressColumn.Index] := Pic.Pos/Pic.Size * 100;
      end;

    if pcLabel in Changes then
      Values[n,FLabelColumn.Index] := Pic.DisplayLabel;

    if pcChecked in Changes then
      Values[n,FCheckColumn.Index] := Pic.Checked;
    end;
{    if md.State in [dsEdit] then
      md.Post;    }


    //VGrid.ViewData.se

    //vGrid.DataController.PostEditingData;
{    md.Post;

    md.RecNo := n;

    vGrid.EndUpdate;

    Pic.Changes := [];

  finally
//    md.Post;
  end;          }
end;

procedure TfGrid.OnStartJob(Sender: TObject; Action: integer);
begin
  PostMessage(Application.MainForm.Handle,CM_STARTJOB,Integer(Self.Parent),0);
  case Action of
    JOB_LIST:
      sBar.Panels[0].Text := _ON_AIR_;
    JOB_PICS:
    begin
//      vGrid.BeginUpdate;
      FCheckColumn.Options.Editing := false;
//      iPicChecker.Properties.ReadOnly := true;
      SetColWidths;
      FSizeColumn.Visible := true;
      FPosColumn.Visible := true;
      FProgressColumn.Visible := true;
//      vGrid.EndUpdate;
      sBar.Panels[0].Text := _ON_AIR_;
    end;
    JOB_STOPLIST:
      if ResList.PicsFinished then
        sBar.Panels[0].Text := '';
    JOB_STOPPICS:
    begin
      FSizeColumn.Visible := false;
      FPosColumn.Visible := false;
      FProgressColumn.Visible := false;
      FCheckColumn.Options.Editing := true;
      if ResList.ListFinished then
        sBar.Panels[0].Text := '';
    end;
  end;
end;

procedure TfGrid.Relise;
begin
  //vd.Close;
  Screen.Cursor := crHourGlass;
  try
    if Assigned(ResList) then
      FreeAndNil(ResList);
    if Assigned(FFieldList) then
      FreeAndNil(FFieldList);
  finally
    Screen.Cursor := crDefault;
  end;
  //FList.Free;
  //FFieldList.Free;
{  vGrid.BeginUpdate;
  vGrid.DataController.RecordCount := 0;
  vGrid.ClearItems;
  vGrid.EndUpdate; }
  //vGrid.Free;
end;

procedure TfGrid.Reset;
var
  i: integer;
  c: tcxGridColumn;
  p: TMetaList;
//  b: boolean;
begin
  Grid.BeginUpdate;
  vGrid.ClearItems;
  vChilds.ClearItems;

{  if vd.Active then
  begin
    vd.Close;
    b := true;
  end else
    b := false;

  vd.Fields.Clear;}

  ResList.CreatePicFields;
//  md.DisableControls;
//  FFieldList := ResList.FullPicFieldList;
  //FFieldList.Insert(0,'resname');
  //c := vGrid.CreateColumn;
  //c.Visible := false;

  FCHeckColumn := AddField('checked:b',true);
  FCHeckColumn.Caption := '';
  //c.Visible := false;
  with FCHeckColumn.Options do
  begin
    HorzSizing := false;
    Filtering := false;
    Grouping := false;
    Moving := false;
    Sorting := false;
  end;
  FCHeckColumn.Width := 20;
  FCHeckColumn.VisibleForCustomization := false;

  FIdColumn := AddField('id:i');
  FIdColumn.Visible := false;
  FIdColumn.VisibleForCustomization := false;

  FParentColumn := AddField('parent:i');
  FParentColumn.Visible := false;
  FParentColumn.VisibleForCustomization := false;
{  c.SortOrder := soAscending;
  c.Width := 20;    }

{   vgrid.DataController.KeyFieldNames := 'RecId';

  c := vGrid.CreateColumn;
  c.DataBinding.FieldName := 'RecId';
  c.DataBinding.Field.DisplayLabel := _RESID_;   }

  FResColumn := AddField(_RESNAME_);
  //c.Caption := ;
  FResColumn.GroupBy(0);

  FLabelColumn := AddField( _PICTURELABEL_);
  //FLabelColumn.Caption :=;

  FPosColumn := AddField(_DOWNLOADED_);
  with FPosColumn.Options do
  begin
    HorzSizing := false;
    Filtering := false;
    Grouping := false;
    Moving := false;
    Sorting := false;
  end;
  FPosColumn.Visible := false;
  FPosColumn.VisibleForCustomization := false;

  FSizeColumn := AddField(_SIZE_);
  with FSizeColumn.Options do
  begin
    HorzSizing := false;
    Filtering := false;
    Grouping := false;
    Moving := false;
    Sorting := false;
  end;
  FSizeColumn.Visible := false;
  FSizeColumn.VisibleForCustomization := false;

  FProgressColumn := AddField(_PROGRESS_ + ':p');
  with FProgressColumn.Options do
  begin
    HorzSizing := false;
    Filtering := false;
    Grouping := false;
    Moving := false;
    Sorting := false;
  end;
  FProgressColumn.Visible := false;
  FProgressColumn.VisibleForCustomization := false;

  if not Assigned(FFieldList) then
    FFieldList := TStringList.Create
  else
    FFieldList.Clear;

  for i := 0 to ResList.PictureList.Meta.Count -1 do
  begin
    FFieldList.Insert(i,ResList.PictureList.Meta.Items[i].Name);
    p := ResList.PictureList.Meta.Items[i].Value;
    case p.ValueType of
      DB.ftString: c := AddField(ResList.PictureList.Meta.Items[i].Name);
      ftBoolean: c := AddField(ResList.PictureList.Meta.Items[i].Name + ':b');
      ftInteger: c := AddField(ResList.PictureList.Meta.Items[i].Name + ':i');
      ftFloat: c := AddField(ResList.PictureList.Meta.Items[i].Name + ':f');
      ftDateTime: c := AddField(ResList.PictureList.Meta.Items[i].Name + ':d');
      else c := AddField(ResList.PictureList.Meta.Items[i].Name);
    end;
    //c := AddField(FFieldList[i],'.');
    FFieldList.Objects[i] := c;
    c.Visible := false;
    //FFieldList.Objects[i] := c;
  end;
  //l.Free;

  FPosColumn.Index := vGrid.ItemCount;
  FSizeColumn.Index := vGrid.ItemCount;
  fProgressColumn.Index := vGrid.ItemCount;

{  if b then
    vd.Open;  }
{  md.EnableControls;  }
  Grid.EndUpdate;
end;

procedure TfGrid.SetColWidths;
begin
  FSizeColumn.Width := 60;
  FPosColumn.Width := 60;
  FProgressColumn.Width := 60;
end;

procedure TfGrid.SetLang;
begin
  bbColumns.Caption := _COLUMNS_;
  bbFilter.Caption := _FILTER_;
  //bbDoubles.Caption := _DOUBLES_;
end;

procedure TfGrid.updatefocusedrecord;
var
  n: variant;
  p: TcxCustomGridRow;
begin
  if Assigned(FPicChanged){ and vd.Active} then
  begin
    p := vGrid.Controller.FocusedRow;

    if Assigned(p) and p.IsData then
      n := p.Values[FIdColumn.Index]
    else
      n := null;
    if n <> null then
      FPicChanged(Self,TTPicture(Integer(n)));
  end;
end;

procedure TfGrid.vdBeforeOpen(DataSet: TDataSet);
begin
  vGrid.BeginUpdate;
  vGrid.EndUpdate;
end;

procedure TfGrid.vdGetFieldValue(Sender: TCustomVirtualDataset; Field: TField;
  Index: Integer; var Value: Variant);
var
  p: TTPicture;
begin
  p := ResList.PictureList[Index];
  case Field.FieldNo of
    1: Value := p.Checked;
    2: Value := Integer(p);
    3: Value := Integer(p.Parent);
    4: Value := Copy(p.Resource.Name,1,Field.Size);
    5: Value := Copy(p.DisplayLabel,1,Field.Size);
    6:
      if p.Size = 0 then
        Value := ''
      else
        Value := GetBtString(p.Pos);
    7:
      if p.Size = 0 then
        Value := ''
      else
        Value := GetBtString(p.Size);
    8:
      if p.Size = 0 then
        if p.Checked then
          Value := 0
        else
          Value := 100
      else
        Value := p.Pos / p.Size * 100;
    else
      case Field.DataType of
        DB.ftString: Value := Copy(VarToStr(p.Meta[Field.DisplayName]),1,Field.Size);
        ftBoolean: Value := p.Meta[Field.DisplayName];
        ftInteger: Value := p.Meta[Field.DisplayName];
        ftFloat: Value := p.Meta[Field.DisplayName];
        ftDateTime: Value := VarToDateTime(p.Meta[Field.DisplayName]);
      end;
  end;
end;

procedure TfGrid.vdGetRecordCount(Sender: TCustomVirtualDataset;
  var Count: Integer);
begin
  Count := ResList.PictureList.Count;
end;

procedure TfGrid.vGrid1FocusedRecordChanged(Sender: TcxCustomGridTableView;
  APrevFocusedRecord, AFocusedRecord: TcxCustomGridRecord;
  ANewItemRecordFocusingChanged: Boolean);

begin
  updatefocusedrecord;
end;

procedure TfGrid.vGridEditValueChanged(Sender: TcxCustomGridTableView;
  AItem: TcxCustomGridTableItem);
var
  n: integer;
begin
  if AItem.Index <> FCheckColumn.Index then
    Exit;
  n := vGrid.DataController.FocusedRecordIndex;
  if n > -1 then
  begin
    ResList.PictureList[n].Checked := vGrid.DataController.Values[n,AItem.Index];
  end;
end;

end.