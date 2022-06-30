const Vec = @import("vec.zig").Vec;
const Colour = @import("vec.zig").Colour;
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hittable.zig").HitRecord;

pub const Lambertian = struct {
    albedo: Colour,

    pub fn scatter(self: *const Lambertian, r: *const Ray, rec: *HitRecord, att: *Colour, s: *Ray) bool {
        _ = r;
        var s_dir = Vec.addv(&[_]Vec{ rec.n, Vec.randUnit() });
        if (s_dir.isNearZero()) {
            s_dir = rec.n;
        }
        s.* = Ray{ .orig = rec.p, .dir = s_dir };
        att.* = self.albedo;
        return true;
    }
};
