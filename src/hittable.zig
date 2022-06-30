const Point = @import("vec.zig").Point;
const Vec = @import("vec.zig").Vec;
const Ray = @import("ray.zig").Ray;
const Sphere = @import("sphere.zig").Sphere;
const Material = @import("material.zig").Material;

pub const HitRecord = struct {
    p: Point = Point{},
    n: Vec = Vec{},
    m: ?*const Material = null,
    t: f32 = 0.0,
    front_face: bool = false,

    pub fn setFaceNormal(self: *HitRecord, r: *const Ray, out_n: *const Vec) void {
        self.front_face = r.dir.dot(out_n) < 0;
        self.n = if (self.front_face) out_n.* else out_n.mulf(-1.0);
    }
};

pub const Hittable = union(enum) {
    sphere: Sphere,

    pub fn hit(self: *const Hittable, r: *const Ray, t_min: f32, t_max: f32, rec: *HitRecord) bool {
        return switch (self.*) {
            .sphere => |*sphere| blk: {
                break :blk sphere.hit(r, t_min, t_max, rec);
            },
        };
    }
};
