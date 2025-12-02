const std = @import("std");

pub fn readEnvsWithFile(allocator: std.mem.Allocator, path: []const u8) !std.process.EnvMap {
    var env = try std.process.getEnvMap(allocator);

    const file = std.fs.cwd().openFile(path, .{}) catch |err| {
        if (err == std.fs.File.OpenError.FileNotFound) {
            return env;
        } else {
            return err;
        }
    };
    
    defer file.close();

    var buffer: [1024]u8 = undefined;

    var file_reader = file.reader(&buffer);
    const reader = &file_reader.interface;

    while (reader.takeDelimiterExclusive('\n')) |line| {
        const eq_index = std.mem.indexOf(u8, line, "=");
        if (eq_index) |i| {
            const key = line[0..i];
            const value = line[i + 1 ..];
            try env.put(key, value);
        }
    } else |_| {}

    return env;
}
