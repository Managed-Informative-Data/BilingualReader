[Setup]
AppName=Bilingual Reader
AppVersion=1.0
DefaultDirName={autopf}\Bilingual Reader
DefaultGroupName=Bilingual Reader
; This creates the uninstaller automatically
UninstallDisplayIcon={app}\bilingual_reader.exe
OutputBaseFilename=BilingualReader_Setup
OutputDir=.\installer_output
Compression=lzma2
SolidCompression=yes

[Files]
; NOTE: Check that this path matches your actual build output path
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Bilingual Reader"; Filename: "{app}\bilingual_reader.exe"
Name: "{commondesktop}\Bilingual Reader"; Filename: "{app}\bilingual_reader.exe"

[Code]
// This section handles the custom cleanup of AppData
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  AppDataPath: String;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    // Ask the user if they want to delete their saved data (Dictionaries, Stories)
    if MsgBox('Do you want to delete all your saved dictionaries and stories?', mbConfirmation, MB_YESNO) = IDYES then
    begin
      // Get the path to %APPDATA%\ManagedInformativeData\Bilingual Reader
      // NOTE: Make sure this matches your Organization Name + Project Name
      AppDataPath := ExpandConstant('{userappdata}\ManagedInformativeData\Bilingual Reader');
      
      if DirExists(AppDataPath) then
      begin
        DelTree(AppDataPath, True, True, True);
      end;
    end;
  end;
end;