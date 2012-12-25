{-------------------------------------------------------------------------------
The contents of this file are subject to the Mozilla Public License
Version 1.1 (the "License"); you may not use this file except in compliance
with the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
the specific language governing rights and limitations under the License.

Code template generated with SynGen.
The original code is: S:\Разработки\Delphi_Develop\Магистратура\Разработка проблемно-ориентированных транслирующих средств\Работа Цыпленкова С\Arc\SynHighlighterSample.pas, released 2012-12-23.
Description: Syntax Parser/Highlighter
The initial author of this file is Drewn.
Copyright (c) 2012, all rights reserved.

Contributors to the SynEdit and mwEdit projects are listed in the
Contributors.txt file.

Alternatively, the contents of this file may be used under the terms of the
GNU General Public License Version 2 or later (the "GPL"), in which case
the provisions of the GPL are applicable instead of those above.
If you wish to allow use of your version of this file only under the terms
of the GPL and not to allow others to use your version of this file
under the MPL, indicate your decision by deleting the provisions above and
replace them with the notice and other provisions required by the GPL.
If you do not delete the provisions above, a recipient may use your version
of this file under either the MPL or the GPL.

$Id: $

You may retrieve the latest version of this file at the SynEdit home page,
located at http://SynEdit.SourceForge.net

-------------------------------------------------------------------------------}

{$IFNDEF QSYNHIGHLIGHTERSAMPLE}
unit SynHighlighterSample;
{$ENDIF}

{$I SynEdit.inc}

interface

uses
{$IFDEF SYN_CLX}
  QGraphics,
  QSynEditTypes,
  QSynEditHighlighter,
  QSynUnicode,
{$ELSE}
  Graphics,
  SynEditTypes,
  SynEditHighlighter,
  SynUnicode,
{$ENDIF}
  SysUtils,
  Classes;

type
  TtkTokenKind = (
    tkComment,
    tkIdentifier,
    tkKey,
    tkNull,
    tkNumber,
    tkSpace,
    tkString,
    tkSymbolRaz,
    tkSymbolSk,
    tkSymbolZn,
    tkUnknown);

  TRangeState = (rsUnKnown, rsBraceComment, rsString);

  TProcTableProc = procedure of object;

  PIdentFuncTableFunc = ^TIdentFuncTableFunc;
  TIdentFuncTableFunc = function (Index: Integer): TtkTokenKind of object;

type
  TSynSampleSyn = class(TSynCustomHighlighter)
  private
    fRange: TRangeState;
    fTokenID: TtkTokenKind;
    fIdentFuncTable: array[0..6] of TIdentFuncTableFunc;
    fCommentAttri: TSynHighlighterAttributes;
    fIdentifierAttri: TSynHighlighterAttributes;
    fKeyAttri: TSynHighlighterAttributes;
    fNumberAttri: TSynHighlighterAttributes;
    fSpaceAttri: TSynHighlighterAttributes;
    fStringAttri: TSynHighlighterAttributes;
    fSymbolRazAttri: TSynHighlighterAttributes;
    fSymbolSkAttri: TSynHighlighterAttributes;
    fSymbolZnAttri: TSynHighlighterAttributes;
    function HashKey(Str: PWideChar): Cardinal;
    function FuncCauchy(Index: Integer): TtkTokenKind;
    function FuncEnd(Index: Integer): TtkTokenKind;
    function FuncGet(Index: Integer): TtkTokenKind;
    function FuncGiven(Index: Integer): TtkTokenKind;
    function FuncKoef(Index: Integer): TtkTokenKind;
    function FuncMethod(Index: Integer): TtkTokenKind;
    function FuncProgram(Index: Integer): TtkTokenKind;
    procedure IdentProc;
    procedure NumberProc;
    procedure SymbolRazProc;
    procedure SymbolSkProc;
    procedure SymbolZnProc;
    procedure UnknownProc;
    function AltFunc(Index: Integer): TtkTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PWideChar): TtkTokenKind;
    procedure NullProc;
    procedure SpaceProc;
    procedure CRProc;
    procedure LFProc;
    procedure BraceCommentOpenProc;
    procedure BraceCommentProc;
    procedure StringOpenProc;
    procedure StringProc;
  protected
    function GetSampleSource: UnicodeString; override;
    function IsFilterStored: Boolean; override;
  public
    constructor Create(AOwner: TComponent); override;
    class function GetFriendlyLanguageName: UnicodeString; override;
    class function GetLanguageName: string; override;
    function GetRange: Pointer; override;
    procedure ResetRange; override;
    procedure SetRange(Value: Pointer); override;
    function GetDefaultAttribute(Index: Integer): TSynHighlighterAttributes; override;
    function GetEol: Boolean; override;
    function GetKeyWords(TokenKind: Integer): UnicodeString; override;
    function GetTokenID: TtkTokenKind;
    function GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetTokenKind: Integer; override;
    function IsIdentChar(AChar: WideChar): Boolean; override;
    procedure Next; override;
  published
    property CommentAttri: TSynHighlighterAttributes read fCommentAttri write fCommentAttri;
    property IdentifierAttri: TSynHighlighterAttributes read fIdentifierAttri write fIdentifierAttri;
    property KeyAttri: TSynHighlighterAttributes read fKeyAttri write fKeyAttri;
    property NumberAttri: TSynHighlighterAttributes read fNumberAttri write fNumberAttri;
    property SpaceAttri: TSynHighlighterAttributes read fSpaceAttri write fSpaceAttri;
    property StringAttri: TSynHighlighterAttributes read fStringAttri write fStringAttri;
    property SymbolRazAttri: TSynHighlighterAttributes read fSymbolRazAttri write fSymbolRazAttri;
    property SymbolSkAttri: TSynHighlighterAttributes read fSymbolSkAttri write fSymbolSkAttri;
    property SymbolZnAttri: TSynHighlighterAttributes read fSymbolZnAttri write fSymbolZnAttri;
  end;

