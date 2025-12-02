const std = @import("std");
const helper = @import("helper.zig");

pub fn execute_01() !void {
    std.debug.print("\n------------------", .{});
    std.debug.print("\n|  Exercise 2.1  |", .{});
    std.debug.print("\n------------------\n\n", .{});

    const alloc = std.heap.page_allocator;

    const ranges = try parse_input(alloc);
    defer alloc.free(ranges);

    try execute_blocks(alloc, ranges, 2);
}

pub fn execute_02() !void {
    std.debug.print("\n------------------", .{});
    std.debug.print("\n|  Exercise 2.2  |", .{});
    std.debug.print("\n------------------\n\n", .{});

    const alloc = std.heap.page_allocator;

    const ranges = try parse_input(alloc);
    defer alloc.free(ranges);

    try execute_blocks(alloc, ranges, null);
}

pub fn execute_blocks(alloc: std.mem.Allocator, ranges: []helper.Pair, fix_blocks: ?usize) !void {
    const start_ms = std.time.milliTimestamp();

    var total: usize = 0;
    for (ranges) |pair| {
        const matches = try findGeneralizedRepunits(alloc, pair.a, pair.b, fix_blocks);

        std.debug.print("\nRange  : {d} - {d}\n", .{ pair.a, pair.b });
        std.debug.print("Matches: {any}\n", .{matches});

        for (matches) |match| {
            total += match;
        }

        alloc.free(matches);
    }

    const end_ms = std.time.milliTimestamp();
    std.debug.print("\nTotal: {d}\n", .{total});
    std.debug.print("Time: {d}ms\n\n", .{end_ms - start_ms});
}

fn parse_input(alloc: std.mem.Allocator) ![]helper.Pair {
    var file = try std.fs.cwd().openFile("src/source/source_02_01.txt", .{});
    defer file.close();

    var buffer: [1024]u8 = undefined;

    var file_reader = file.reader(&buffer);
    const reader = &file_reader.interface;

    var list = try std.ArrayList(helper.Pair).initCapacity(alloc, 0);

    while (reader.takeDelimiterExclusive(',')) |line| {
        const eq_index = std.mem.indexOf(u8, line, "-");
        if (eq_index == null) {
            continue;
        }

        const first_slice = std.mem.trim(u8, line[0..eq_index.?], " \n\t\r");
        const first = try std.fmt.parseInt(usize, first_slice, 10);

        const last_slice = std.mem.trim(u8, line[eq_index.? + 1 ..], " \n\t\r");
        const last = try std.fmt.parseInt(usize, last_slice, 10);

        try list.append(alloc, .{ .a = first, .b = last });
    } else |_| {}

    return list.items;
}

fn findGeneralizedRepunits(alloc: std.mem.Allocator, min: usize, max: usize, fix_blocks: ?usize) ![]usize {
    var cache = std.AutoHashMap(usize, void).init(alloc);
    defer cache.deinit();

    var list = try std.ArrayList(usize).initCapacity(alloc, 0);

    const minDigits = std.math.log10(min) + 1;
    const maxDigits = std.math.log10(max) + 1;

    for (minDigits..maxDigits + 1) |size| {
        for (1..(size / 2) + 1) |chunk| {
            if (size % chunk != 0) {
                continue;
            }

            const blocks = size / chunk;
            if (fix_blocks != null and blocks != fix_blocks) {
                continue;
            }

            var factor: usize = 0;
            for (0..blocks) |i| {
                factor += std.math.pow(usize, 10, i * chunk);
            }

            const startA: usize = std.math.pow(usize, 10, chunk - 1);
            const endA: usize = std.math.pow(usize, 10, chunk) - 1;

            for (startA..endA + 1) |A| {
                const N = A * factor;
                if (N >= min and N <= max and cache.get(N) == null) {
                    try cache.put(N, undefined);
                    try list.append(alloc, N);
                }
            }
        }
    }

    return list.items;
}
