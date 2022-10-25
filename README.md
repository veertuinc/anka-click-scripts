# Anka Click/MUAS Scripts

This repo is a collection of Behavior-Driven MacOS UI Automation Framework scripts and tools for Anka's "click" feature. Often, macOS and applications do not have a CLI allowing you to perform certain actions such as toggling configuration options. This varies from app to app and can severely impact the maintainabiliy and automatability for your team. With MUAF scripts, you can programmatically target, click, send keystrokes, and much more to your Anka VM's macOS UI.

Some examples of what you can automate:

- Disabling SIP from Apple Silicon VMs (which requires Recovery Mode).
- Enabling VNC/Remote Management under System Preferences.
- Enabling certain settings only available in the Simulator Menu (Prefer Discrete GPU) to optimize simulator tests.

# Syntax Basics

## Variables

### `$<variable name>`

Assign a `string`, `integer`, or `png image (as base64)` to a variable at the top of your muas script with `$<label>`. These are then made available throught the script logic.

```
$macos_maj_ver 12
$prefix "muas-"
$next_image iVBORw0KGgoAAAANSUhEUgAA. . .
```

**PRO TIP:** If there are multiple image/png variables with the same name, the framework will try each image until it gets a match.


## Clicking and Targeting

### `(<location/target>)[mouse button]`

There are many times that macOS or your applications will require user confirmation for popup dialogs. Defining where and how to click is fairly simple:

#### Location/Target

- **Center of Image:** `(image_variable_name)` allows you to target the center of an image on screen using the variable name defined in your script.
- **Coordinate:**`(X,Y)` is the pixels starting from the top left corner of the screen (which is `(0,0)`).
    - `+` and `-` are available to control the direction from the previous mouse location: `(+350` is right 350 pixels, and `-10)` will be up 10 pixels.
    - You can also target and click relative to previous mouse location: `(vnc_image)0 (+350,+0)`

#### Mouse Button

- `0`: do nothing, just use the location specified as a starting target for subsequent directives
- `1`: (default) left click with tiny interval between down and up

#### Example

This code snippet will target the center of vnc_image, avoid clicking with 0, and then from there move +350,+0 and click.

```
(vnc_image)0
(+350,+0)
if modify_settings_image, on_image
    "admin\n"
else
    +500
end
```

## Waiting

### `+<duration/image variable>`

It is very common for applications to take time to load. Often you'll want to execute actions and have delays in between them so you can guarantee subsequent actions are not performed prematurely. This can be done with either a duration or image variable:

- **Duration:** The interval as an integer that the script will wait before proceeding: `+2s, +5000n, 300 (msec by default)`
- **Wait for Image:** The image we want to ensure is visible before proceeding: `+bash_image`

#### Example

This code snippet will, inside of Recovery Mode, click Utilities in the menu bar, then the Terminal button, and once terminal is opened type "csrutil disable" and hit return.

```
(utilities_image) (terminal_image)
+bash_image
"csrutil disable\n"
+1s
"y\n"
+1s
"admin\n"
+1s
"shutdown -h now\n"
```

## Keystrokes

### `"keystrokes here\n"`

Simulating user input is also possible. This is useful for typing logins or setting configuration values within user prompts. It will not automatically execute return, so be sure to use `\n` on the end for that. You can also tab with `\t`.

#### Example

```
(utilities_image) (terminal_image)
+bash_image
"csrutil disable\n"
+1s
"y\n"
+1s
"admin\n"
+1s
"shutdown -h now\n"
```

## Keyboard Shortcuts

### `:<key> <key> . . .`

Closing or quitting applications can be done through clicking, however, keyboard shortcuts are often much easier to use. You can define 8 keys to be pressed simultaneously inside of the script. 

Note: Some codes aren't what you expect. The command key is `cmd` and escape `esc`. You can find macOS QUERTY keyboard codes through a simple google search.

#### Examples

The incomplete snippet below will enable VNC inside of System Preferences and then quit with it `:cmd q`
```
. . .
if off_image, on_image
    (vnc_image)0
    (+350,+0)
    if modify_settings_image, on_image
        "admin\n"
    else
        +500
    end
end

:cmd q
```

---

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

This line could be read as if wait for off_image till on_image succeeded do something
succeeded means the off_image appeared, not on_image, on_image is just allow to abort waiting

So it is's already on do nothing in this particular case


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

<!-- ### Prefer Discrete GPU in Simulator

While most scripts will be for Anka VM Template preparation, you can of course use it in your Controller-less setup where you have access to the Anka CLI on the host. This example shows how to achieve this.

