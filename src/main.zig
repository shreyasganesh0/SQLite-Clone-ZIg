const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 3) {
        try std.io.getStdErr().writer().print("Usage: {s} <database_file_path> <command>\n", .{args[0]});
        return;
    }

    const database_file_path: []const u8 = args[1];
    const command: []const u8 = args[2];

    if (std.mem.eql(u8, command, ".dbinfo")) {
        var file = try std.fs.cwd().openFile(database_file_path, .{});
        defer file.close();

        var buf: [2]u8 = undefined;
        _ = try file.seekTo(16);
        _ = try file.read(&buf);
        const page_size = std.mem.readInt(u16, &buf, .big);
        try std.io.getStdOut().writer().print("database page size: {}\n", .{page_size});
        const file_info = try file.stat();
        const file_size = file_info.size;
        const page_count = file_size / page_size - 1;
        try std.io.getStdOut().writer().print("number of tables: {}\n", .{page_count});
    }
}
