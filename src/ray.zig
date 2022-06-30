const Vec = @import("vec.zig").Vec;
const Point = @import("vec.zig").Point;

pub const Ray = struct {
    orig: Point = Point{},
    dir: Vec = Vec{},

    pub fn at(self: *const Ray, t: f32) Point {
        return Vec.addv(&[_]Vec{ self.orig, self.dir.mulf(t) });
    }
};
