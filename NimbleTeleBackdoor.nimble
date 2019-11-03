# Package

version       = "0.1.0"
author        = "Yaz"
description   = "a backdoor in Nim using Telegram bot as a C2 server"
license       = "GPL-3.0"
srcDir        = "src"
bin           = @["NimbleTeleBackdoor"]



# Dependencies

requires "nim >= 1.0.0"
requires "winim >= 3.2.3"
requires "telebot >= 0.6.8"
