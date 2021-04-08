const std = @import("std");
const lsdl = @import("lsdl");

const Rope = @import("rope.zig").Rope;

pub const Vector = lsdl.Vector(f32);

pub fn main() anyerror!void {
    var core = lsdl.Core.new(lsdl.Size.new(1000, 800));
    var timer = try lsdl.Timer.new();

    var rope = Rope(128).new(&core, 0, 0);

    var running = true;
    while (running) {
        while (lsdl.input.poll()) |event| {
            if (event.type == lsdl.SDL_QUIT or event.button.button == lsdl.SDL_SCANCODE_Q) {
                running = false;
            }
        }

        if (timer.doFrame()) {
            rope.input();
            const dt = 10 * @intToFloat(f32, timer.deltaTime()) / std.time.ns_per_s;
            rope.update(dt);
            std.debug.print("{}\n", .{dt});

            core.render.clear(lsdl.Color.black);
            rope.render(&core.render);
            core.render.present();
        }

        timer.tick();
        timer.wait();
    }
}
