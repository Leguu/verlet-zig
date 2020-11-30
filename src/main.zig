const std = @import("std");
const lsdl = @import("lsdl");

const Rope = @import("rope.zig").Rope;

pub const Vector = lsdl.math.Vector(f32);

pub fn main() anyerror!void {
    var core = lsdl.core.Core.new(1000, 800);
    var timer = try lsdl.timer.Timer.new();

    var rope = Rope(256).new(0, 0);

    var running = true;
    while (running) {
        const event = &core.input.event;
        while (core.input.poll()) {
            if (event.type == lsdl.SDL_QUIT or event.button.button == lsdl.SDL_SCANCODE_Q) {
                running = false;
            }
        }

        if (1 == lsdl.SDL_GetMouseState(0, 0)) {
            rope.head().set(@intToFloat(f32, event.button.x), @intToFloat(f32, event.button.y));
            rope.update_head = false;
        } else {
            rope.update_head = true;
        }

        if (!timer.doFrame(60)) continue;
        const dt = 10 * timer.deltaTime(f32) / std.time.ns_per_s;

        rope.update(dt);

        core.render.clear(0, 0, 0, 255);
        rope.render(&core.render);
        core.render.present();

        timer.tick();
    }
}
