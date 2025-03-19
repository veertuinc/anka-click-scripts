; First open spotlight to launch terminal
:cmd space
"Terminal"
"\n"
+2s

; Run the sudo command to disable gatekeeper globally
"sudo spctl --global-disable\n"
"open 'x-apple.systempreferences:com.apple.preference.security?Security'\n"
+2s

; Click on Allow applications downloaded from Anywhere
("App Store & Known Developers")
+1s
("Anywhere")
+2s

; type password
"admin\n"
("Modify Settings")
+1s
("Cancel")0 (+0,-40)