const std = @import("std");
const Colour = @import("vec.zig").Colour;
const Point = @import("vec.zig").Point;
const Vec = @import("vec.zig").Vec;
const Ray = @import("ray.zig").Ray;
const Hittable = @import("hittable.zig").Hittable;
const HitRecord = @import("hittable.zig").HitRecord;
const HittableList = @import("hittable_list.zig").HittableList;
const Sphere = @import("sphere.zig").Sphere;
const Camera = @import("camera.zig").Camera;
const Material = @import("material.zig").Material;
const Lambertian = @import("lambertian.zig").Lambertian;
const Metal = @import("metal.zig").Metal;
const Dielectric = @import("dielectric.zig").Dielectric;
const randf = @import("util.zig").randf;
const randfmm = @import("util.zig").randfmm;
const writeColour = @import("util.zig").writeColour;

const MAX_NUM_RANDOM_SPHERES = 23 * 23;
const TOTAL_NUM_OBJECTS = MAX_NUM_RANDOM_SPHERES + 4;
const RANDOM_SPHERE_IDX_MAX = (@floatToInt(i32, std.math.sqrt(MAX_NUM_RANDOM_SPHERES)) - 1) / 2;
const RANDOM_SPHERE_IDX_MIN = -RANDOM_SPHERE_IDX_MAX;

fn rayColour(r: *const Ray, world: *const HittableList, depth: i32) anyerror!Colour {
    if (depth <= 0) {
        return Colour{};
    }

    var rec = HitRecord{};
    if (world.hit(r, 0.001, std.math.floatMax(f32), &rec)) {
        var scattered = Ray{};
        var att = Colour{};
        if (rec.m.?.scatter(r, &rec, &att, &scattered)) {
            return Vec.mulv(&[_]Vec{ att, try rayColour(&scattered, world, depth - 1) });
        }
        return Colour{};
    }
    const unit_dir = r.dir.unit();
    const t = 0.5 * (unit_dir.y + 1.0);
    const a = Colour{
        .x = 1.0,
        .y = 1.0,
        .z = 1.0,
    };
    const b = Colour{
        .x = 0.5,
        .y = 0.7,
        .z = 1.0,
    };
    return Vec.addv(&[_]Vec{
        a.mulf(1.0 - t),
        b.mulf(t),
    });
}

fn hitSphere(centre: *const Point, radius: f32, r: *const Ray) f32 {
    const oc = Vec.subv(&[_]Vec{ r.orig, centre.* });
    const a = r.dir.lenSqrd();
    const half_b = oc.dot(&r.dir);
    const c = oc.lenSqrd() - radius * radius;
    const discriminant = half_b * half_b - a * c;
    if (discriminant < 0.0) {
        return -1.0;
    }
    return (-half_b - std.math.sqrt(discriminant)) / a;
}

pub fn main() anyerror!void {
    // Image
    const aspect_ratio = 3.0 / 2.0;
    const image_width = 400;
    const image_height = @floatToInt(i32, @intToFloat(f32, image_width) / aspect_ratio);
    const samples_per_pixel = 100;
    const max_depth = 50;
    const vfov = 20.0;
    const lookfrom = Point{ .x = 13, .y = 2, .z = 3 };
    const lookat = Point{};
    const vup = Vec{ .y = 1 };
    const dist_to_focus = 10.0;
    const aperture = 0.1;

    // World
    var world = HittableList{};
    var materials: [MAX_NUM_RANDOM_SPHERES]Material = undefined;
    var n_materials: usize = 0;
    const mat_gnd = Material{ .lambertian = Lambertian{ .albedo = Colour{ .x = 0.5, .y = 0.5, .z = 0.5 } } };
    const sphere_gnd = Hittable{ .sphere = Sphere{ .centre = Point{ .y = -1000 }, .radius = 1000, .mat = &mat_gnd } };
    world.add(&sphere_gnd);
    var a: i32 = RANDOM_SPHERE_IDX_MIN;
    while (a < RANDOM_SPHERE_IDX_MAX) : (a += 1) {
        var b: i32 = RANDOM_SPHERE_IDX_MIN;
        while (b < RANDOM_SPHERE_IDX_MAX) : (b += 1) {
            const choose_mat = randf();
            const centre = Point{ .x = @intToFloat(f32, a) + 0.9 * randf(), .y = 0.2, .z = @intToFloat(f32, b) + 0.9 * randf() };

            if (Vec.subv(&[_]Vec{ centre, Point{ .x = 4, .y = 0.2 } }).len() > 0.9) {
                if (choose_mat < 0.8) {
                    const albedo = Vec.mulv(&[_]Vec{ Vec.rand(), Vec.rand() });
                    materials[n_materials] = Material{ .lambertian = Lambertian{ .albedo = albedo } };
                } else if (choose_mat < 0.96) {
                    const albedo = Vec.randmm(0.5, 1);
                    const fuzz = randfmm(0, 0.5);
                    materials[n_materials] = Material{ .metal = Metal{ .albedo = albedo, .fuzz = fuzz } };
                } else {
                    materials[n_materials] = Material{ .dielectric = Dielectric{ .refr_idx = 1.5 } };
                }
                const sphere = Hittable{ .sphere = Sphere{ .centre = centre, .radius = 0.2, .mat = &materials[n_materials] } };
                n_materials += 1;
                world.add(&sphere);
            }
        }
    }
    const mat1 = Material{ .dielectric = Dielectric{ .refr_idx = 1.5 } };
    const mat2 = Material{ .lambertian = Lambertian{ .albedo = Colour{ .x = 0.4, .y = 0.2, .z = 0.1 } } };
    const mat3 = Material{ .metal = Metal{ .albedo = Colour{ .x = 0.7, .y = 0.6, .z = 0.5 }, .fuzz = 0.0 } };
    const sphere1 = Hittable{ .sphere = Sphere{ .centre = Point{ .y = 1 }, .radius = 1, .mat = &mat1 } };
    const sphere2 = Hittable{ .sphere = Sphere{ .centre = Point{ .x = -4, .y = 1 }, .radius = 1, .mat = &mat2 } };
    const sphere3 = Hittable{ .sphere = Sphere{ .centre = Point{ .x = 4, .y = 1 }, .radius = 1, .mat = &mat3 } };
    world.add(&sphere1);
    world.add(&sphere2);
    world.add(&sphere3);

    // Camera
    var cam = Camera{};
    cam.init(&lookfrom, &lookat, &vup, vfov, aspect_ratio, aperture, dist_to_focus);

    var file = try std.fs.cwd().createFile("img.ppm", .{});
    defer file.close();

    var writer = file.writer();

    try std.fmt.format(writer, "P3\n{} {}\n255\n", .{ image_width, image_height });

    var j: i32 = image_height - 1;
    while (j >= 0) : (j -= 1) {
        std.debug.print("{}/{}\r", .{ image_height - j, image_height });
        var i: i32 = 0;
        while (i != image_width) : (i += 1) {
            var pixel_colour = Colour{};
            var s: usize = 0;
            while (s < samples_per_pixel) : (s += 1) {
                const u = (@intToFloat(f32, i) + randf()) / @intToFloat(f32, image_width - 1);
                const v = (@intToFloat(f32, j) + randf()) / @intToFloat(f32, image_height - 1);
                const r = cam.getRay(u, v);
                pixel_colour = Vec.addv(&[_]Vec{
                    pixel_colour,
                    try rayColour(&r, &world, max_depth),
                });
            }

            try writeColour(writer, &pixel_colour, samples_per_pixel);
        }
    }
    std.debug.print("\ndone\n", .{});
}
