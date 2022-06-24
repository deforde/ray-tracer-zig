const std = @import("std");

pub fn main() anyerror!void {
    const image_width = 256;
    const image_height = 256;

    var file = try std.fs.cwd().createFile("img.ppm", .{});
    defer file.close();

    var writer = file.writer();

    try std.fmt.format(writer, "P3\n{} {}\n255\n", .{ image_width, image_height });

    var j: i32 = image_height - 1;
    while (j >= 0) : (j -= 1) {
        var i: i32 = 0;
        while (i != image_width) : (i += 1) {
            const r = @intToFloat(f32, i) / @intToFloat(f32, image_width - 1);
            const g = @intToFloat(f32, j) / @intToFloat(f32, image_height - 1);
            const b: f32 = 0.25;

            const ir = @floatToInt(i32, 255.999 * r);
            const ig = @floatToInt(i32, 255.999 * g);
            const ib = @floatToInt(i32, 255.999 * b);

            try std.fmt.format(writer, "{} {} {}\n", .{ ir, ig, ib });
        }
    }
}
