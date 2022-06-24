const std = @import("std");
const Colour = @import("vec.zig").Colour;
const writeColour = @import("util.zig").writeColour;

pub fn main() anyerror!void {
    const image_width = 256;
    const image_height = 256;

    var file = try std.fs.cwd().createFile("img.ppm", .{});
    defer file.close();

    var writer = file.writer();

    try std.fmt.format(writer, "P3\n{} {}\n255\n", .{ image_width, image_height });

    var j: i32 = image_height - 1;
    while (j >= 0) : (j -= 1) {
        std.debug.print("{}/{}\r", .{ image_height - j, image_height });
        var i: i32 = 0;
        while (i != image_width) : (i += 1) {
            const r = @intToFloat(f32, i) / @intToFloat(f32, image_width - 1);
            const g = @intToFloat(f32, j) / @intToFloat(f32, image_height - 1);
            const b: f32 = 0.25;

            const pixel_colour = Colour{
                .x = r,
                .y = g,
                .z = b,
            };

            try writeColour(writer, pixel_colour);
        }
    }
    std.debug.print("\ndone\n", .{});
}
