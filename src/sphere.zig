const std = @import("std");
const Point = @import("vec.zig").Point;
const Vec = @import("vec.zig").Vec;
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hittable.zig").HitRecord;

pub const Sphere = struct {
    centre: Point,
    radius: f32,

    pub fn hit(self: *const Sphere, r: *const Ray, t_min: f32, t_max: f32, rec: *HitRecord) bool {
        const oc = Vec.subv(&[_]Vec{ r.orig, self.centre });
        const a = r.dir.lenSqrd();
        const half_b = oc.dot(&r.dir);
        const c = oc.lenSqrd() - self.radius * self.radius;

        const discriminant = half_b * half_b - a * c;
        if (discriminant < 0) {
            return false;
        }
        const sqrtd = std.math.sqrt(discriminant);

        var root = (-half_b - sqrtd) / a;
        if ((root < t_min) or (root > t_max)) {
            root = (-half_b + sqrtd) / a;
            if ((root < t_min) or (root > t_max)) {
                return false;
            }
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        const out_n = Vec.subv(&[_]Vec{ rec.p, self.centre }).divf(self.radius);
        rec.setFaceNormal(r, &out_n);
        rec.n = Vec.subv(&[_]Vec{ rec.p, self.centre }).divf(self.radius);

        return true;
    }
};
