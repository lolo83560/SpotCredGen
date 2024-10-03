# Spotify Credentials regenerator
# LL - 02-oct-2024
#
# Prerequisites:
# - librespot-auth.exe (built from https://github.com/tgmb1/getcredentials.json.git)
# - Spotx app installed and patched (see here https://github.com/SpotX-Official/SpotX)
#
# check existence of :
#	spotify app in C:

	# 1st test existence of local file .SpotAppPath containing application path
	
	#================================================
	# Check existence of Spotify.exe, exit if unfound 
	#================================================
	$spotappfound = $false
	
	if ((gci ".\.spotpath" -ErrorAction SilentlyContinue) -ne $null) {	# if local file .spotpath exists
		$SpotAppPath = get-content ".\.spotpath"
		if ($SpotAppPath -ne $null) {			# if not empty path			
			if ((gci $SpotAppPath -ErrorAction SilentlyContinue) -ne $null) {	# if spot app path in dotfile is valid
				"Valid Spotify.exe found -> $SpotAppPath"
				$spotappfound = $true
			} else { 
				$spotappfound = $false
			}
		} else {
			$spotappfound = $false
		}
	}
	if ( $spotappfound -eq $false ) {
		"No valid local config file found"
		"Searching Spotify.exe in C:\ ..."
		$SpotSearch = $(gci -path "c:\" -filter "spotify.exe" -recurse -ErrorAction SilentlyContinue -Force)
		if ($SpotSearch -eq $null) {	# then spotify.exe not found on disk C
			"Spotify.exe not installed - cannot continue :/"
			Exit-PSSession
		}
		else {	# spotify.exe found in c:\
			$SpotAppPath = $SpotSearch[0]
			if ($SpotSearch.count -gt 1) {	# more than one instance found, list all but pick 1st one
				"Several Spotify.exe instances found (choosing the 1st one) :"
				$i = 0
				foreach ($f in $SpotSearch.count) {
						"$i : $f"
						$i++
				}
			} else {
				"Spotify.exe found: $SpotAppPath"
			}
		}
	}
	# regenerate local .spotpath file
	$SpotAppPath | out-file ".\.spotpath" -Force

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
