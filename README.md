# NimTeleBackdoor

a simple backdoor for Windows programmed in Nim that uses Telegram bot as a C2 server

### Prerequisites

* winim https://github.com/khchen/winim 
* telebot https://github.com/ba0f3/telebot.nim

### Cross-Compile on linux

```
sudo apt install gcc-mingw-w64-x86-64 gcc-mingw-w64-i686

nim c --opt:size --app:gui -d:mingw --passL:-Os -d:danger -d:release -d:ssl -d:noOpenSSLHacks --dynlibOverride:ssl- --dynlibOverride:crypto- -d:sslVersion:"(" --passL:-Lsrc\ --passL:-Bstatic --passL:-lssl --passL:-lcrypto --threads:on --passL:-Bdynamic --passL:-s .\src\main.nim
```

### TODO

- [ ] Adding a keylogger
- [ ] Adding encryption
- [ ] Improving shellcode injection