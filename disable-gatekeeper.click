; First open spotlight to launch terminal
:cmd space
"Terminal"
+1s
"\n"

; Run the sudo command to disable gatekeeper globally
"sudo spctl --global-disable\n"
"open 'x-apple.systempreferences:com.apple.preference.security?Security'\n"

; Click on Allow applications downloaded from Anywhere
("App Store & Known Developers")
+2s
("Anywhere")
+1s
(+0,+0)

if "Modify Settings"
	"admin\n"
end

if "Unlock"
	; type password
	"admin\n"
	+1s
	("Unlock")
end

("Cancel")0 (+0,-40)