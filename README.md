# anka-MUAF-scripts

This repo is a collection of Behavior-Driven MacOS UI Automation Framework scripts and tools for Anka's "click" feature. With MUAF scripts, you can programmatically target, click, and even send keystrokes to the VM's macOS UI and apps. Often, macOS and applications do not have a CLI allowing you to perform certain actions. Some examples of what you can automate:

- Disabling SIP from Apple Silicon VMs (which requires Recovery Mode).
- Enabling VNC/Remote Management under System Preferences.
- Disabling certain settings for

# Scripting Basics

## Variables

Assign a `string`, `integer`, or `png image (as base64)` to a variable at the top of your muas script with `$<label>`. These are then made available throught the script logic.

```
$macos_maj_ver 12
$prefix "muas-"
$next_image iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAUGVYSWZNTQAqAAAACAACARIAAwAAAAEAAQAAh2kABAAAAAEAAAAmAAAAAAADoAEAAwAAAAEAAQAAoAIABAAAAAEAAAAgoAMABAAAAAEAAAAgAAAAAL5bTO0AAAIFaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA2LjAuMCI+CiAgIDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIgogICAgICAgICAgICB4bWxuczpleGlmPSJodHRwOi8vbnMuYWRvYmUuY29tL2V4aWYvMS4wLyI+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWERpbWVuc2lvbj4xMDI0PC9leGlmOlBpeGVsWERpbWVuc2lvbj4KICAgICAgICAgPGV4aWY6UGl4ZWxZRGltZW5zaW9uPjc2ODwvZXhpZjpQaXhlbFlEaW1lbnNpb24+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgp/iD9uAAAByElEQVRYCe2WyYrCQBRFb+zGAQcEBQdcqIhbwYX/oAtRv6j/SAV/wJ2foTgPCIIiDtDdt8BGYxljUiANqU1SyXvvntx6VUQrFovfeONwvVFbSDsAjgP/3wGXy4VyuYxSqWRpQ31ayrpK8nq9yOfz0DQNPp8P3W736u3z249EIvH1POxxxOl0wna7RTabxW8teDweDAaDxwm6N7YBWG+5XGK32yGTyQgIutLv93VS8qkSAJZeLBbY7/dIp9MvQSgDIMR8Psdms/lbDvbEMyeUAhBitVphNpshl8shmUyKxjSCUA5ACLowHA4FRCqVMoSQbsNqtSroWczK4M44HA44Ho9gQxYKBdEfvV7vrpwUIBqNisS7aJMPKBoMBm+iQ6HQzfwy0WQ/JG63G4FA4BLz8pUO8ISsVCqIxWKYTCZotVrCEX0xqQO0br1e62NNz/m19Xod4XDYUJwFpQCmlSSBkUgEjUYDfr9fiDebTdCRR0MpAI/iWq0mjuPxeCxsNxInlDKAeDwubGf/jEYjtNttwy+/OKLkf4CNRttfFSeEbQCKWhUngJIl4K6ZTqfodDo4n8+sa3pIzwHT2QoCbS+BXQYHwHHg7Q78AOAlpzTuTXd0AAAAAElFTkSuQmCC
```


TODO:

- Support || for separating alternative images in () instead of having them have the same name


### Clicking and Targeting

`(location/target)[mouse button]`

Available buttons:

- `0`: do nothing, just use the location specified as a starting target for subsequent directives
- `1`: (default) left click with tiny interval between down and up

() - click (pointer event), could be absolute: (123, 456), pattern based (images) - will wait and position on its center, or relative according to previous click - (+1, -0)
You can disable clicking of items and just use it as the starting point for subsequent directives: `(vnc)0` `(location)[button]`

+ - wait rule, could wait for image or, +2s, +5000n, 300 (msec by default)

"keystroke" rule, supports \n - return button, \t - tab button

:key code - the explicitly specified key codes pressed simultaneously, e.g. :cmd q - quit from a foreground app

