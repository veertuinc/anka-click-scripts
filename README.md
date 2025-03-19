# Anka Click Scripts

This repo is a collection of scripts and tools for Anka's "click" feature. Starting in Anka 3.2, we've introduced a solution to scripting macOS UI actions. "Why would I want to do that" you may ask. Well, often macOS configuration and applications do not have a CLI allowing you to perform certain actions such as toggling options on and off. This varies from app to app and can severely impact the maintainability and automatability of macOS CI/CD/Automation for your team. With Anka Click scripts, you can programmatically target, click, and send keystrokes to your Anka VM's UI without needing CLI commands or a shell.

Some examples of what you can automate:

- Disabling SIP from Apple Silicon VMs (which requires Recovery Mode).
- Enabling VNC/Remote Management under System Preferences. 
- Enabling certain settings only available in the Simulator Menu (Prefer Discrete GPU) to optimize simulator tests.

---

**Starting in Anka 3.3.0, `/Library/Application\ Support/Veertu/Anka/bin/click` is available inside of your VMs, allowing you to run click scripts without needing access to the host!**

## Usage Examples

### Disable SIP (through Recovery Mode)

```bash
# Create a VM without SIP disabled already
❯ ANKA_CREATE_SIP=0 anka --debug create -m 6G -c 4 -d 128G -a /Users/m1mini/Downloads/UniversalMac_13.0_22A379_Restore.ipsw 13.0
# Start it in Recovery Mode (2)
❯ ANKA_START_MODE=2 anka start 13.0
# Run disable-sip script against VM booted in Recovery Mode
❯ anka --debug view --click 13.0/disable-sip/disable-sip.click 13.0
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
❯ anka run 13.0 csrutil status
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

4. Run the `swift-voxel.bash` prepare, build, install, and open simulator stages. Then, before executing the test, run the `simulator-prefer-discrete-gpu.click` script.

    ```bash
    # Set up swift voxel repo inside of VM
    ❯ anka run 13.0 bash -lc "./swift-voxel.bash prep"
    # Build swift voxel, start simulator, and then install it inside
    ❯ anka run 13.0 bash -lc "./swift-voxel.bash build-launch-simulator-and-install"
    # Prepare simulator with discrete GPU
    ❯ anka --debug view --click 13.0/simulator-prefer-discrete-gpu/simulator-prefer-discrete-gpu.click 13.0
    # Run test in simulator
    ❯ anka run 13.0 bash -lc "./swift-voxel.bash test"
    ``` -->

### Enable Kernel Extensions

1. Boot into Recovery Mode

    ```bash
    ❯ ANKA_START_MODE=2 anka start -v 13.0
    ```

2. Execute `enable-kernel-extensions.click`

    ```bash
    ❯ anka --debug view --click 13.0/enable-kernel-extensions/enable-kernel-extensions.click 13.0
    ```

---

## Syntax Basics

### Variables

#### `$<variable_name>`

Assign a `string`, `integer`, or `png image (as base64)` to a variable with `$<variable_name>`. The `variable_name` should not start with a digit, contain whitespaces, punctuation or control characters, and be a Anka Click keywords like 'if'.

```
$macos_maj_ver 12
$prefix "vmName-"
$next_image iVBORw0KGgoAAAANSUhEUgAA. . .
```

**PRO TIP:** If there are multiple image/png variables with the same name, the framework will try each image until it gets a match.

### Targeting, Mouse Movement, and Clicking

#### `(<location/target>)[mouse buttons]`

There are many times that macOS or your applications will require user confirmation for popup dialogs. Defining what to move the mouse (starting initially from the top left of the screen) over and what to click on is fairly simple.

##### Location/Target

- **Text:** `("Describe")` will click on the center of the text on screen. Only available in Anka 3.4 and above.
- **Center of Image:** `(image_variable_name)` allows you to target the center of an image on screen using the variable name defined in your script.
- **Coordinate:**`(X,Y)` is the pixels starting from the top left corner of the screen (which is `(0,0)`).
    - `+` and `-` are available to control the direction from the previous mouse location: `(+350` is right 350 pixels, and `-10)` will be up 10 pixels.
    - You can also target and click relative to previous mouse location: `(vnc_image)0 (+350,+0)`
    - Dragging is possible with `(icon)1 (+200,+0)0`
**PRO TIP:** Mouse movement is performed from the last targeted location. This can cause menus to close if the mouse is somehow moving outside of the menu's borders. Make sure to chain your mouse movements to prevent this.

**Note:** By default in Anka 3.1.2, we disable `Dynamic Wallpapers` and enable `Reduce transparency`. Without these, your targeting may not work should the VM's desktop change colors or menus have different things open under them when transparency is enabled. If manually creating VMs, please set these in the VM you're running Anka Click scripts on.

##### Mouse Buttons

- `0`: all buttons up do nothing, could be used as reference location for subsequent relative directives
- `1`: left button down
- `2`: right button down

If no buttons were specified in directive, left button (`1`) click is used.

**PRO TIP:** You can click multiple times with something like `(image) (+0,+0) (+0,+0) (+0,+0) (+0,+0) (+0,+0)`.

##### Examples

This code snippet will target the center of vnc_image, avoid clicking with 0, and then from there move +350,+0 and click.

```
(vnc_image)0 (+350,+0)
if modify_settings_image, on_image
    "admin\n"
