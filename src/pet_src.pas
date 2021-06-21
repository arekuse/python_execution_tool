unit pet_src;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  CheckLst, Grids, ExtCtrls, Buttons, Menus, SynHighlighterPython, SynEdit, DOM,
  XMLRead, XMLWrite, XPath, strutils, Process, Types, base64;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    CheckListBox1: TCheckListBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    PopupMenu1: TPopupMenu;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    StringGrid1: TStringGrid;
    SynEdit1: TSynEdit;
    SynPythonSyn1: TSynPythonSyn;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure CheckListBox1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure CheckListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckListBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure CheckListBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckListBox1SelectionChange(Sender: TObject; User: boolean);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure Memo1Exit(Sender: TObject);
    procedure Memo3Change(Sender: TObject);
    procedure Memo4Change(Sender: TObject);
    procedure MenuItem1Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;
  python_path : string = 'C:\Users\Alexei\AppData\Local\Programs\Python\Python37\python.exe';
  Xml: TXMLDocument;
  HoldIndex : Integer;
implementation

{$R *.lfm}

{ TForm1 }

procedure execute_with_python(filename: string);
var AProcess: TProcess;
begin
  with form1 do
  begin
  memo2.clear;
  memo2.lines.add(python_path + ' "'+filename+'"');
  memo2.lines.SaveToFile('exec.cmd');
  AProcess:=TProcess.Create(nil);
  AProcess.Parameters.Add('exec.cmd');
  AProcess.Parameters.Add('/LOG+:Log.txt');
  AProcess.Executable:='SilentCMD.exe';
  AProcess.Options:=AProcess.Options + [poWaitOnExit];
  try
    AProcess.Execute;
    //Result:=true;
  except
  on E: Exception do
  begin
     showmessage('Execution failed');
  //Result:=false;
  end;
  end;
  AProcess.Free;
  deletefile(filename);
  deletefile('exec.cmd');
  end;
end;

procedure execute_with_cmd(filename: string);
var AProcess: TProcess;
begin
  with form1 do
  begin
  memo2.clear;
  memo2.lines.add('"'+filename+'"');
  memo2.lines.SaveToFile('exec.cmd');
  AProcess:=TProcess.Create(nil);
  AProcess.Parameters.Add('exec.cmd');
  AProcess.Parameters.Add('/LOG+:Log.txt');
  AProcess.Executable:='SilentCMD.exe';
  AProcess.Options:=AProcess.Options + [poWaitOnExit];
  try
    AProcess.Execute;
    //Result:=true;
  except
  on E: Exception do
  begin
     showmessage('Execution failed');
  //Result:=false;
  end;
  end;
  AProcess.Free;
  deletefile(filename);
  deletefile('exec.cmd');
  end;
end;


function get_result: string;
var
  MyFile: TextFile;
  s: string;
begin
  AssignFile(MyFile, 'result');
  try
    reset(MyFile);    //Reopen the file for reading
    readln(MyFile, s);
    if s='0' then
    result := 'ERROR'
    else
    result := 'OK';
  finally
    CloseFile(MyFile)
  end
end;

function get_result_data: string;
var
  MyFile: TextFile;
  s: string;
begin
  AssignFile(MyFile, 'result_data');
  try
    reset(MyFile);    //Reopen the file for reading
    readln(MyFile, s);
    result:=s;
  finally
    CloseFile(MyFile)
  end
end;

procedure TForm1.Button1Click(Sender: TObject);
var uuid: string;
    step_filename: string;
    step_name: string;
    step_desc: string;
    step_group: string;
    i: integer;
    code: string;
begin
  if checklistbox1.SelCount<>0 then
  begin
  for i :=0 to checklistbox1.Items.count-1 do
  begin
