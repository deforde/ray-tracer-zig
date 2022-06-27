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
const randomf = @import("util.zig").randomf;
const writeColour = @import("util.zig").writeColour;

fn rayColour(r: *const Ray, world: *const HittableList) Colour {
    var rec = HitRecord{};
    if (world.hit(r, 0.0, std.math.floatMax(f32), &rec)) {
        return Vec.addv(&[_]Vec{ rec.n, Colour{ .x = 1, .y = 1, .z = 1 } }).mulf(0.5);
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
    const aspect_ratio = 16.0 / 9.0;
    const image_width = 400;
    const image_height = @floatToInt(i32, @intToFloat(f32, image_width) / aspect_ratio);
    const samples_per_pixel = 100;

    // World
    var world = HittableList{};
    const sphere_1 = Hittable{ .sphere = Sphere{ .centre = Point{ .z = -1 }, .radius = 0.5 } };
    const sphere_2 = Hittable{ .sphere = Sphere{ .centre = Point{ .y = -100.5, .z = -1 }, .radius = 100 } };
    world.add(&sphere_1);
    world.add(&sphere_2);

    // Camera
    var cam = Camera{};
    cam.init();

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
                const u = (@intToFloat(f32, i) + randomf()) / @intToFloat(f32, image_width - 1);
                const v = (@intToFloat(f32, j) + randomf()) / @intToFloat(f32, image_height - 1);
                const r = cam.getRay(u, v);
                pixel_colour = Vec.addv(&[_]Vec{
                    pixel_colour,
                    rayColour(&r, &world),
                });
            }

            try writeColour(writer, &pixel_colour, samples_per_pixel);
        }
    }
    std.debug.print("\ndone\n", .{});
}
