const Point = @import("vec.zig").Point;
const Vec = @import("vec.zig").Vec;
const Ray = @import("ray.zig").Ray;

pub const Camera = struct {
    orig: Point = Point{},
    lower_left_corner: Point = Point{},
    hori: Vec = Vec{},
    vert: Vec = Vec{},

    pub fn init(self: *Camera) void {
        const aspect_ratio = 16.0 / 9.0;
        const viewport_height = 2.0;
        const viewport_width = aspect_ratio * viewport_height;
        const focal_len = 1.0;

        self.orig = Point{};
        self.hori = Vec{ .x = viewport_width };
        self.vert = Vec{ .y = viewport_height };
        self.lower_left_corner = Vec.subv(&[_]Vec{
            self.orig,
            self.hori.divf(2.0),
            self.vert.divf(2.0),
            Vec{ .z = focal_len },
        });
    }

    pub fn getRay(self: *const Camera, u: f32, v: f32) Ray {
        return Ray{
            .orig = self.orig,
            .dir = Vec.addv(&[_]Vec{
                self.lower_left_corner,
                self.hori.mulf(u),
                self.vert.mulf(v),
                self.orig.mulf(-1),
            }),
        };
    }
};