if checklistbox1.Selected[i] then
begin
checklistbox1.Checked[i]:=false;
  step_group:=combobox1.text;
  step_name:=checklistbox1.Items[i];
  //button3.Click;
  //LOAD CODE
  if checklistbox1.SelCount>1 then
  begin
  synedit1.clear;
  code:=DecodeStringBase64(String(EvaluateXPathExpression('//group[@name="'+combobox1.text+'"]/step[@name="'+checklistbox1.Items[i]+'"]', Xml.DocumentElement).AsText));
  //code:=String(EvaluateXPathExpression('//group[@name="'+combobox1.text+'"]/step[@name="'+checklistbox1.Items[i]+'"]', Xml.DocumentElement).AsText);
  //code:=stringsreplace(code,['\t','\n'],[#9,#13],[rfReplaceAll]);
  //code:=stringsreplace(code,['\t','\n'],['    ',#13],[rfReplaceAll]);
  synedit1.text:=code;
  end;
  //LOAD INFO
  uuid:=String(EvaluateXPathExpression('//group[@name="'+combobox1.text+'"]/step[@name="'+step_name+'"]/@uuid', Xml.DocumentElement).AsText);
  step_desc:=String(EvaluateXPathExpression('//group[@name="'+combobox1.text+'"]/step[@name="'+step_name+'"]/@desc', Xml.DocumentElement).AsText);

  if combobox2.text='python' then
  begin
  step_filename:=ExtractFilePath(ParamStr(0))+uuid+'.py';
  synedit1.Lines.SaveToFile(step_filename);
  execute_with_python(step_filename);
  end
  else
  begin
  step_filename:=ExtractFilePath(ParamStr(0))+uuid+'.bat';
  synedit1.Lines.SaveToFile(step_filename);
  execute_with_cmd(step_filename);
  end;

  stringgrid1.RowCount:=stringgrid1.RowCount+1;
  stringgrid1.Cells[0,stringgrid1.RowCount-1]:=step_group;
  stringgrid1.Cells[1,stringgrid1.RowCount-1]:=step_name;
  stringgrid1.Cells[2,stringgrid1.RowCount-1]:=step_desc;
  stringgrid1.Cells[5,stringgrid1.RowCount-1]:=FormatDateTime('dd.mm.yyyy, hh:nn:ss', now);
  if fileexists('result') then
  begin
  	stringgrid1.Cells[3,stringgrid1.RowCount-1]:=get_result;
        checklistbox1.Checked[i]:=true;
  	if fileexists('result_data') then
  	stringgrid1.Cells[4,stringgrid1.RowCount-1]:=get_result_data
  	else
        stringgrid1.Cells[3,stringgrid1.RowCount-1]:='--';
  end
  	else
        stringgrid1.Cells[4,stringgrid1.RowCount-1]:='--';
  end;
//CLEANUP
if fileexists('result') then DeleteFile('result');
if fileexists ('result_data') then DeleteFile('result_data');
end;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  stringgrid1.RowCount:=1;
end;

procedure add_xml_group(xml: TXMLDocument; group_name: string);
var Members: TDOMNodeList;
    Member: TDOMNode;
    group_count, i: integer;
    uuid: TGUID;
    ElementNode, RootNode: TDOMNode;
begin
  RootNode:=xml.FindNode('file');
  ElementNode:= xml.CreateElement('group');
  //group_count:= strtoint(String(EvaluateXPathExpression('count(//group)',Xml.DocumentElement).AsText));
  TDOMElement(ElementNode).SetAttribute('name', group_name);
  CreateGUID(uuid);
  TDOMElement(ElementNode).SetAttribute('uuid', GUIDToString(uuid));
  RootNode.AppendChild(ElementNode);
  form1.combobox1.Items.Add(group_name);
  writeXMLFile(xml,'data.xml');
end;

procedure update_steps(xml: TXMLDocument);
var Members: TDOMNodeList;
    Member: TDOMNode;
    Members_Steps: TDOMNodeList;
    Member_Steps: TDOMNode;
    step_count, i, j: integer;
    uuid: TGUID;
    ElementNode, RootNode: TDOMNode;
begin
  Members:= xml.GetElementsByTagName('step');
  for i:= 0 to Members.Count - 1 do
    begin
      Member:= Members[i];
      //showmessage(member.Attributes.GetNamedItem('name').TextContent);
      if form1.CheckListbox1.items.IndexOf(member.Attributes.GetNamedItem('name').TextContent)<>-1 then
      TDOMElement(Member).SetAttribute('id', inttostr(form1.CheckListbox1.items.IndexOf(member.Attributes.GetNamedItem('name').TextContent)+1));
      end;
  writeXMLFile(xml,'data.xml');
end;

procedure add_xml_step(xml: TXMLDocument; step_name: string);
var Members: TDOMNodeList;
    Member: TDOMNode;
    step_count, i: integer;
    uuid: TGUID;
    ElementNode, RootNode: TDOMNode;
begin
  Members:= xml.GetElementsByTagName('group');
  for i:= 0 to Members.Count - 1 do
    begin
      Member:= Members[i];
      if (member.Attributes.GetNamedItem('name').TextContent) = form1.combobox1.Text
      then
      RootNode:=member;
    end;
  ElementNode:= xml.CreateElement('step');
  step_count:= strtoint(String(EvaluateXPathExpression('count(//group[@name="'+form1.combobox1.text+'"]//step)',Xml.DocumentElement).AsText));
  TDOMElement(ElementNode).SetAttribute('name', step_name);
  CreateGUID(uuid);
  TDOMElement(ElementNode).SetAttribute('id', inttostr(step_count+1));
  TDOMElement(ElementNode).SetAttribute('uuid', GUIDToString(uuid));
  TDOMElement(ElementNode).SetAttribute('desc', '');
  TDOMElement(ElementNode).SetAttribute('type', '');
  ElementNode.TextContent:=EncodeStringBase64(' ');
  RootNode.AppendChild(ElementNode);
  form1.checklistbox1.Items.Add(step_name);
  writeXMLFile(xml,'data.xml');
  update_steps(xml);