else
    +500
end
```

This example shows a simple Text targeting and clicking script.

```
❯ cat test.click
if "Allow" ("Allow")
❯ anka --debug view --click test.click test
Tue Jul  9 15:06:20 main: executing command view
Tue Jul  9 15:06:20 view: starting execution of test.click
click: checking for "Allow" till <timeout>...
click: waiting for "Allow" and 0 other templates for match...
click: Allow - (473, 334) in Don't Allow (418, 327; 72, 14)
click: waiting for "Allow" and 0 other templates for match...
click: Allow - (473, 334) in Don't Allow (418, 327; 72, 14)
click: got "Allow"'s location (473, 334)
click: generating (473, 334) 1
```

If you want to move the mouse to the top left corner of the screen, but not click, use `(0,0)0`.

### Waiting

#### `+<duration/image variable>`

It is very common for applications to take time to load. Often you'll want to execute actions and have delays in between them so you can guarantee subsequent actions are not performed prematurely. This can be done with either a duration or image variable:

- **Duration:** The interval as an integer that the script will wait before proceeding: `+2s, +5000n, 300 (msec by default)`
- **Wait for Image:** The image we want to ensure is visible before proceeding: `+bash_image`

**PRO TIP:** You can have multiple wait directives on the same line. Example: `+finder,5s`

The default timeout is 5 minutes.

##### Example

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

**PRO TIP:** Should you need to delay the time between moving the mouse over a target and the click, you can use

```
(image_to_target)0
+1s
(+0,+0)
```

##### Behavioral Sequences

In the last example, you'll see the following:

```
(utilities_image) (terminal_image)
+bash_image
```

Click directives can be organized in sequences all on the same line. This same-line-sequence applies additional logic which will, if `utilities_image` doesn't exist, move on to try clicking on `terminal_image`. This does not apply, however, when they are on separate lines.

### Keystrokes

#### `"<keystrokes here>\n"`

Simulating user input is also possible. This is useful for typing logins or setting configuration values within user prompts. It will not automatically execute return, so be sure to use `\n` on the end for that. You can also tab with `\t`.

##### Example

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

### Keyboard Shortcuts

#### `:<key> <key> . . .`

Closing or quitting applications can be done through clicking, however, keyboard shortcuts are often much easier to use. You can define up to 8 keys to be pressed simultaneously inside of a single shortcut directive. 

Note: You can find macOS QUERTY keyboard codes through a simple google search.

##### Examples

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

### Conditionals

#### `if <desired_var> [, <undesired_var>]`

Keywords like 'if' are available to use inside of your scripts. It requires at a minimum one variable name. The first variable in the condition -- the image to be waited for on screen.

```
if desired_image (target_image)
```

The rules to execute can be split onto separate lines and wrapped using `end`. The example below will, if `input_image` exists, type the password and hit return.

```
if input_image
    "password\n"
end
```

The `else` keyword is also possible. The following example will check if `login_items_image` exists, click itself, then click `sharing_image`, or else click on `general_image` before `sharing_image`.

```
if login_items_image
    (login_items_image) (sharing_image)
else
    (general_image) (sharing_image)