1. Start a Ventura VM
2. Ensure Xcode is installed
3. Copy in the `swift-voxel.bash` script

    ```bash
    #!/usr/bin/env bash
    set -exo pipefail
    cd "${HOME}"
    if [[ "${*}" =~ "prep" ]]; then
        [[ ! -d SwiftVoxel ]] && git clone https://github.com/claygarrett/SwiftVoxel.git
    fi
    if [[ "${*}" =~ "build-launch-simulator-and-install" ]]; then
        cd SwiftVoxel
        xcrun simctl list --json devices available; sleep 20 # fix a weird bug where xcrun simctl list --json devices available is empty the first run
        SIM_VER="$(xcrun simctl list --json devices available | grep name | grep Pro | head -1 | cut -d'"' -f4)"
        xcodebuild -workspace SwiftVoxel.xcworkspace -derivedDataPath /tmp/ -scheme SwiftVoxel -destination "platform=iOS Simulator,name=${SIM_VER}" build
        SIMID=$(xcrun simctl create test "com.apple.CoreSimulator.SimDeviceType.$(echo ${SIM_VER} | sed 's/ /-/g')")
        xcrun simctl boot "${SIMID}"
        sleep 120
        open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app
        xcrun simctl install test /tmp/Build/Products/Debug-iphonesimulator/SwiftVoxel.app
    fi
    if [[ "${*}" =~ "test" ]]; then
        BUNDLE_ID="$(defaults read /tmp/Build/Products/Debug-iphonesimulator/SwiftVoxel.app/Info.plist CFBundleIdentifier)"
        xcrun simctl launch test "${BUNDLE_ID}"
        sleep 300 # Sleep 5 minutes to make sure the VM doesn't crash
    fi
    ```

4. Run the `swift-voxel.bash` prepare, build, install, and open simulator stages. Then, before executing the test, run the `simulator-prefer-discrete-gpu.muas` script.

    ```bash
    # Set up swift voxel repo inside of VM
    ❯ anka run 13.0 bash -lc "./swift-voxel.bash prep"
    # Build swift voxel, start simulator, and then install it inside
    ❯ anka run 13.0 bash -lc "./swift-voxel.bash build-launch-simulator-and-install"
    # Prepare simulator with discrete GPU
    ❯ anka --debug view --click 13.0/simulator-prefer-discrete-gpu/simulator-prefer-discrete-gpu.muas 13.0
    # Run test in simulator
    ❯ anka run 13.0 bash -lc "./swift-voxel.bash test"
    ``` -->

### Enable Kernel Extensions

1. Boot into Recovery Mode

    ```bash
    ❯ ANKA_START_MODE=2 anka start -v 13.0
    ```

2. Execute `enable-kernel-extensins.muas`

```bash
❯ anka --debug view --click 13.0/enable-kernel-extensions/enable-kernel-extensions.muas 13.0
```

## Script Development

### Working with images

You will eventually have a need to target a specific 

There are several tools you can use to make development of scripts easier:

1. `unencode-images.bash` - Allows you take the base64 png variables in the MUAS and export them to png files.

    ```bash
    ❯ ls 13.0/enable-vnc/                
    enable-vnc.muas

    ❯ .tools/unencode-images.bash 13.0/enable-vnc/enable-vnc.muas
    . . .

    ❯ ls 13.0/enable-vnc/ 
    background.png      general_title.png   on.png              vnc_alt.png
    close.png           login_items.png     settings.png
    enable-vnc.muas     modify_settings.png sharing.png
    general.png         off.png             vnc.png
    ```

2. `encode-images.bash` - Allows you to take all images in the same directory as the MUAS and encode them as variables.

    ```bash
    ❯ ls 13.0/enable-vnc/ 
    background.png      general_title.png   on.png              vnc_alt.png
    close.png           login_items.png     settings.png
    enable-vnc.muas     modify_settings.png sharing.png
    general.png         off.png             vnc.png

    ❯ ls 13.0/enable-vnc/                                        
    enable-vnc.muas

    ❯ head -3 13.0/enable-vnc/enable-vnc.muas  
    $vnc_image iVBORw0KGgoAAAANSUhEUgAAA. . .
    $vnc_image iVBORw0KGgoAAAANSUhEUgAAA. . .
    $sharing_image iVBORw0KGgoAAAANSUhEUgAAA. . .
    . . .
    ```






TODO:

- Support || for separating alternative images in () instead of having them have the same name
- Guide for icloud login