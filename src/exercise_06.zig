const std = @import("std");
const helper = @import("helper.zig");
const utils = @import("utils.zig");

const FilePath = "src/source/source_06_01.txt";

pub fn execute_01() !void {
    std.debug.print("\n------------------", .{});
    std.debug.print("\n|  Exercise 6.1  |", .{});
    std.debug.print("\n------------------\n\n", .{});

    const alloc = std.heap.page_allocator;

    const start_ms = std.time.milliTimestamp();
    const result = try parseInput_01(alloc);
    defer alloc.free(result.@"0");
    defer alloc.free(result.@"1");

    helper.printExp("Matrix: {any}\n", .{result.@"0"});
    helper.printExp("Symbols: {any}\n", .{result.@"1"});

    try operate(result.@"0", result.@"1");

    const end_ms = std.time.milliTimestamp();

    const time = try utils.millisecondsToTime(alloc, end_ms - start_ms, null);
    defer alloc.free(time);

    std.debug.print("Time: {s}\n\n", .{time});
}

pub fn execute_02() !void {
    std.debug.print("\n------------------", .{});
    std.debug.print("\n|  Exercise 6.2  |", .{});
    std.debug.print("\n------------------\n\n", .{});

    const alloc = std.heap.page_allocator;

    const start_ms = std.time.milliTimestamp();
    const result = try parseInput_02(alloc);
    defer alloc.free(result.@"0");
    defer alloc.free(result.@"1");

    helper.printExp("Matrix: {any}\n", .{result.@"0"});
    helper.printExp("Symbols: {any}\n", .{result.@"1"});

    try operate(result.@"0", result.@"1");

    const end_ms = std.time.milliTimestamp();

    const time = try utils.millisecondsToTime(alloc, end_ms - start_ms, null);
    defer alloc.free(time);

    std.debug.print("Time: {s}\n\n", .{time});
}

pub fn parseInput_01(alloc: std.mem.Allocator) !struct { [][]i64, []u8 } {
    var lines = try helper.parseInputRawLines(alloc, FilePath);

    const symbols = try parseInput_01_Symbols(alloc, lines[lines.len - 1]);
    const matrix = try parseInput_01_Matrix(alloc, lines[0 .. lines.len - 1]);

    return .{ matrix, symbols };
}

pub fn parseInput_01_Symbols(alloc: std.mem.Allocator, line: []u8) ![]u8 {
    var symbols = try std.ArrayList(u8).initCapacity(alloc, 0);

    var iter = std.mem.splitScalar(u8, line, ' ');
    while (iter.next()) |symbol| {
        const clean_symbol = std.mem.trim(u8, symbol, " \n\t\r");
        if (clean_symbol.len == 0 or
            clean_symbol[0] != '+' and
            clean_symbol[0] != '*')
        {
            continue;
        }

        try symbols.append(alloc, clean_symbol[0]);
    }

    return symbols.items;
}

pub fn parseInput_01_Matrix(alloc: std.mem.Allocator, lines: [][]u8) ![][]i64 {
    var matrix = try std.ArrayList([]i64).initCapacity(alloc, 0);

    for (lines) |line| {
        var row = try std.ArrayList(i64).initCapacity(alloc, 0);

        var iter = std.mem.splitScalar(u8, line, ' ');
        while (iter.next()) |str_number| {
            const clean_number = std.mem.trim(u8, str_number, " \n\t\r");
            if (clean_number.len == 0) {
                continue;
            }

            const number = try std.fmt.parseInt(i64, clean_number, 10);
            try row.append(alloc, number);
        }

        if (row.items.len > 0) {
            try matrix.append(alloc, row.items);
        }
    }

    return try utils.transposeMatrix(alloc, matrix.items);
}

pub fn parseInput_02(alloc: std.mem.Allocator) !struct { [][]i64, []u8 } {
    var lines = try helper.parseInputRawLines(alloc, FilePath);

    var symbols = try std.ArrayList(u8).initCapacity(alloc, 0);
    var matrix = try std.ArrayList([]i64).initCapacity(alloc, 0);

    const symbol_line = lines[lines.len - 1];
    lines = lines[0 .. lines.len - 1];

    var position: ?usize = 0;
    while (position != null) {
        const new_position = std.mem.indexOfNonePos(u8, symbol_line, position.? + 1, " ");

        var fix_position = new_position;
        if (new_position == null) {
            fix_position = symbol_line.len;
        }

        const numbers = try parseInput_02_Chunk(alloc, position.?, fix_position.?, lines);
        if (numbers.len > 0) {
            try matrix.append(alloc, numbers);
        }

        if (symbol_line[position.?] == '+' or symbol_line[position.?] == '*') {
            try symbols.append(alloc, symbol_line[position.?]);
        }

        position = new_position;
    }

    return .{ matrix.items, symbols.items };
}

pub fn parseInput_02_Chunk(alloc: std.mem.Allocator, init: usize, end: usize, lines: [][]u8) ![]i64 {
    var row = try std.ArrayList(i64).initCapacity(alloc, 0);

    for (init..end) |i| {
        var str_number = try alloc.alloc(u8, lines.len);

        var count: usize = 0;
        for (lines) |line| {
            str_number[count] = line[i];
            count += 1;
        }

        const clean_number = std.mem.trim(u8, str_number, " \n\t\r");
        if (clean_number.len == 0) {
            continue;
        }

        const number = try std.fmt.parseInt(i64, clean_number, 10);
        try row.append(alloc, number);
    }

    return row.items;
}

fn operate(matrix: [][]i64, symbols: []u8) !void {
    var total: i64 = 0;
    for (symbols, 0..) |symbol, i| {
        total += switch (symbol) {
            '+' => add(matrix[i]),
            '*' => mul(matrix[i]),
            else => 0,
        };
    }

    std.debug.print("\nTotal: {d}\n", .{total});
}

fn add(row: []i64) i64 {
    var total: i64 = 0;
    for (row) |cell| {
        total += cell;
    }
    return total;
}

fn mul(row: []i64) i64 {
    var total: i64 = 1;
    for (row) |cell| {
        total *= cell;
    }
    return total;
}
