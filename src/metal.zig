const Vec = @import("vec.zig").Vec;
const Colour = @import("vec.zig").Colour;
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hittable.zig").HitRecord;

pub const Metal = struct {
    albedo: Colour,
    fuzz: f32,

    pub fn scatter(self: *const Metal, r: *const Ray, rec: *HitRecord, att: *Colour, s: *Ray) bool {
        const ref = Vec.reflect(&r.dir.unit(), &rec.n);
        s.* = Ray{ .orig = rec.p, .dir = Vec.addv(&[_]Vec{ ref, Vec.randUnitSphere().mulf(self.fuzz) }) };
        att.* = self.albedo;
        return (s.dir.dot(&rec.n) > 0.0);
    }
};
