# anka-MUAF-scripts
Behavior-Driven MacOS UI Automation Framework scripts for Anka


### Basic Example

```bash
❯ anka create --no-setup -a latest latest-macOS
100% [||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||]          
e90db9dd-7606-45cc-9bdd-e70491dec02d

```

1. architecture
2. macOS version



## Variables

Assign a string, integer, or png image (as base64) to a variable at the top of your muas script with `$<label>`. These are then made available throught the script logic.

```
$macos_maj_ver 12
$prefix "muas-"
$next_image iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAUGVYSWZNTQAqAAAACAACARIAAwAAAAEAAQAAh2kABAAAAAEAAAAmAAAAAAADoAEAAwAAAAEAAQAAoAIABAAAAAEAAAAgoAMABAAAAAEAAAAgAAAAAL5bTO0AAAIFaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA2LjAuMCI+CiAgIDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIgogICAgICAgICAgICB4bWxuczpleGlmPSJodHRwOi8vbnMuYWRvYmUuY29tL2V4aWYvMS4wLyI+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgICAgIDxleGlmOlBpeGVsWERpbWVuc2lvbj4xMDI0PC9leGlmOlBpeGVsWERpbWVuc2lvbj4KICAgICAgICAgPGV4aWY6UGl4ZWxZRGltZW5zaW9uPjc2ODwvZXhpZjpQaXhlbFlEaW1lbnNpb24+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgp/iD9uAAAByElEQVRYCe2WyYrCQBRFb+zGAQcEBQdcqIhbwYX/oAtRv6j/SAV/wJ2foTgPCIIiDtDdt8BGYxljUiANqU1SyXvvntx6VUQrFovfeONwvVFbSDsAjgP/3wGXy4VyuYxSqWRpQ31ayrpK8nq9yOfz0DQNPp8P3W736u3z249EIvH1POxxxOl0wna7RTabxW8teDweDAaDxwm6N7YBWG+5XGK32yGTyQgIutLv93VS8qkSAJZeLBbY7/dIp9MvQSgDIMR8Psdms/lbDvbEMyeUAhBitVphNpshl8shmUyKxjSCUA5ACLowHA4FRCqVMoSQbsNqtSroWczK4M44HA44Ho9gQxYKBdEfvV7vrpwUIBqNisS7aJMPKBoMBm+iQ6HQzfwy0WQ/JG63G4FA4BLz8pUO8ISsVCqIxWKYTCZotVrCEX0xqQO0br1e62NNz/m19Xod4XDYUJwFpQCmlSSBkUgEjUYDfr9fiDebTdCRR0MpAI/iWq0mjuPxeCxsNxInlDKAeDwubGf/jEYjtNttwy+/OKLkf4CNRttfFSeEbQCKWhUngJIl4K6ZTqfodDo4n8+sa3pIzwHT2QoCbS+BXQYHwHHg7Q78AOAlpzTuTXd0AAAAAElFTkSuQmCC
```


Ideally it will contain different types:
images
strings
numbers



TODO:

- Support || for separating alternative images in () instead of having them have the same name


() - click (pointer event), could be absolute: (123, 456), pattern based (images) - will wait and position on its center, or relative according to previous click - (+1, -0)

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