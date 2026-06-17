; Ensure T0 is the active tool
if state.currentTool != 0
    abort "Error: You must have T0 active to set the alignment origin!"

; Create global variables if they don't exist yet, or update them if they do
if !exists(global.t_zero_alignment_origin_x)
    global t_zero_alignment_origin_x = move.axes[0].machinePosition
    global t_zero_alignment_origin_y = move.axes[1].machinePosition
else
    set global.t_zero_alignment_origin_x = move.axes[0].machinePosition
    set global.t_zero_alignment_origin_y = move.axes[1].machinePosition

; Send a success message to the DWC console
echo "T0 origin captured at X:" ^ global.t_zero_alignment_origin_x ^ " Y:" ^ global.t_zero_alignment_origin_y