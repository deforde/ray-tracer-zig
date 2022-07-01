const std = @import("std");
const Vec = @import("vec.zig").Vec;
const Colour = @import("vec.zig").Colour;
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hittable.zig").HitRecord;

pub const Dielectric = struct {
    refr_idx: f32,

    pub fn scatter(self: *const Dielectric, r: *const Ray, rec: *HitRecord, att: *Colour, s: *Ray) bool {
        att.* = Colour{ .x = 1, .y = 1, .z = 1 };
        const refr_ratio = if (rec.front_face) 1 / self.refr_idx else self.refr_idx;

        const unit_dir = r.dir.unit().mulf(-1);
        const cos_theta = std.math.min(rec.n.dot(&unit_dir), 1);
        const sin_theta = std.math.sqrt(1 - cos_theta * cos_theta);

        const can_refr = refr_ratio * sin_theta <= 1;
        const dir = blk: {
            if (can_refr) {
                break :blk unit_dir.refract(&rec.n, refr_ratio);
            }
            break :blk unit_dir.reflect(&rec.n);
        };

        s.* = Ray{ .orig = rec.p, .dir = dir };
        return true;
    }
};
