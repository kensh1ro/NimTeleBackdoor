# NimTeleBackdoor

a simple backdoor for Windows programmed in Nim that uses Telegram bot as a C2 server

### Prerequisites

* winim https://github.com/khchen/winim 
* telebot https://github.com/ba0f3/telebot.nim

### Cross-Compile on linux

```
sudo apt install gcc-mingw-w64-x86-64 gcc-mingw-w64-i686

nim c -d:mingw -d:release --app:gui --opt:size main.nim # 64-bit

nim c -d:mingw -d:release --cpu:i386 --app:gui --opt:size main.nim # 32-bit

```

### TODO

- [ ] Adding a keylogger
- [ ] Adding encryption
- [ ] Improving shellcode injection
- [ ] Linking openssl statically
- [ ] TLS Callback anti-debugging