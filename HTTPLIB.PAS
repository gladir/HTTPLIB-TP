{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2023
  @website(https://www.gladir.com/CODER/HTTPLIB-TP)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2)
}

Unit HTTPLIB;

INTERFACE

Const
  { Protocole reconnu }
 Protocole_HTTP1_0='HTTP/1.0';
 Protocole_HTTP1_1='HTTP/1.1';

  { Port commun }
 portHTTP=80;
 portHTTPS=443;
 portIBMHTTPSererAdmin=8008;
 portAlternativeHTTP=8080;
 portAtlassianConfluence=8090;

  { Code d'‚tat HTTP }
 SWITCHING_PROTOCOLS=101;
 OK=200;
 CREATED=201;
 ACCEPTED=202;
 NONAUTHORITATIVE_INFORMATION=203;
 NO_CONTENT=204;
 RESET_CONTENT=205;
 PARTIAL_CONTENT=206;
 MULTIPLE_CHOICES=300;
 MOVED_PERMANENTLY=301;
 MOVED_TEMPORARILY=302;
 SEE_OTHER=303;
 NOT_MODIFIED=304;
 USE_PROXY=305;
 BAD_REQUEST=400;
 UNAUTHORIZED=401;
 PAYMENT_REQUIRED=402;
 FORBIDDEN=403;
 NOT_FOUND=404;
 METHOD_NOT_ALLOWED=405;
 NOT_ACCEPTABLE=406;
 PROXY_AUTHENTICATION_REQUIRED=407;
 REQUEST_TIMEOUT=408;
 CONFLICT=408;
 GONE=410;
 LENGTH_REQUIRED=411;
 PRECONDITION_FAILED=412;
 REQUEST_ENTITY_TOO_LARGE=413;
 REQUESTURI_TOO_LARGE=414;
 UNSUPPORTED_MEDIA_TYPE=415;
 REQUESTED_RANGE_NOT_SATISFIABLE=416;
 EXPECTATION_FAILED=417;
 IM_A_TEAPOT=418;
 INTERNAL_SERVER_ERROR=500;
 NOT_IMPLEMENTED=501;
 BAD_GATEWAY=502;
 SERVICE_UNAVAILABLE=503;
 GATEWAY_TIMEOUT=504;
 HTTP_VERSION_NOT_SUPPORTED=505;

Procedure Header(S:String);
Procedure HTTP_Connect(Domain:String;Port:Word;Protocole:String);
Function  HTTP_GetUserAgent:String;
Procedure HTTP_HeadersForHTML;
Procedure HTTP_HeadersForJSON;
Procedure HTTP_Redirection(URL:String);
Function  HTTP_Response_Code(code:Integer):Integer;
Procedure HTTP_SendGETRequestMethod(S:String);
Procedure HTTP_SendPOSTRequestMethod(S,ParamList,RefererURL:String;ContentLength:LongInt);
Procedure HTTP_SendPOSTRequestMethodByBuffer(S,ParamList,RefererURL:String;ContentLength:Word;Var Buffer);
Function  HTTP_SendPOSTRequestMethodByFile(S,ParamList,RefererURL:String;FileName:String):Boolean;
Procedure HTTP_SetUserAgent(S:String);
Procedure JavaScript_Redirection(URL:String);

IMPLEMENTATION

Uses DOS;

Var
 UserAgent,CurrHost:String;
 AcceptLanguage:String[20];

Function IntToStr(Value:Integer):String;
Var
 S:String;
Begin
 Str(Value,S);
 IntToStr:=S;
End;

Function PadZeroLeft(Value:Integer;Space:Byte):String;
Var
 S:String;
Begin
 Str(Value,S);
 While Length(S)<Space do S:='0'+S;
 PadZeroLeft:=S;
End;


Function GetStringTime(Year,Month,Day,DOW,Hour,Min,Sec:Word):String;
Const
 DayOfWeekList:Array[0..6]of String[3]=('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
 MonthList:Array[1..12]of String[12]=('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
Begin
 GetStringTime:=DayOfWeekList[DOW]+', '+IntToStr(Day)+' '+MonthList[Month]+' '+IntToStr(Year)+' '+
                PadZeroLeft(Hour,2)+':'+PadZeroLeft(Min,2)+':'+PadZeroLeft(Sec,2)+' GMT';
End;

Procedure Header(S:String);Begin
 WriteLn(S);
End;

Procedure HTTP_SetUserAgent(S:String);Begin
 UserAgent:=S;
End;

Function HTTP_GetUserAgent:String;Begin
 HTTP_GetUserAgent:=UserAgent;
End;

Procedure HTTP_Connect(Domain:String;Port:Word;Protocole:String);Begin
 WriteLn('CONNECT ',Domain,':',Port,Protocole);
End;

Procedure HTTP_Redirection(URL:String);Begin
 Header('Location: '+URL);
End;

Procedure JavaScript_Redirection(URL:String);Begin
 WriteLn('<script type="text/javascript">');
 WriteLn('window.location.href="',URL,'";');
 WriteLn('</script>');
 WriteLn('<noscript>');
 WriteLn('<meta http-equiv="refresh" content="0;url=',URL,'" />');
 WriteLn('</noscript>');
End;

Function HTTP_Response_Code(code:Integer):Integer;
Var
 TextMsg:String;
Begin
 HTTP_Response_Code:=-1;
 Case(Code)of
  100:TextMsg:='Continue';
  101:TextMsg:='Switching Protocols';
  200:TextMsg:='OK';
  201:TextMsg:='Created';
  202:TextMsg:='Accepted';
  203:TextMsg:='Non-Authoritative Information';
  204:TextMsg:='No Content';
  205:TextMsg:='Reset Content';
  206:TextMsg:='Partial Content';
  300:TextMsg:='Multiple Choices';
  301:TextMsg:='Moved Permanently';
  302:TextMsg:='Moved Temporarily';
  303:TextMsg:='See Other';
  304:TextMsg:='Not Modified';
  305:TextMsg:='Use Proxy';
  400:TextMsg:='Bad Request';
  401:TextMsg:='Unauthorized';
  402:TextMsg:='Payment Required';
  403:TextMsg:='Forbidden';
  404:TextMsg:='Not Found';
  405:TextMsg:='Method Not Allowed';
  406:TextMsg:='Not Acceptable';
  407:TextMsg:='Proxy Authentication Required';
  408:TextMsg:='Request Time-out';
  409:TextMsg:='Conflict';
  410:TextMsg:='Gone';
  411:TextMsg:='Length Required';
  412:TextMsg:='Precondition Failed';
  413:TextMsg:='Request Entity Too Large';
  414:TextMsg:='Request-URI Too Large';
  415:TextMsg:='Unsupported Media Type';
  500:TextMsg:='Internal Server Error';
  501:TextMsg:='Not Implemented';
  502:TextMsg:='Bad Gateway';
  503:TextMsg:='Service Unavailable';
  504:TextMsg:='Gateway Time-out';
  505:TextMsg:='HTTP Version not supported';
  Else Exit;
 End;
 WriteLn('HTTP/1.0',' ',Code,' ',TextMsg);
 HTTP_Response_Code:=Code;
End;

Procedure HTTP_SendGETRequestMethod(S:String);Begin
 WriteLn('GET ',S,' HTTP/1.1');
End;

Procedure HTTP_SendPOSTRequestMethod(S,ParamList,RefererURL:String;ContentLength:LongInt);Begin
 WriteLn('POST ',S,' HTTP/1.1');
 WriteLn('Host: ',CurrHost);
 WriteLn('User-Agent: ',UserAgent);
 WriteLn('Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8');
 WriteLn('Accept-Language: ',AcceptLanguage);
 { WriteLn('Accept-Encoding: gzip,deflate'); }
 WriteLn('Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7');
 WriteLn('Keep-Alive: 300');
 WriteLn('Connection: keep-alive');
 If(RefererURL<>'')Then WriteLn('Referer: ',RefererURL);
 WriteLn('Content-Type: application/x-www-form-urlencoded');
 WriteLn('Content-Length: ',ContentLength);
 WriteLn;
 WriteLn(ParamList);
End;

Procedure HTTP_SendPOSTRequestMethodByBuffer(S,ParamList,RefererURL:String;ContentLength:Word;Var Buffer);
Type
 BufferByte=Array[0..16383]of Byte;
Var
 BBuffer:BufferByte Absolute Buffer;
 I:Word;
Begin
 HTTP_SendPOSTRequestMethod(S,ParamList,RefererURL,ContentLength);
 For I:=0 to ContentLength-1 do Begin
  Write(Char(BBuffer[I]));
 End;
End;

Function HTTP_SendPOSTRequestMethodByFile(S,ParamList,RefererURL:String;FileName:String):Boolean;
Var
 F:File;
 ContentLength:LongInt;
 C:Byte;
 ByteReaded:Word;
Begin
 HTTP_SendPOSTRequestMethodByFile:=False;
 {$I-}Assign(F,FileName);
 Reset(F,1);{$I+}
 If IOResult<>0 Then Exit;
 ContentLength:=FileSize(F);
 HTTP_SendPOSTRequestMethod(S,ParamList,RefererURL,ContentLength);
 While Not EOF(F)do Begin
  BlockRead(F,C,1,ByteReaded);
  Write(Chr(C));
 End;
 Close(F);
 HTTP_SendPOSTRequestMethodByFile:=True;
End;

Procedure HTTP_HeadersForJSON;Begin
 WriteLn('HTTP/1.1 200 OK');
 WriteLn('Content-Type: application/json;charset=UTF-8');
 WriteLn('Cache-Control: no-store');
 WriteLn('Pragma: no-cache');
 WriteLn;
End;

Procedure HTTP_HeadersForHTML;
Var
 Year,Month,Day,DOW,Hour,Min,Sec,Sec100:Word;
Begin
 GetDate(Year,Month,Day,DOW);
 GetTime(Hour,Min,Sec,Sec100);
 WriteLn('HTTP/1.x 200 OK');
 WriteLn('Date: ',GetStringTime(Year,Month,Day,DOW,Hour,Min,Sec));
 WriteLn('Connection: close');
 WriteLn('Pragma: public');
 WriteLn('Expires: ',GetStringTime(Year+1,Month,Day,DOW,Hour,Min,Sec));
 WriteLn('Cache-Control: max-age=3600, public');
 WriteLn('Content-Type: text/html; charset=UTF-8');
 WriteLn('Last-Modified: ',GetStringTime(Year,Month,Day,DOW,Hour,Min,Sec));
 WriteLn('Vary: Accept-Encoding, Cookie, User-Agent');
 WriteLn;
End;

BEGIN
 UserAgent:='Non-Mozilla/5.0 (Turbo Pascal)';
 CurrHost:='localhost';
 AcceptLanguage:='fr-ca,fr;q=0.5';
END.