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
    w: Vec = Vec{},
    u: Vec = Vec{},
    v: Vec = Vec{},
    lens_radius: f32 = 0,

    pub fn init(self: *Camera, lookfrom: *const Point, lookat: *const Point, vup: *const Vec, vfov: f32, aspect_ratio: f32, aperture: f32, focus_dist: f32) void {
        const theta = degToRad(vfov);
        const h = std.math.tan(theta / 2);
        const viewport_height = 2.0 * h;
        const viewport_width = aspect_ratio * viewport_height;

        self.w = Vec.subv(&[_]Vec{ lookfrom.*, lookat.* }).unit();
        self.u = vup.cross(&self.w).unit();
        self.v = self.w.cross(&self.u);

        self.orig = lookfrom.*;
        self.hori = self.u.mulf(viewport_width * focus_dist);
        self.vert = self.v.mulf(viewport_height * focus_dist);
        self.lower_left_corner = Vec.subv(&[_]Vec{
            self.orig,
            self.hori.divf(2.0),
            self.vert.divf(2.0),
            self.w.mulf(focus_dist),
        });

        self.lens_radius = aperture / 2;
    }

    pub fn getRay(self: *const Camera, s: f32, t: f32) Ray {
        const rd = Vec.randUnitDisk().mulf(self.lens_radius);
        const offset = Vec.addv(&[_]Vec{ self.u.mulf(rd.x), self.v.mulf(rd.y) });
        return Ray{
            .orig = Vec.addv(&[_]Vec{ self.orig, offset }),
            .dir = Vec.addv(&[_]Vec{
                self.lower_left_corner,
                self.hori.mulf(s),
                self.vert.mulf(t),
                self.orig.mulf(-1),
                offset.mulf(-1),
            }),
        };
    }
};
