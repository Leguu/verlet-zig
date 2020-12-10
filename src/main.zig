const std = @import("std");
const lsdl = @import("lsdl");

const Rope = @import("rope.zig").Rope;

pub const Vector = lsdl.Vector(f32);

pub fn main() anyerror!void {
    var core = lsdl.Core.new(1000, 800);
    var timer_sixty = try lsdl.Timer.new();
    var timer_hundred = try lsdl.Timer.new();

    var rope = Rope(256).new(&core, 0, 0);

    var running = true;
    while (running) {
        while (core.input.poll()) |event| {
            if (event.type == lsdl.SDL_QUIT or event.button.button == lsdl.SDL_SCANCODE_Q) {
                running = false;
            }
        }

        if (timer_hundred.doFrame(200)) {
            const dt = 10 * timer_hundred.deltaTime(f32) / std.time.ns_per_s;

            rope.update(dt);

            timer_hundred.tick();
        }

        if (timer_sixty.doFrame(60)) {
            rope.input();

            core.render.clear(0, 0, 0, 255);
            rope.render(&core.render);
            core.render.present();

            timer_sixty.tick();
        }
    }
}
