program ListFeatures;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Classes,
  VimbaC,
  VmbCommonTypes;

var
  Status: VmbError_t;
  AlliedCamera: VmbHandle_t;
  total, dummy: VmbUint32_t;
  lista: VmbFeatureInfo_t;
  P: pVmbFeatureInfo_t;
  c, f, d, u, r: PAnsiChar;
  I: integer;
begin
  Status := VmbStartup();
  if Status <> Ord(VmbErrorSuccess) then
    Halt(Status);
  //Ip of camera: 192.168.1.169
  Status := VmbCameraOpen(PChar('192.168.1.169'), Ord(VmbAccessModeConfig),
    @AlliedCamera);

  P := @Lista;
  P := nil;
  total := 0;
  status := VmbFeaturesList(AlliedCamera, p, 0, total, SizeOf(Lista));

  if status = 0 then
  begin
    dummy := 0;
    p := @Lista;
    Getmem(p, (Sizeof(Lista) * Total));
    Status := VmbFeaturesList(AlliedCamera, (p), (SizeOf(Lista) * Total),
      dummy, SizeOf(Lista));

  end;
  for I := 0 to dummy - 1 do
  begin
    c := p[i].Name;
    f := p[i].category;
    d := p[i].displayName;
    u := p[i]._unit;
    r := p[i].tooltip;
    Writeln(c + ',' + f + ' ' + d + ',' + u + ',' + r);
  end;
  status := VmbCameraClose(AlliedCamera);
  VmbShutdown;
  Freemem(P);

end.
