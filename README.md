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






Ideally it will contain different types:
images
strings
numbers






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