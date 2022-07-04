const std = @import("std");
const Point = @import("vec.zig").Point;
const Vec = @import("vec.zig").Vec;
const Ray = @import("ray.zig").Ray;
const degToRad = @import("util.zig").degToRad;

pub const Camera = struct {
    orig: Point = Point{},
    lower_left_corner: Point = Point{},
    hori: Vec = Vec{},
    vert: Vec = Vec{},

    pub fn init(self: *Camera, lookfrom: *const Point, lookat: *const Point, vup: *const Vec, vfov: f32, aspect_ratio: f32) void {
        const theta = degToRad(vfov);
        const h = std.math.tan(theta / 2);
        const viewport_height = 2.0 * h;
        const viewport_width = aspect_ratio * viewport_height;

        const w = Vec.subv(&[_]Vec{ lookfrom.*, lookat.* }).unit();
        const u = vup.cross(&w).unit();
        const v = w.cross(&u);

        self.orig = lookfrom.*;
        self.hori = u.mulf(viewport_width);
        self.vert = v.mulf(viewport_height);
        self.lower_left_corner = Vec.subv(&[_]Vec{
            self.orig,
            self.hori.divf(2.0),
            self.vert.divf(2.0),
            w,
        });
    }

    pub fn getRay(self: *const Camera, s: f32, t: f32) Ray {
        return Ray{
            .orig = self.orig,
            .dir = Vec.addv(&[_]Vec{
                self.lower_left_corner,
                self.hori.mulf(s),
                self.vert.mulf(t),
                self.orig.mulf(-1),
            }),
        };
    }
};
