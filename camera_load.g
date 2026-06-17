; camera_load.g
; Universal macro to safely load a tool and move to the camera for offset calibration

; 1. PRE-FLIGHT SAFETY CHECKS
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
    abort "Error: Machine is not homed. Home all axes before running calibration moves."

if !exists(param.T)
    abort "Error: No tool parameter provided. Check your BTNCMD button code."

; For T1-T4, ensure the T0 origin has actually been captured first
if param.T > 0 && !exists(global.t_zero_alignment_origin_x)
    abort "Error: You must load T0 and capture its camera position before calibrating other tools!"

; --- TOOL EXISTENCE AND HEALTH CHECKS ---
; Ensure the requested tool number actually exists in the firmware memory
if param.T >= #tools || tools[param.T] == null
    abort "Error: Tool " ^ param.T ^ " does not exist in the Object Model. Check config.g."

; Ensure the tool is alive by checking if its primary heater has faulted (e.g., CAN board dropped offline)
if #tools[param.T].heaters > 0
    if heat.heaters[tools[param.T].heaters[0]].state == "fault" || heat.heaters[tools[param.T].heaters[0]].state == "offline"
        abort "Error: Tool " ^ param.T ^ " is reporting a fault. Check the CAN bus connection!"

; 2. WIPE THE SLATE (OR VERIFY)
; If V1 is passed, keep the offsets for a verification check. Otherwise, clear them for calibration.
if exists(param.V) && param.V == 1
    echo "Verification Mode: Retaining existing offsets for Tool " ^ param.T
else
    ; Clear the target tool's offset while it is still in the dock. 
    ; Doing this for T0 ensures your baseline reference is strictly enforced at 0,0.
    G10 P{param.T} X0 Y0
    echo "Calibration Mode: Offsets pre-cleared for Tool " ^ param.T
    

; 3. EXECUTE SAFE TOOL CHANGE
T{param.T}
M400 ; Wait for all physical tool change movements to stop
;
;
; 4. NAVIGATE & PROMPT
if param.T == 0
    ; --- T0 LOGIC ---
    if !exists(global.t_zero_alignment_origin_x)
        ; First run after reboot: No camera coords exist yet.
        M291 P"T0 loaded. Jog nozzle to crosshair and press your CAPTURE ORIGIN button." S2
    else
        ; Camera coords exist: Drive to them to double-check alignment.
        G1 X{global.t_zero_alignment_origin_x} Y{global.t_zero_alignment_origin_y} F6000 
        M400
        M291 P"T0 loaded and moved to saved camera origin. Ready to verify." S2
else
    ; --- T1 through T4 LOGIC ---
    ; Drive carriage to the exact physical coordinates captured by T0
    G1 X{global.t_zero_alignment_origin_x} Y{global.t_zero_alignment_origin_y} F6000 
    M400
    
    ; Smart popup based on Verification Mode
    if exists(param.V) && param.V == 1
        M291 P{"Tool " ^ param.T ^ " moved to camera using SAVED offsets. Verify crosshair alignment."} S2
    else
        M291 P{"Tool " ^ param.T ^ " loaded safely. Jog nozzle to crosshair and calculate NEW offset."} S2


