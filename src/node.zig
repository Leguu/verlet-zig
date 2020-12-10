const lsdl = @import("lsdl");

const Vector = @import("main.zig").Vector;

pub const Node = struct {
    position: Vector,
    previous: Vector,
    previous_dt: f32 = 1,

    const Self = @This();

    pub fn new(x: f32, y: f32) Self {
        return Self{ .position = Vector.new(x, y), .previous = Vector.new(x, y) };
    }

    pub fn set(self: *Self, x: f32, y: f32) void {
        self.* = new(x, y);
    }

    pub fn distance(self: *Self, other: Self) f32 {
        return self.position.subtract(other.position).length();
    }

    pub fn velocity(self: *Self) Vector {
        return self.position.subtract(self.previous);
    }

    pub fn v_mul(self: *Self, dt: f32) f32 {
        return dt / self.previous_dt;
    }

    pub fn a_mul(self: *Self, dt: f32) f32 {
        return dt * (dt + self.previous_dt) / 2;
    }

    pub fn equals(self: *Self, other: Self) bool {
        return self.position.equals(other.position) and self.previous.equals(other.previous) and self.previous_dt == other.previous_dt;
    }
};
