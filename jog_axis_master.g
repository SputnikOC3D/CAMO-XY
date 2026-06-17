; jog_axis_master.g
; Parameters: A (Axis string: "X", "Y", or "Z"), D (Distance numeric, positive or negative)

; 1. PARAMETER CHECKS
if !exists(param.A) || !exists(param.D)
    abort "Error: Missing axis (A) or distance (D) parameter."

; 2. SAFETY HOMING CHECKS
if param.A == "X" && !move.axes[0].homed
    abort "Error: X axis not homed. Cannot jog."
elif param.A == "Y" && !move.axes[1].homed
    abort "Error: Y axis not homed. Cannot jog."
elif param.A == "Z" && !move.axes[2].homed
    abort "Error: Z axis not homed. Cannot jog."

; 3. EXECUTE RELATIVE MOVE
G91 ; Switch to relative positioning
if param.A == "X"
    G1 X{param.D} F300
elif param.A == "Y"
    G1 Y{param.D} F300
elif param.A == "Z"
    G1 Z{param.D} F300  ; Slower feedrate for Z axis
else
    G90 ; Revert to absolute if someone passed a bad axis letter
    abort "Error: Invalid axis parameter. Use 'X', 'Y', or 'Z'."

G90 ; Revert back to absolute positioning