end;

procedure TForm1.Button3Click(Sender: TObject);
var Members: TDOMNodeList;
    Member: TDOMNode;
    UUID: TDOMNode;
    i: integer;
    Element : TDOMElement;
begin
  Members:= xml.GetElementsByTagName('step');
  for i:= 0 to Members.Count - 1 do
  begin
    Member:= Members[i];
    if (member.Attributes.GetNamedItem('uuid').TextContent) = labelededit2.Text
    then
    begin
    TDOMElement(member).SetAttribute('desc',form1.labelededit3.Text);
    TDOMElement(member).SetAttribute('name',form1.labelededit1.Text);
    TDOMElement(member).SetAttribute('type',form1.combobox2.Text);
    //member.TextContent:=stringsreplace(synedit1.text,[#9,#13,'    '],['\t','\n','\t'],[rfReplaceAll]);
    member.TextContent:=EncodeStringBase64(synedit1.text);
    form1.checklistbox1.Items[checklistbox1.ItemIndex]:=form1.labelededit1.text;
    end;
  end;
  writeXMLFile(xml,'data.xml');
  CheckListBox1SelectionChange(form1, true);
end;

procedure TForm1.Button4Click(Sender: TObject);
var
    user_input: string;
begin
  if InputQuery('Group name', 'Type in group name', false, User_input) then
  if (trim(user_input)<>'') and (combobox1.Items.IndexOf(user_input)<0) then begin
  add_xml_group(xml, user_input);
  combobox1.ItemIndex:=combobox1.Items.Count-1;
  combobox1.OnChange(self);
  end
  else showmessage('Name existing or empty');
end;

procedure TForm1.Button5Click(Sender: TObject);
var Members: TDOMNodeList;
    Member: TDOMNode;
    step_count, i: integer;
    uuid: TGUID;
    ElementNode, RootNode: TDOMNode;
begin
  Members:= xml.GetElementsByTagName('group');
  for i:= 0 to Members.Count - 1 do
    begin
      Member:= Members[i];
      if (member.Attributes.GetNamedItem('name').TextContent) = form1.combobox1.Text
      then
      begin
      //xml.RemoveChild(member);
      member.Free;
      form1.combobox1.Items.Delete(combobox1.ItemIndex);
      form1.combobox1.ItemIndex:=form1.combobox1.Items.Count-1;
      break;
    end;
    end;
  writeXMLFile(xml,'data.xml');
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  user_input: string;
  Members: TDOMNodeList;
      Member: TDOMNode;
      i: integer;
begin
  user_input:=combobox1.text;
  if InputQuery('Group name', 'Type in group name', false, User_input) then
  if (trim(User_input)<>'') and (combobox1.Items.IndexOf(user_input)<0) then
  begin
  Members:= xml.GetElementsByTagName('group');
  for i:= 0 to Members.Count - 1 do
    begin
      Member:= Members[i];
      if (member.Attributes.GetNamedItem('name').TextContent) = form1.combobox1.Text
      then
      TDOMElement(member).SetAttribute('name', user_input);
      combobox1.Items[combobox1.ItemIndex]:=user_input;
    end;
  writeXMLFile(xml,'data.xml');
  end
  else
  else showmessage('Name existing or empty');
end;

procedure TForm1.CheckListBox1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
  popupmenu1.PopUp;
end;

procedure TForm1.CheckListBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TForm1.CheckListBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
end;

procedure TForm1.CheckListBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
end;

procedure TForm1.CheckListBox1SelectionChange(Sender: TObject; User: boolean);
var code: string;
begin
  synedit1.Clear;
  labelededit1.Clear;
  labelededit1.Text:=checklistbox1.Items[checklistbox1.ItemIndex];
  labelededit2.Clear;
  labelededit2.Text:=String(EvaluateXPathExpression('//group[@name="'+combobox1.text+'"]/step[@name="'+labelededit1.Text+'"]/@uuid', Xml.DocumentElement).AsText);
  labelededit3.Clear;
  labelededit3.Text:=String(EvaluateXPathExpression('//group[@name="'+combobox1.text+'"]/step[@name="'+labelededit1.Text+'"]/@desc', Xml.DocumentElement).AsText);
  combobox2.text:='';
  combobox2.text:=String(EvaluateXPathExpression('//group[@name="'+combobox1.text+'"]/step[@name="'+labelededit1.Text+'"]/@type', Xml.DocumentElement).AsText);
  code:=DecodeStringBase64(String(EvaluateXPathExpression('//group[@name="'+combobox1.text+'"]/step[@name="'+checklistbox1.Items[checklistbox1.ItemIndex]+'"]', Xml.DocumentElement).AsText));
  //code:=String(EvaluateXPathExpression('//group[@name="'+combobox1.text+'"]/step[@name="'+checklistbox1.Items[checklistbox1.ItemIndex]+'"]', Xml.DocumentElement).AsText);
  //code:=stringsreplace(code,['\t','\n'],['    ',#13],[rfReplaceAll]);
  button3.Enabled:=true;
  synedit1.text:=code;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
