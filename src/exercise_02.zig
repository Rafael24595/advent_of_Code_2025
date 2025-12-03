const std = @import("std");
const helper = @import("helper.zig");
const utils = @import("utils.zig");

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
        const matches = try findGeneralizedRepunitsWithDocs(alloc, pair.a, pair.b, fix_blocks);

        helper.printExp("\nRange  : {d} - {d}\n", .{ pair.a, pair.b });
        helper.printExp("Matches: {any}\n\n", .{matches});

        for (matches) |match| {
            total += match;
        }

        alloc.free(matches);
    }

    const end_ms = std.time.milliTimestamp();
    
    const time = try utils.formatTime(alloc, end_ms - start_ms);
    defer alloc.free(time);

    std.debug.print("Total: {d}\n", .{total});
    std.debug.print("Time: {s}\n\n", .{time});
}

fn parse_input(alloc: std.mem.Allocator) ![]helper.Pair {
    var file = try std.fs.cwd().openFile("src/source/source_02_00.txt", .{});
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

fn _findGeneralizedRepunitsClean(alloc: std.mem.Allocator, min: usize, max: usize, fix_blocks: ?usize) ![]usize {
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
                if (N > max) {
                    break;
                }

                if (N >= min and cache.get(N) == null) {
                    try cache.put(N, undefined);
                    try list.append(alloc, N);
                }
            }
        }
    }

    return list.items;
}

fn findGeneralizedRepunitsWithDocs(alloc: std.mem.Allocator, min: usize, max: usize, fix_blocks: ?usize) ![]usize {
    var cache = std.AutoHashMap(usize, void).init(alloc);
    defer cache.deinit();

    var list = try std.ArrayList(usize).initCapacity(alloc, 0);

    helper.printExp("--- Explanation -----------------------------------------------\n\n", .{});
    helper.printExp("Searching for generalized repunits within the range [{d}, {d}].\n\n", .{ min, max });

    const minDigits = std.math.log10(min) + 1;
    const maxDigits = std.math.log10(max) + 1;

    helper.printExp("Minimum digit count in range : {d}.\n", .{minDigits});
    helper.printExp("Maximum digit count in range : {d}.\n", .{maxDigits});

    helper.printExp("Restriction on number of blocks (optional): {any}.\n", .{fix_blocks});

    for (minDigits..maxDigits + 1) |size| {
        helper.printExp("\nEvaluating numbers with {d} digits:\n", .{size});

        for (1..(size / 2) + 1) |chunk| {
            helper.printExp("\n Trying chunk size = {d} digits:\n\n", .{chunk});

            if (size % chunk != 0) {
                helper.printExp(" * {d} does not divide {d} exactly. cannot form a repeated pattern. Skipping.\n", .{ chunk, size });
                continue;
            }

            const blocks = size / chunk;

            helper.printExp(" Number of repetitions (blocks) = size / chunk = {d}.\n", .{blocks});

            if (fix_blocks != null and blocks != fix_blocks) {
                helper.printExp(" * Number of blocks does not match the required restriction ({d}). Skipping\n", .{fix_blocks.?});
                continue;
            }

            helper.printExp(" Building factor: summing powers of 10 spaced every {d} digits.\n", .{chunk});

            var factor: usize = 0;
            for (0..blocks) |i| {
                factor += std.math.pow(usize, 10, i * chunk);
            }

            helper.printExp(" Resulting factor template: {d}\n", .{factor});

            const startA: usize = std.math.pow(usize, 10, chunk - 1);
            const endA: usize = std.math.pow(usize, 10, chunk) - 1;

            helper.printExp("\n Evaluating all chunk values A in the range [{d}, {d}] (all {d}-digit numbers):\n", .{ startA, endA, chunk });

            for (startA..endA + 1) |A| {
                const N = A * factor;

                helper.printExp("\n  Calculating N: A ({d}) multiplied by factor ({d}).\n", .{ A, factor });

                if (N > max) {
                    helper.printExp("  N = {d} exceeds the upper limit ({d}). Stopping iteration for this chunk (future values will be larger).\n", .{ N, max });
                    break;
                }

                if (cache.get(N) != null) {
                    helper.printExp("  N = {d} already processed earlier. Skipping.\n", .{N});
                    continue;
                }

                if (N >= min and N <= max) {
                    try cache.put(N, undefined);
                    try list.append(alloc, N);

                    helper.printExp("  N = {d} is within [{d}, {d}]. Added to results.\n", .{ N, min, max });
                } else {
                    helper.printExp("  N = {d} is outside [{d}, {d}]. Discarded.\n", .{ N, min, max });
                }
            }
        }
    }

    helper.printExp("\n--- ----------- -----------------------------------------------\n\n", .{});

    return list.items;
}
