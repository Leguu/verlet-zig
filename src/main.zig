const std = @import("std");
const lsdl = @import("lsdl");

pub fn main() anyerror!void {
    var core = lsdl.core.Core.new(1000, 800);
    var timer = try lsdl.timer.Timer.new();

    MAIN: while (true) {
        if (!timer.doFrame(60)) continue;

        const event = &core.input.event;
        while (core.input.poll()) {
            if (core.input.event.type == lsdl.SDL_QUIT or core.input.event.button.button == lsdl.SDL_SCANCODE_Q) {
                break :MAIN;
            }
        }

        if (1 == lsdl.SDL_GetMouseState(0, 0)) {
            core.renderer.setDrawColor(255, 0, 0, 255);
            core.renderer.drawCircle(@intToFloat(f32, event.button.x), @intToFloat(f32, event.button.y), 10);
        }

        core.renderer.setDrawColor(255, 255, 255, 255);
        core.renderer.drawCircle(@intToFloat(f32, core.window_width) / 2, @intToFloat(f32, core.window_height) / 2, 50);

        core.renderer.present();
    }
}
