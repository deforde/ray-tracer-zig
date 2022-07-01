const Vec = @import("vec.zig").Vec;
const Colour = @import("vec.zig").Colour;
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hittable.zig").HitRecord;

pub const Dielectric = struct {
    refr_idx: f32,

    pub fn scatter(self: *const Dielectric, r: *const Ray, rec: *HitRecord, att: *Colour, s: *Ray) bool {
        att.* = Colour{ .x = 1, .y = 1, .z = 1 };
        const refr_ratio = if (rec.front_face) 1 / self.refr_idx else self.refr_idx;

        const unit_dir = r.dir.unit();
        const refr = unit_dir.refract(&rec.n, refr_ratio);

        s.* = Ray{ .orig = rec.p, .dir = refr };
        return true;
    }
};
