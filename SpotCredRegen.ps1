# Spotify Credentials regenerator
# LL - 02-oct-2024
#
# Prerequisites:
# - librespot-auth.exe (built from https://github.com/tgmb1/getcredentials.json.git)
# - Spotx app installed and patched (see here https://github.com/SpotX-Official/SpotX)
#
# check existence of :
#	spotify app in C:
# 	appdata\roaming\zotify
# 	librespot-auth.exe
#	Warn about firewall
#
# Algo :
#
# run spotify app
# run librespot-auth.exe, wait till exit & successful gen' of cred file
# patch credentials.json
# move credentials.json -> zotify appdata/...