end
```

There are also ways to handle differences between OS versions. The next example is taken from a script that handles when different macOS versions are used and only some of them show a language selection. If a second variable is present with a comma separating them, you can only expect that the first variable will be waited on **as long as** the second is not present.

```
if english_image, menu_utilities_image
    (english_image) (next_image)
end
```

Finally, you can conditionally execute text targeting. Here is an example:

```
if "Are you sure to delete file?" ("Delete")
```

##### Example

This example will ensure that, even if Prefer Discrete GPU is enabled already, the script will complete. [See the full script here.](./simulator-prefer-discrete-gpu/simulator-prefer-discrete-gpu.click)

```
(dock_simulator_icon_image)
; click on File in the menu, then click on GPU Selection.
(menu_file_image)
(menu_gpu_selection_image)
; IF prefer discrete gpu is not enabled
if menu_prefer_discrete_gpu_image, menu_prefer_discrete_gpu_enabled_image
    ; enable discrete gpu
    (menu_prefer_discrete_gpu_image)
else
    ; otherwise bring simulator to front again and exit script
    (dock_simulator_icon_image)
    exit
end

```

#### `while [ ! ] <variable>`

While loops are useful to perform an action until it's no longer true. Long lists, repetitive items and so could be handled with the while directive.

```
; remove the "background items added" popups until they no longer exist as they will cover up other images we're targetting
while background_image (background_image)
```

##### Example

```
while !img
:down
:down
:down
:down
:down
end
```

#### `exit`

Stops all the further script processing with `success` status.

#### `abort`

Stops all the further script processing with `failure` status.


### Comments

#### `; <string>`

##### Example

```
(dock_simulator_icon_image)
; check if the simulator was brought to front
if menu_simulator_image
    ; click on File in the menu, then click on GPU Selection.
. . .
```

---

## Tips

- There are scrolling limitations, especially for System Preferences. To get around these, use something like `open 'x-apple.systempreferences:com.apple.preference.security?Security'` in the Terminal to go to a specific section of the System Preferences.

---

## Script Development

### Working with Images

#### Targeting Accuracy

The targeting engine does its best to match your screenshot with what it finds on the screen. Here are a few things to keep in mind to ensure that your targeting of images works as expected:

- Differences in scale/resolution can impact this, so ensure that you're not using a different scale/zoom when viewing your VMs desktop. `anka view -s` is recommended.
- Transparency behind menu items and other colors can change. It may help for you to drop the saturation in your images to eliminate colors, but also keep in mind that gradients may be present.
- The less data in the image the better. Crop your images so that only what is necessary is present.

#### Encoding / Unencoding

Images used for targeting are base64 encoded and placed directly into scripts. Because of this, you need an easy way to unencode them from the script into png files and then also encode them once changes are made or new pngs are added. There are two scripts for this:

1. `unencode-images.bash` - Allows you take the base64 png variables in the anka click script and export them to png files.

    ```bash
    ❯ head -3 13.0/enable-vnc/enable-vnc.click  
    $vnc_image iVBORw0KGgoAAAANSUhEUgAAA. . .
    $vnc_image iVBORw0KGgoAAAANSUhEUgAAA. . .
    $sharing_image iVBORw0KGgoAAAANSUhEUgAAA. . .
    . . .

    ❯ ls 13.0/enable-vnc/                
    enable-vnc.click

    ❯ .tools/unencode-images.bash 13.0/enable-vnc/enable-vnc.click
    . . .

    ❯ ls 13.0/enable-vnc/ 
    vnc.png   vnc_alt.png
    enable-vnc.click     sharing.png
    ```

2. `encode-images.bash` - Allows you to take all images in the same directory as the script and encode them as variables.

    ```bash
    ❯ ls 13.0/enable-vnc/ 
    vnc.png   vnc_alt.png
    enable-vnc.click     sharing.png

    ❯ ls 13.0/enable-vnc/                                        
    enable-vnc.click

    ❯ head -3 13.0/enable-vnc/enable-vnc.click  
    $vnc_image iVBORw0KGgoAAAANSUhEUgAAA. . .
    $vnc_image iVBORw0KGgoAAAANSUhEUgAAA. . .
    $sharing_image iVBORw0KGgoAAAANSUhEUgAAA. . .
    . . .
    ```
