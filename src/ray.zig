const Vec = @import("vec.zig").Vec;
const Point = @import("vec.zig").Point;

pub const Ray = struct {
    orig: Point,
    dir: Vec,

    // pub fn at(self: *Ray, t: f32) Point {
    // }
};
