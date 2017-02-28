object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Google Athentificator'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 8
    Width = 31
    Height = 13
    Caption = 'Secret'
  end
  object SecretEdit: TEdit
    Left = 24
    Top = 27
    Width = 121
    Height = 21
    TabOrder = 0
    Text = '3333444455556666'
  end
  object Button1: TButton
    Left = 176
    Top = 25
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 24
    Top = 64
    Width = 409
    Height = 185
    TabOrder = 2
  end
end
