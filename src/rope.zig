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

        const gravity = Vector.new(0, 10);
        const friction = Vector.new(1, 1);
        const node_distance = 2;

        const Self = @This();

        pub fn new(x: f32, y: f32) Self {
            var nodes: [len]Node = undefined;
            for (nodes) |*node, i| {
                node.* = Node.new(x + @intToFloat(f32, i) * node_distance, y);
            }
            return Self{ .nodes = nodes };
        }

        pub fn render(self: *Self, renderer: *lsdl.render.Render) void {
            renderer.setDrawColor(255, 255, 255, 255);
            for (self.nodes) |node, i| {
                if (i + 1 >= self.nodes.len) {
                    renderer.drawCircle(node.position.x, node.position.y, 2);
                    return;
                }
                const next = self.nodes[i + 1];
                renderer.drawLine(node.position.x, node.position.y, next.position.x, next.position.y);
            }
        }

        pub fn head(self: *Self) *Node {
            return &self.nodes[self.nodes.len - 1];
        }

        pub fn update(self: *Self, dt: f32) void {
            self.simulate(dt);
            var i: usize = 0;
            while (i < 80) : (i += 1) {
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
            for (self.nodes) |*node, i| {
                if (i + 1 >= self.nodes.len) break;
                const next = &self.nodes[i + 1];

                const distance = node.distance(next.*);
                const difference = std.math.absFloat(distance - node_distance);
                var direction = Vector.zero();

                if (distance > node_distance) {
                    direction = node.position.subtract(next.position).normalized();
                } else if (distance < node_distance) {
                    direction = node.position.subtract(next.position).normalized();
                }

                const movement = direction.rescale(difference);

                node.position = node.position.subtract(movement.rescale(0.5));
                next.position = next.position.add(movement.rescale(0.5));

                // const distance = node.distance(next.*);
                // if (distance > node_distance) {
                //     node.position.redistance(next.position, 0.5);
                //     next.position.redistance(node.position, 0.5);
                // }
            }
        }
    };
}
