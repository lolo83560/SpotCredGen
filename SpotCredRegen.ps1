# Spotify Credentials regenerator
# LL - 02-oct-2024
#
# Prerequisites:
# - librespot-auth.exe (built from https://github.com/tgmb1/getcredentials.json.git)
# - Spotx app installed and patched (see here https://github.com/SpotX-Official/SpotX)

	#================================================
	#================================================
	# function to exit abruptly after havind
	function Eject([string]$message) {
		# Update local config file .utilpaths w/ info potentially just refreshed
		if ($utilpaths -ne $null) {	# note: does not check if contents is valid
			$utilpaths.GetEnumerator() | ForEach-Object { "{0}={1}" -f $_.Name,$_.Value } | Set-Content ".\.utilpaths" -force
		}
		if ($message -ne $null) {
			"--"
			$message
		}
		Exit-PSSession
	}
	#================================================
	#================================================
	
	#================================================
	# Read local config file .utilpaths if exists
	#
	# .utilpath contents expected like below:
	#
	# SpotAppPath = c:\<the path to Spotify.exe> ...
	# ZotDataPath = c:\<the path to zotify data> ...
	# LibspotAuthPath = c:\<the path to librespot-auth.exe> ...
	#================================================

	# by default create a void hashtable
	
	$utilpaths = @{
		'SpotAppPath' = ''
		'ZotDataPath' = ''
		'LibspotAuthPath' = ''
	}
		
	if ((gci ".\.utilpaths" -ErrorAction SilentlyContinue) -ne $null) {			# if local file .utilpaths exists
		# read its contents shaped into a hash table
		$utilpaths = (get-content ".\.utilpaths") -replace '\\', '\\' | out-string | ConvertFrom-StringData
		$SpotAppPath = $utilpaths.SpotAppPath
		$ZotDataPath = $utilpaths.ZotDataPath
		$LibspotAuthPath = $utilpaths.LibspotAuthPath
	}
	
	#================================================
	# Check existence of Spotify.exe
	# record its path in .\.utilpaths file for the next times
	# or exit if unfound 
	#================================================

	$spotappfound = $false
	if ($SpotAppPath -ne $null) {			# if Spotify app path retreived from config file is not empty, check its validity	
		if ((gci $SpotAppPath -ErrorAction SilentlyContinue) -ne $null) {	# if spot app path in dotfile is valid
			"Using configured Spotify.exe located in : $SpotAppPath"		# then tell so
			$spotappfound = $true
		} else { 							# in other case spot app path (in dotfile) not valid
			$spotappfound = $false
		}
	} else {								# in other case spot app path (in dotfile) was unexisting
		$spotappfound = $false
	}

	if ( $spotappfound -eq $false ) {		# if not found from .utilpaths file then search it in current harddisk
		"Searching Spotify.exe in C:\ ..."
		$SpotSearch = $(gci -path "c:\" -filter "spotify.exe" -recurse -ErrorAction SilentlyContinue -Force)
		if ($SpotSearch -eq $null) {		# no spotify.exe can be found on disk C
			Eject("### FATAL - Spotify.exe not installed - cannot continue :/")
			
		}
		else {								# spotify.exe found in c:\
			if ($SpotSearch.count -gt 1) {	# in case more than one instance found, list all and propose choice
				"--"
				"More than 1 Spotify.exe instance found :"
				$i = 1
				foreach ($f in $SpotSearch) {
						"$i : created $($f.creationtime) in $($f.directoryname)"
						$i++
				}
				do {
					$instance = read-host "Enter the correct one [1..$($SpotSearch.count)]"
				} until ($instance -ge 1 -and $instance -le $SpotSearch.count)
				$SpotAppPath = $SpotSearch[$instance-1].fullname
			} else {
				$SpotAppPath = $SpotSearch.fullname
				"Spotify.exe found: $SpotAppPath"
			}
		}
	}
	$utilpaths.SpotAppPath = $SpotAppPath	# update hastable so eventually .utilpaths file gets updated w/ fresh info
	
	#================================================
	# Check existence of appdata\roaming\zotify
	# exit if unfound 
	#================================================

	if (test-path $ZotDataPath -eq $null) {						# if path given in .utilpath does not exist
		$ZotDataPath = "$($env:APPDATA)\zotify"					# try the default one
		if ((test-path $ZotDataPath) -eq $null) {					# if zotify appdata does not exist, no need to continue
			"--"
			Eject("### FATAL - Zotify is not installed - cannot continue :/")
		}
	}
	$utilpaths.ZotDataPath = $ZotDataPath	# update hastable so eventually .utilpaths file gets updated w/ fresh info
	
	#================================================
	# Check existence of librespot-auth.exe
	# exit if unfound 
	#================================================

	$LSauthappfound = $false
	if ($LibspotAuthPath -ne $null) {							# if librespot-auth path retreived from config file is not empty, check its validity
		if ((gci $LibspotAuthPath -ErrorAction SilentlyContinue) -ne $null) {	# if librespot-auth app path in dotfile is valid
			"Using configured librespot-auth.exe located in : $LibspotAuthPath"		# then tell so
			$LSauthappfound = $true
		} else { 							# in other case librespot-auth app path (in dotfile) not valid
			$LSauthappfound = $false
		}
	} else {								# in other case librespot-auth app path (in dotfile) was unexisting
		$LSauthappfound = $false
	}

	if ( $LSauthappfound -eq $false ) {		# if not found from .utilpaths file then search it in current harddisk
		"Searching librespot-auth.exe in C:\ ..."
		$LSauthSearch = $(gci -path "c:\" -filter "librespot-auth.exe" -recurse -ErrorAction SilentlyContinue -Force)
		if ($LSauthSearch -eq $null) {		# no librespot-auth.exe can be found on disk C
			Eject("### FATAL - librespot-auth.exe not found - cannot continue :/")
			
		}
		else {								# librespot-auth.exe found in c:\
			if ($LSauthSearch.count -gt 1) {	# in case more than one instance found, list all and propose choice
				"--"
				"More than 1 librespot-auth.exe instance found :"
				$i = 1
				foreach ($f in $LSauthSearch) {
						"$i : created $($f.creationtime) in $($f.directoryname)"
						$i++
				}
				do {
					$instance = read-host "Enter the correct one [1..$($LSauthSearch.count)]"
				} until ($instance -ge 1 -and $instance -le $LSauthSearch.count)
				$LibspotAuthPath = $LSauthSearch[$instance-1].fullname
			} else {
				$LibspotAuthPath = $LSauthSearch.fullname
				"librespot-auth.exe found: $LibspotAuthPath"
			}
		}
	}
	$utilpaths.LibspotAuthPath = $LibspotAuthPath	# update hastable so eventually .utilpaths file gets updated w/ fresh info
		
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

