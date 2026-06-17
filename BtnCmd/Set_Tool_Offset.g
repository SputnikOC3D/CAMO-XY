; Ensure a tool OTHER than T0 is active
if state.currentTool <= 0
    abort "Error: Load a tool other than T0 to calculate an offset."

; Ensure the T0 capture button was actually pressed first
if !exists(global.t_zero_alignment_origin_x)
    abort "Error: You must capture T0's position first!"

; Calculate the delta (T0 Position - Current Machine Position)
var offset_x = global.t_zero_alignment_origin_x - move.axes[0].machinePosition
var offset_y = global.t_zero_alignment_origin_y - move.axes[1].machinePosition

; Apply the new offset to the currently active toolhead
G10 P{state.currentTool} X{var.offset_x} Y{var.offset_y}

; Echo the result to the console so you can see the math it did
echo "Tool " ^ state.currentTool ^ " offset set to X:" ^ var.offset_x ^ " Y:" ^ var.offset_y

; Save the tool offsets permanently to the override file
M500 P10