program ListaCamaras;

{$mode objfpc}{$H+}

uses {$IFDEF UNIX} {$IFDEF UseCThreads}
  cthreads, {$ENDIF} {$ENDIF}
  Classes { you can add units after this },
  SysUtils,
  Sockets,
  VimbaC,
  VmbCommonTypes;

var
  isGigE: boolean;
  VimbaError: VmbError_t;
  pCameras: PAnsiString;
  nCount, total: VmbUint32_t;
  Pte: ^PCamera;
  Lista: VmbCameraInfo_t;
  I: integer;
  AlliedCamera: VmbHandle_t;
  valor: VmbInt64_t;
  Ip: string;
  Direccion: in_addr;
begin
  VimbaError := VmbStartup();
  if VimbaError <> Ord(VmbErrorSuccess) then
  begin
    WriteLn('VimbaError iniciando la librería ' + IntToStr(VimbaError));
    Halt(VimbaError);
  end;

  isGigE := False;

  VimbaError := VmbFeatureBoolGet(gVimbaHandle, 'GeVTLIsPresent', @isGigE);
  //Is Vimba connected to a GigE transport layer?
  if VimbaError = Ord(VmbErrorSuccess) then
  begin
    if (isGigE) then
    begin
      VimbaError := VmbFeatureIntSet(gVimbaHandle, 'GeVDiscoveryAllDuration', 250);
      //Default is 150ms
      if VimbaError = Ord(VmbErrorSuccess) then
      begin
        //Discovery is switched on only once so that the API can detect all
        //currently connected cameras. Wait 250 ms for an answer
        VimbaError := VmbFeatureCommandRun(gVimbaHandle, 'GeVDiscoveryAllOnce');
        if VimbaError <> Ord(VmbErrorSuccess) then
        begin
          WriteLn(format('Could not ping GigE cameras over the network. Reason: %d',
            [VimbaError]));
          VmbShutdown;
          Halt(VimbaError);
        end;
      end
      else
      begin
        WriteLn(format('Could not set the discovery waiting duration. Reason: %d',
          [VimbaError]));
        VmbShutdown;
        Halt(VimbaError);
      end;
    end;
  end
  else
  begin
    WriteLn(Format('DiscoverGigECameras failed with reason: %d ==> %s',
      [VimbaError, VmbErrorStr[(VimbaError)]]));
    VmbShutdown;
    Halt(VimbaError);
  end;



  //Localizar cámaras

  VimbaError := VmbCamerasList(nil, 0, nCount, sizeof(pCameras));

  if VimbaError <> Ord(VmbErrorSuccess) then
  begin
    WriteLn('Error localizando cámaras ' + IntToStr(VimbaError));
    VmbShutdown;
    Halt(VimbaError);
  end;

  if nCount < 1 then
  begin
    WriteLn('No se encuentra ningun cámara ' + IntToStr(VimbaError));
    VmbShutdown;
    Halt(VimbaError);
  end;

  Pte := @Lista;
  Getmem(Pte, nCount * SizeOf((VmbCameraInfo_t)));
  VimbaError := VmbCamerasList(Pte, nCount, total, SizeOf(Lista));

  for I := 0 to Total - 1 do
  begin
    WriteLn(Format('Camara id: %s ', [pte[I].cameraIdString]));
    Writeln(Format('Camara nombre: %s ', [pte[i].cameraName]));
    WriteLn(Format('Modelo: %s ', [Pte[i].modelName]));
    WriteLn(Format('Número serie: %s ', [Pte[I].serialString]));
    WriteLn(Format('Tipo de acceso %d ', [pte[i].permittedAccess]));
    Writeln(Format('Interface: %s ', [pte[i].interfaceIdString]));
    VimbaError := VmbCameraOpen(pte[i].cameraIdString, Ord(VmbAccessModeRead),
      @AlliedCamera);
    if VimbaError = Ord(VmbErrorSuccess) then
    begin

      VimbaError := VmbFeatureIntGet(AlliedCamera, PChar('GevCurrentIPAddress'), valor);
      if VimbaError = Ord(VmbErrorSuccess) then
      begin
        Direccion.s_addr := valor;
        Ip := NetAddrToStr(Direccion);
        Writeln(Format('Direccion Ip: %s ', [ip]));
      end;

      VimbaError := VmbFeatureIntGet(AlliedCamera, PChar('GevCurrentSubnetMask'), valor);
      if VimbaError = Ord(VmbErrorSuccess) then
      begin
        Direccion.s_addr := valor;
        Ip := NetAddrToStr(Direccion);
        Writeln(Format('Mascara de red: %s ', [ip]));
      end;

      VimbaError := VmbFeatureIntGet(AlliedCamera,
        PChar('GevCurrentDefaultGateway'), Valor);
      if VimbaError = Ord(VmbErrorSuccess) then
      begin
        Direccion.s_addr := valor;
        Ip := NetAddrToStr(Direccion);
        Writeln(Format('Puerta  de enlace: %s ', [ip]));
      end;

      VimbaError := VmbFeatureIntGet(AlliedCamera, PChar('GevDeviceMACAddress'), Valor);
      if VimbaError = Ord(VmbErrorSuccess) then
      begin
        Direccion.s_addr := valor;
        ip := IntToHex((Valor),2);
        if Length(Ip) div 2 <> 0 then
        begin
          Ip := '0'+Ip;
        end;
        Writeln(Format('Mascara de red %s ', [ip]));
      end;
      VmbCameraClose(AlliedCamera);
    end;
  end;
  VmbShutdown;
end.
