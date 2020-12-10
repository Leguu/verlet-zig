const std = @import("std");
const lsdl = @import("lsdl");

const Node = @import("node.zig").Node;
const Vector = @import("main.zig").Vector;

const Renderable = lsdl.render.Renderable;
const ArrayList = std.ArrayList;

pub fn Rope(len: usize) type {
    return struct {
        nodes: [len]Node,
        update_head: bool = false,
        core: *lsdl.Core,

        const gravity = Vector.new(0, 98);
        const friction = Vector.new(0.99, 0.99);
        const node_distance = 1;

        const Self = @This();

        pub fn new(core: *lsdl.Core, x: f32, y: f32) Self {
            var nodes: [len]Node = undefined;
            for (nodes) |*node, i| {
                node.* = Node.new(10 + x + @intToFloat(f32, i) * node_distance, 10 + y);
            }
            return Self{ .nodes = nodes, .core = core };
        }

        pub fn render(self: *Self, renderer: *lsdl.Render) void {
            renderer.setDrawColor(255, 255, 255, 255);
            for (self.nodes) |node, i| {
                if (self.head().equals(node)) {
                    renderer.drawCircle(node.position.x, node.position.y, 4);
                }
                if (i + 1 >= self.nodes.len) return;
                const next = self.nodes[i + 1];
                renderer.drawLine(node.position.x, node.position.y, next.position.x, next.position.y);
            }
        }

        pub fn head(self: *Self) *Node {
            return &self.nodes[0];
        }

        pub fn update(self: *Self, dt: f32) void {
            self.simulate(dt);
            var i: usize = 0;
            while (i < 10) : (i += 1) {
                self.handleConstraints();
            }
        }

        pub fn simulate(self: *Self, dt: f32) void {
            for (self.nodes) |*node, i| {
                if (node == self.head() and !self.update_head) {
                    continue;
                }
                var velocity = node.velocity();
                var acceleration = gravity;

                velocity = velocity.rescale(node.v_mul(dt)).multiply(friction);
                acceleration = acceleration.rescale(node.a_mul(dt));

                node.previous_dt = dt;
                node.previous = node.position;

                node.position = node.position.add(velocity).add(acceleration);
            }
        }

        pub fn handleConstraints(self: *Self) void {
            for (self.nodes) |*current, i| {
                const size = self.core.window.size();
                current.position.y = std.math.min(current.position.y, @intToFloat(f32, size.height - 10));
                current.position.y = std.math.max(current.position.y, 10);

                current.position.x = std.math.min(current.position.x, @intToFloat(f32, size.width - 10));
                current.position.x = std.math.max(current.position.x, 10);

                if (i + 1 >= self.nodes.len) break;
                const next: *Node = &self.nodes[i + 1];

                const distance = next.distance(current.*);

                if (!current.equals(self.head().*) or self.update_head) {
                    const temp = current.position;
                    current.position.moveToward(next.position, (distance - node_distance) * 0.91);
                    next.position.moveToward(temp, (distance - node_distance) * 0.91);
                } else {
                    next.position.moveToward(current.position, distance - node_distance);
                }
            }
        }
    };
}
