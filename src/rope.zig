const std = @import("std");
const lsdl = @import("lsdl");

const Node = @import("node.zig").Node;
const Vector = @import("main.zig").Vector;

const Renderable = lsdl.render.Renderable;
const ArrayList = std.ArrayList;

pub fn Rope(len: usize) type {
    return struct {
        core: *lsdl.Core,
        nodes: [len]Node,
        previous_mouse: Vector = Vector.zero(),

        const gravity = Vector.new(0, 98);
        const friction = Vector.new(0.99, 0.99);
        const node_distance = 3;

        const Self = @This();

        pub fn new(core: *lsdl.Core, x: f32, y: f32) Self {
            var nodes: [len]Node = undefined;
            for (nodes) |*node, i| {
                node.* = Node.new(10 + x + @intToFloat(f32, i) * node_distance, 10 + y);
            }
            return Self{ .nodes = nodes, .core = core };
        }

        pub fn render(self: *Self, renderer: *lsdl.Render) void {
            renderer.setDrawColor(lsdl.Color.white());
            for (self.nodes) |node, i| {
                if (self.head().equals(node)) {
                    renderer.drawCircle(node.position.x, node.position.y, 4);
                }
                if (i + 1 >= self.nodes.len) break;
                const next = self.nodes[i + 1];
                renderer.drawLine(node.position.x, node.position.y, next.position.x, next.position.y);
            }

            renderer.setDrawColor(lsdl.Color.gray(100));
            const size = self.core.window.size(f32);
            renderer.drawRectangle(10, 10, size.width - 20, size.height - 20);
        }

        pub fn head(self: *Self) *Node {
            return &self.nodes[0];
        }

        pub fn input(self: *Self) void {
            if (self.core.input.mousePressed()) {
                var node = self.head();
                const pos = self.core.input.mousePosition(f32);

                node.position = pos;
                node.previous.redistance(pos, 0.8);
            }
        }

        pub fn update(self: *Self, dt: f32) void {
            self.simulate(dt);
            var i: usize = 0;
            while (i < 50) : (i += 1) {
                self.handleConstraints();
            }
        }

        pub fn simulate(self: *Self, dt: f32) void {
            for (self.nodes) |*node, i| {
                if (node == self.head() and self.core.input.mousePressed()) {
                    continue;
                }
                if (!self.head().equals(node.*)) self.windowConstraint(node);
                var velocity = node.velocity();
                var acceleration = gravity;

                velocity = velocity.rescale(node.v_mul(dt)).multiply(friction);
                acceleration = acceleration.rescale(node.a_mul(dt));

                node.previous_dt = dt;
                node.previous = node.position;

                if (self.head().equals(node.*))
                    self.windowConstraint(node);

                node.position = node.position.add(velocity).add(acceleration);
            }
        }

        pub fn windowConstraint(self: *Self, node: *Node) void {
            // Constrain to window size
            const size = self.core.window.size(f32);
            node.position.y = std.math.min(node.position.y, size.height - 10);
            node.position.y = std.math.max(node.position.y, 10);
            node.position.x = std.math.min(node.position.x, size.width - 10);
            node.position.x = std.math.max(node.position.x, 10);
        }

        pub fn handleConstraints(self: *Self) void {
            for (self.nodes) |*current, i| {
                if (i + 1 >= self.nodes.len) break;
                const next: *Node = &self.nodes[i + 1];

                const distance = next.distance(current.*);
                const value = (distance - node_distance) * 0.99;

                if (!current.equals(self.head().*)) {
                    current.redistance(next, value);
                } else {
                    next.position.moveToward(current.position, distance - node_distance);
                }
            }
        }
    };
}