var   step_count: integer;
  i: integer;
begin
  if combobox1.Text<>'' then begin
  checklistbox1.Clear;
  labelededit1.Clear;
  labelededit2.Clear;
  labelededit3.Clear;
  combobox2.text:='';
  synedit1.Clear;
  button3.Enabled:=false;
  step_count:=strtoint((String(EvaluateXPathExpression('count(//group[@name="'+combobox1.text+'"]//step)',Xml.DocumentElement).AsText)));
  for i:=1 to step_count do
//  checklistbox1.Items.Add(String(EvaluateXPathExpression('//group[@name="'+combobox1.text+'"]/step['+inttostr(i)+']/@name', Xml.DocumentElement).AsText));
  checklistbox1.Items.Add(String(EvaluateXPathExpression('//group[@name="'+combobox1.text+'"]/step[@id="'+inttostr(i)+'"]/@name', Xml.DocumentElement).AsText));
  if checklistbox1.Items.Count<>0 then
  begin
  //checklistbox1.Selected[0]:=true;
  end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  group_count: integer;
  i: integer;
begin
  ReadXMLFile(Xml, 'data.xml');
  group_count:=strtoint(String(EvaluateXPathExpression('count(//group)',Xml.DocumentElement).AsText));
  for i:=1 to group_count do
  combobox1.Items.Add(String(EvaluateXPathExpression('//group['+inttostr(i)+']/@name',Xml.DocumentElement).AsText));
  combobox1.ItemIndex:=0;
  combobox1.OnChange(combobox1);
  checklistbox1.ClickOnSelChange:=true;
  memo4.text:=EncodeStringBase64(memo3.text);
end;

procedure TForm1.Memo1Change(Sender: TObject);
begin

end;

procedure TForm1.Memo1Exit(Sender: TObject);
begin

end;

procedure TForm1.Memo3Change(Sender: TObject);
begin
  memo4.Text:=EncodeStringBase64(memo3.text);
end;

procedure TForm1.Memo4Change(Sender: TObject);
begin
  memo3.Text:=DecodeStringBase64(memo4.text);
end;

procedure TForm1.MenuItem1Click(Sender: TObject);
var
  user_input: string;
begin
  if InputQuery('Step name', 'Type in step name', false, User_input) then
  if (trim(user_input)<>'') and (checklistbox1.Items.IndexOf(user_input)<0) then add_xml_step(xml, user_input)
  else showmessage('Name existing or empty');
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
var Members: TDOMNodeList;
    Member: TDOMNode;
    step_count, i: integer;
    uuid: TGUID;
    ElementNode, RootNode: TDOMNode;
begin
  Members:= xml.GetElementsByTagName('step');
  for i:= 0 to Members.Count - 1 do
    begin
      Member:= Members[i];
      if (member.Attributes.GetNamedItem('name').TextContent) = form1.checklistbox1.Items[form1.CheckListBox1.ItemIndex]
      then
      begin
      //xml.RemoveChild(member);
      member.Free;
      form1.checklistbox1.Items.Delete(checklistbox1.ItemIndex);
      form1.checklistbox1.ItemIndex:=form1.checklistbox1.Items.Count-1;
      break;
    end;
    end;
  writeXMLFile(xml,'data.xml');
  update_steps(xml);
end;

procedure TForm1.MenuItem4Click(Sender: TObject);
var
  i: Integer;
begin
  i := CheckListBox1.ItemIndex;
  if i > 0 then begin
    CheckListbox1.ClearSelection;
    CheckListBox1.Items.Exchange(i, i - 1);
    CheckListBox1.Selected[i-1]:= True;
    update_steps(xml);
  end;
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
var
  i, Max: Integer;
begin
  Max := CheckListBox1.Items.Count;
  if Max > 0 then begin
    Dec(Max);
    i := CheckListBox1.ItemIndex;
    if i < Max then begin
      CheckListbox1.ClearSelection;
      CheckListBox1.Items.Exchange(i, i + 1);
      CheckListBox1.Selected[i+1]:= True;
      update_steps(xml);
    end;
  end;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  checklistbox1.CheckAll(cbUnchecked,false,false);
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  checklistbox1.SelectAll;
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
  checklistbox1.ClearSelection;
end;

end.