implementation

uses
{$IFDEF SYN_CLX}
  QSynEditStrConst;
{$ELSE}
  SynEditStrConst;
{$ENDIF}

resourcestring
  SYNS_Filter = 'All files (*.*)|*.*';
  SYNS_Lang = '';
  SYNS_FriendlyLang = '';
  SYNS_AttrSymbolRaz = 'SymbolRaz';
  SYNS_FriendlyAttrSymbolRaz = 'SymbolRaz';
  SYNS_AttrSymbolSk = 'SymbolSk';
  SYNS_FriendlyAttrSymbolSk = 'SymbolSk';
  SYNS_AttrSymbolZn = 'SymbolZn';
  SYNS_FriendlyAttrSymbolZn = 'SymbolZn';

var
  Identifiers: array[#0..#255] of ByteBool;
  mHashTable : array[#0..#255] of Integer;

const
  // as this language is case-insensitive keywords *must* be in lowercase
  KeyWords: array[0..6] of UnicodeString = (
    'cauchy', 'end', 'get', 'given', 'koef', 'method', 'program' 
  );

  KeyIndices: array[0..6] of Integer = (
    1, 3, 6, 0, 5, 4, 2 
  );

procedure TSynSampleSyn.InitIdent;
var
  i: Integer;
begin
  for i := Low(fIdentFuncTable) to High(fIdentFuncTable) do
    if KeyIndices[i] = -1 then
      fIdentFuncTable[i] := AltFunc;

  fIdentFuncTable[3] := FuncCauchy;
  fIdentFuncTable[0] := FuncEnd;
  fIdentFuncTable[6] := FuncGet;
  fIdentFuncTable[1] := FuncGiven;
  fIdentFuncTable[5] := FuncKoef;
  fIdentFuncTable[4] := FuncMethod;
  fIdentFuncTable[2] := FuncProgram;
end;

{$Q-}
function TSynSampleSyn.HashKey(Str: PWideChar): Cardinal;
begin
  Result := 0;
  while IsIdentChar(Str^) do
  begin
    Result := Result * 216 + Ord(Str^);
    inc(Str);
  end;
  Result := Result mod 7;
  fStringLen := Str - fToIdent;
end;
{$Q+}

function TSynSampleSyn.FuncCauchy(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynSampleSyn.FuncEnd(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynSampleSyn.FuncGet(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynSampleSyn.FuncGiven(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynSampleSyn.FuncKoef(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynSampleSyn.FuncMethod(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynSampleSyn.FuncProgram(Index: Integer): TtkTokenKind;
begin
  if IsCurrentToken(KeyWords[Index]) then
    Result := tkKey
  else
    Result := tkIdentifier;
end;

function TSynSampleSyn.AltFunc(Index: Integer): TtkTokenKind;
begin
  Result := tkIdentifier;
end;

function TSynSampleSyn.IdentKind(MayBe: PWideChar): TtkTokenKind;
var
  Key: Cardinal;
begin
  fToIdent := MayBe;
  Key := HashKey(MayBe);
  if Key <= High(fIdentFuncTable) then
    Result := fIdentFuncTable[Key](KeyIndices[Key])
  else
    Result := tkIdentifier;
end;

procedure TSynSampleSyn.SpaceProc;
begin
  inc(Run);
  fTokenID := tkSpace;
  while (FLine[Run] <= #32) and not IsLineEnd(Run) do inc(Run);
end;

procedure TSynSampleSyn.NullProc;
begin
  fTokenID := tkNull;
  inc(Run);
end;

procedure TSynSampleSyn.CRProc;
begin
  fTokenID := tkSpace;
  inc(Run);
  if fLine[Run] = #10 then
    inc(Run);
end;

procedure TSynSampleSyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TSynSampleSyn.BraceCommentOpenProc;
begin
  Inc(Run);
  fRange := rsBraceComment;
  fTokenID := tkComment;
end;

procedure TSynSampleSyn.BraceCommentProc;
begin
  case fLine[Run] of
     #0: NullProc;
    #10: LFProc;
    #13: CRProc;
  else
    begin
      fTokenID := tkComment;
      repeat
        if (fLine[Run] = '}') then
        begin
          Inc(Run, 1);
          fRange := rsUnKnown;
          Break;
        end;
        if not IsLineEnd(Run) then
          Inc(Run);
      until IsLineEnd(Run);
    end;
  end;
end;

procedure TSynSampleSyn.StringOpenProc;
begin
  Inc(Run);
  fRange := rsString;
  StringProc;
  fTokenID := tkString;
end;

procedure TSynSampleSyn.StringProc;
begin
  fTokenID := tkString;
  repeat
    if (fLine[Run] = '''') then
    begin
      Inc(Run, 1);
      fRange := rsUnKnown;
      Break;
    end;
    if not IsLineEnd(Run) then
      Inc(Run);
  until IsLineEnd(Run);
end;

constructor TSynSampleSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fCaseSensitive := False;

  fCommentAttri := TSynHighLighterAttributes.Create(SYNS_AttrComment, SYNS_FriendlyAttrComment);
  fCommentAttri.Style := [fsItalic];
  fCommentAttri.Foreground := clNavy;
  AddAttribute(fCommentAttri);

  fIdentifierAttri := TSynHighLighterAttributes.Create(SYNS_AttrIdentifier, SYNS_FriendlyAttrIdentifier);
  fIdentifierAttri.Style := [];
  fIdentifierAttri.Foreground := clBlack;
  AddAttribute(fIdentifierAttri);

  fKeyAttri := TSynHighLighterAttributes.Create(SYNS_AttrReservedWord, SYNS_FriendlyAttrReservedWord);
  fKeyAttri.Style := [fsBold];
  fKeyAttri.Foreground := clBlack;
  AddAttribute(fKeyAttri);

  fNumberAttri := TSynHighLighterAttributes.Create(SYNS_AttrNumber, SYNS_FriendlyAttrNumber);
  fNumberAttri.Foreground := clBlue;
  AddAttribute(fNumberAttri);

  fSpaceAttri := TSynHighLighterAttributes.Create(SYNS_AttrSpace, SYNS_FriendlyAttrSpace);
  fSpaceAttri.Foreground := clCream;
  AddAttribute(fSpaceAttri);

  fStringAttri := TSynHighLighterAttributes.Create(SYNS_AttrString, SYNS_FriendlyAttrString);
  fStringAttri.Foreground := clFuchsia;
  AddAttribute(fStringAttri);

  fSymbolRazAttri := TSynHighLighterAttributes.Create(SYNS_AttrSymbolRaz, SYNS_FriendlyAttrSymbolRaz);
  fSymbolRazAttri.Style := [fsBold];
  fSymbolRazAttri.Foreground := clMaroon;
  AddAttribute(fSymbolRazAttri);

  fSymbolSkAttri := TSynHighLighterAttributes.Create(SYNS_AttrSymbolSk, SYNS_FriendlyAttrSymbolSk);
  fSymbolSkAttri.Style := [fsBold];
  fSymbolSkAttri.Foreground := clGreen;
  AddAttribute(fSymbolSkAttri);

  fSymbolZnAttri := TSynHighLighterAttributes.Create(SYNS_AttrSymbolZn, SYNS_FriendlyAttrSymbolZn);
  fSymbolZnAttri.Foreground := clRed;
  AddAttribute(fSymbolZnAttri);

  SetAttributesOnChange(DefHighlightChange);
  InitIdent;
  fDefaultFilter := SYNS_Filter;
  fRange := rsUnknown;
end;

procedure TSynSampleSyn.IdentProc;
begin
  fTokenID := IdentKind((fLine + Run));
  inc(Run, fStringLen);
  while Identifiers[fLine[Run]] do
    Inc(Run);
end;

procedure TSynSampleSyn.NumberProc;
begin
  inc(Run);
  fTokenID := tkNumber;
  while Identifiers[fLine[Run]] do

    inc(Run);

end;

procedure TSynSampleSyn.SymbolRazProc;
begin
  fTokenID  := tkSymbolRaz;
  Inc( Run );
end;

procedure TSynSampleSyn.SymbolSkProc;
begin
  fTokenID  := tkSymbolSk;
  Inc( Run );
end;

procedure TSynSampleSyn.SymbolZnProc;
begin
  fTokenID  := tkSymbolZn;
  Inc( Run );
end;

procedure TSynSampleSyn.UnknownProc;
begin
  inc(Run);
  fTokenID := tkUnknown;
end;

procedure TSynSampleSyn.Next;
begin
  fTokenPos := Run;
  case fRange of
    rsBraceComment: BraceCommentProc;
  else
    case fLine[Run] of
      #0: NullProc;
      #10: LFProc;
      #13: CRProc;
      '{': BraceCommentOpenProc;
      '''': StringOpenProc;
      #1..#9, #11, #12, #14..#32: SpaceProc;
      'A'..'Z','a'..'z': IdentProc;
      '0'..'9': NumberProc;
      '>',';',',',':','.': SymbolRazProc;
      '(',')','[',']': SymbolSkProc;
      '-', '+', '*','^','/','=': SymbolZnProc;
    else
      UnknownProc;
    end;
  end;
  inherited;
end;

function TSynSampleSyn.GetDefaultAttribute(Index: Integer): TSynHighLighterAttributes;
begin
  case Index of
    SYN_ATTR_COMMENT: Result := fCommentAttri;
    SYN_ATTR_IDENTIFIER: Result := fIdentifierAttri;
    SYN_ATTR_KEYWORD: Result := fKeyAttri;
    SYN_ATTR_STRING: Result := fStringAttri;
    SYN_ATTR_WHITESPACE: Result := fSpaceAttri;
  else
    Result := nil;
  end;
end;

function TSynSampleSyn.GetEol: Boolean;
begin
  Result := Run = fLineLen + 1;
end;

function TSynSampleSyn.GetKeyWords(TokenKind: Integer): UnicodeString;
begin
  Result := 
    'cauchy,end,get,given,koef,method,program';
end;

function TSynSampleSyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

function TSynSampleSyn.GetTokenAttribute: TSynHighLighterAttributes;
begin
  case GetTokenID of
    tkComment: Result := fCommentAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkKey: Result := fKeyAttri;
    tkNumber: Result := fNumberAttri;
    tkSpace: Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkSymbolRaz: Result := fSymbolRazAttri;
    tkSymbolSk: Result := fSymbolSkAttri;
    tkSymbolZn: Result := fSymbolZnAttri;
    tkUnknown: Result := fIdentifierAttri;
  else
    Result := nil;
  end;
end;

function TSynSampleSyn.GetTokenKind: Integer;
begin
  Result := Ord(fTokenId);
end;

function TSynSampleSyn.IsIdentChar(AChar: WideChar): Boolean;
begin
  case AChar of
    '_', '0'..'9', 'a'..'z', 'A'..'Z':
      Result := True;
    else
      Result := False;
  end;
end;

function TSynSampleSyn.GetSampleSource: UnicodeString;
begin
  Result := 
    '{ Sample source for the demo highlighter }'#13#10 +
    #13#10 +
    'This highlighter will recognize the words Hello and'#13#10 +
    'World as keywords. It will also highlight "Strings".'#13#10 +
    #13#10 +
    'And a special keyword type: SynEdit'#13#10 +
    '/* This style of comments is also highlighted */';
end;

function TSynSampleSyn.IsFilterStored: Boolean;
begin
  Result := fDefaultFilter <> SYNS_Filter;
end;

class function TSynSampleSyn.GetFriendlyLanguageName: UnicodeString;
begin
  Result := SYNS_FriendlyLang;
end;

class function TSynSampleSyn.GetLanguageName: string;
begin
  Result := SYNS_Lang;
end;

procedure TSynSampleSyn.ResetRange;
begin
  fRange := rsUnknown;
end;

procedure TSynSampleSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

function TSynSampleSyn.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

initialization
{$IFNDEF SYN_CPPB_1}
  RegisterPlaceableHighlighter(TSynSampleSyn);
{$ENDIF}
end.
