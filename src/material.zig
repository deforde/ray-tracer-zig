const Colour = @import("vec.zig").Colour;
const Ray = @import("ray.zig").Ray;
const HitRecord = @import("hittable.zig").HitRecord;
const Lambertian = @import("lambertian.zig").Lambertian;
const Metal = @import("metal.zig").Metal;
const Dielectric = @import("dielectric.zig").Dielectric;

pub const Material = union(enum) {
    lambertian: Lambertian,
    metal: Metal,
    dielectric: Dielectric,

    pub fn scatter(self: *const Material, r: *const Ray, rec: *HitRecord, att: *Colour, s: *Ray) bool {
        return switch (self.*) {
            .lambertian => |*lambertian| blk: {
                break :blk lambertian.scatter(r, rec, att, s);
            },
            .metal => |*metal| blk: {
                break :blk metal.scatter(r, rec, att, s);
            },
            .dielectric => |*dielectric| blk: {
                break :blk dielectric.scatter(r, rec, att, s);
            },
        };
    }
};