The ptr events could be organized into "behavioural sequences": (img1) (img2) (img3)... (imgN), this is complex logic, it includes waits, retries, skips of already passed phases etc
New

This behavioural logic extends also on next wait rule also:
(img1) (img2)... (imgN)
+wait_img
to achieve to the wait_img "state" same retry and skip logic is applied

There are also:
if (awaiting_image) [, (cansel_image)] {rule}

if (awaiting_image) [, (cansel_image)]
    rule
    rule
else
    rule
    rule
    rule
end

Also:
while (image) {rule}



Variable operations:
if (image) $var = 100

if $var > 99 exit

The "power" is behavioural sequences...



## Examples

### Disable SIP (through Recovery Mode)

```bash
# Create a VM without SIP disabled already
❯ ANKA_CREATE_SIP=0 anka --debug create -m 6G -c 4 -d 128G -a /Users/m1mini/Downloads/UniversalMac_13.0_22A379_Restore.ipsw 13.0
# Start it in Recovery Mode (2)
❯ ANKA_START_MODE=2 anka start 13.0
# Run disable-sip script against VM booted in Recovery Mode
❯ anka --debug view --click arm64/12.6/disable-sip/disable-sip.muas test
Fri Oct 21 15:12:49 main: executing command view
Fri Oct 21 15:12:49 click: loading resource data 2144 bytes
Fri Oct 21 15:12:49 click: utilities_image: shelved image 53x22 bytes
Fri Oct 21 15:12:49 click: loading resource data 2248 bytes
Fri Oct 21 15:12:49 click: terminal_image: shelved image 70x24 bytes
Fri Oct 21 15:12:49 click: loading resource data 21596 bytes
Fri Oct 21 15:12:49 click: options_image: shelved image 96x96 bytes
Fri Oct 21 15:12:49 click: loading resource data 1592 bytes
Fri Oct 21 15:12:49 click: next_image: shelved image 32x32 bytes
Fri Oct 21 15:12:49 click: loading resource data 2408 bytes
Fri Oct 21 15:12:49 click: english_image: shelved image 76x22 bytes
Fri Oct 21 15:12:49 click: loading resource data 2244 bytes
Fri Oct 21 15:12:49 click: english_image: shelved image 80x21 bytes
Fri Oct 21 15:12:49 click: loading resource data 2868 bytes
Fri Oct 21 15:12:49 click: continue_image: shelved image 100x28 bytes
Fri Oct 21 15:12:49 click: loading resource data 1916 bytes
Fri Oct 21 15:12:49 click: bash_image: shelved image 66x21 bytes
Fri Oct 21 15:12:49 click: waiting for options_image, 1 templates for match...
Fri Oct 21 15:12:50 click: got options_image's location (624, 337)
Fri Oct 21 15:12:50 click: waiting for continue_image, 1 templates for match...
Fri Oct 21 15:12:51 click: got continue_image's location (624, 465)
Fri Oct 21 15:12:51 click: checking for english_image till utilities_image...
Fri Oct 21 15:12:51 click: waiting for english_image, 2 templates for match...
Fri Oct 21 15:12:54 click: moving the cursor out of the screen
Fri Oct 21 15:12:56 click: waiting for utilities_image, 1 templates for match...
Fri Oct 21 15:12:58 click: got utilities_image's location (243, 11)
Fri Oct 21 15:12:58 click: waiting for terminal_image, 1 templates for match...
Fri Oct 21 15:13:00 click: got terminal_image's location (247, 63)
Fri Oct 21 15:13:00 click: adding template bash_image for match...
Fri Oct 21 15:13:00 click: waiting for bash_image, 1 templates for match...
Fri Oct 21 15:13:02 click: waiting for 1 sec 0 nsec
Fri Oct 21 15:13:03 click: waiting for 1 sec 0 nsec
Fri Oct 21 15:13:05 click: waiting for 1 sec 0 nsec
# Check if SIP is disabled
❯ anka run test csrutil status
System Integrity Protection status: disabled.
```