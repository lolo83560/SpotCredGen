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
				"Using configured Spotify.exe located in : $SpotAppPath"
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
			if ($SpotSearch.count -gt 1) {	# more than one instance found, list all but pick 1st one
				"--"
				"More than 1 Spotify.exe instance found :"
				$i = 1
				foreach ($f in $SpotSearch) {
						"$i : created $($f.creationtime) in $($f.directoryname)"
						$i++
				}
				do {
					$instance = read-host "Select the correct one [1..$($SpotSearch.count)]"
				} until ($instance -ge 1 -and $instance -le $SpotSearch.count)
				$SpotAppPath = $SpotSearch[$instance-1].fullname
			} else {
				$SpotAppPath = $SpotSearch.fullname
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
