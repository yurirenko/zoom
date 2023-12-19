const sdl = @import("sdl");
const std = @import("std");
// const glfw = @import("mach-glfw");
// const gl = @import("gl");

// fn errorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
//     std.log.err("glfw: {}: {s}\n", .{ error_code, description });
// }

const resolution_scale = 1;
const screen_width = 160 * resolution_scale;
const screen_height = 120 * resolution_scale;
const pixel_scale = 4 / resolution_scale;
const window_width = screen_width * pixel_scale;
const window_height = screen_height * pixel_scale;

const fps = 24;
const frame_difference = 1000 / fps;

const Time = struct {
    current_frame: u32,
    previous_frame: u32,
};

var t = Time{ .current_frame = 0, .previous_frame = 0 };

const Color = enum {
    yellow,
    yellow_darker,
    green,
    green_darker,
    cyan,
    cyan_darker,
    brown,
    brown_darker,
    background,
    pub fn toRgb(self: Color) sdl.Color {
        return switch (self) {
            .yellow => sdl.Color.rgb(255, 255, 0),
            .yellow_darker => sdl.Color.rgb(160, 160, 0),
            .green => sdl.Color.rgb(0, 255, 0),
            .green_darker => sdl.Color.rgb(0, 160, 0),
            .cyan => sdl.Color.rgb(0, 255, 255),
            .cyan_darker => sdl.Color.rgb(0, 160, 160),
            .brown => sdl.Color.rgb(160, 100, 0),
            .brown_darker => sdl.Color.rgb(110, 50, 0),
            .background => sdl.Color.rgb(0, 60, 130),
        };
    }

    pub fn fromIndex(index: u8) Color {
        return switch (index) {
            0 => Color.yellow,
            1 => Color.yellow_darker,
            2 => Color.green,
            3 => Color.green_darker,
            4 => Color.cyan,
            5 => Color.cyan,
            6 => Color.brown,
            7 => Color.brown_darker,
            else => Color.background,
        };
    }
};

// fn pixel() void {
//     gl.glBegin(gl.GL_POINTS);
//     // gl.glVertexAttribI2i()
// }

// fn pixel(x: i16, y: i16, z: i16) void {
//     gl.cle
// }

fn drawPixel(renderer: *sdl.Renderer, x: i32, y: i32, c: Color) void {
    renderer.setColor(c.toRgb()) catch unreachable;
    renderer.drawPoint(x, y) catch unreachable;
}

var tick: i32 = 0;

fn draw3D(renderer: *sdl.Renderer) void {
    var c: u8 = 0;

    for (0..screen_height / 2) |x| {
        for (0..screen_width / 2) |y| {
            drawPixel(renderer, @intCast(x), @intCast(y), Color.fromIndex(c));
            c += 1;
            if (c > 8) {
                c = 0;
            }
        }
    }
    tick += 1;
    if (tick > 20) {
        tick = 0;
    }

    drawPixel(renderer, screen_width / 2, screen_height / 2 + tick, Color.green);
}

fn display(renderer: *sdl.Renderer) void {
    if (t.current_frame - t.previous_frame >= frame_difference) {
        renderer.setColorRGB(0, 0, 0) catch unreachable;
        renderer.clear() catch unreachable;
        draw3D(renderer);
        renderer.present();

        t.previous_frame = t.current_frame;
    }

    t.current_frame = sdl.getTicks();
}

pub fn main() !void {
    // glfw.setErrorCallback(errorCallback);
    try sdl.init(.{
        .video = true,
        .events = true,
        .audio = true,
    });
    defer sdl.quit();

    var window = try sdl.createWindow(
        "SDL.zig Basic Demo",
        .{ .centered = {} },
        .{ .centered = {} },
        window_width,
        window_height,
        .{ .vis = .shown, .allow_high_dpi = false },
    );
    defer window.destroy();

    var renderer = try sdl.createRenderer(window, null, .{ .accelerated = true });
    defer renderer.destroy();

    renderer.setScale(pixel_scale, pixel_scale) catch unreachable;

    mainLoop: while (true) {
        while (sdl.pollEvent()) |ev| {
            switch (ev) {
                .quit => {
                    break :mainLoop;
                },
                .key_down => |key| {
                    switch (key.scancode) {
                        .escape => break :mainLoop,
                        else => std.log.info("key pressed: {}\n", .{key.scancode}),
                    }
                },

                else => {},
            }
        }

        // try renderer.setColorRGB(0, 0, 0);
        // try renderer.clear();

        display(&renderer);
        // draw3D(&renderer);
        // try renderer.drawRect(sdl.Rectangle{
        //     .x = screen_width / 2,
        //     .y = screen_height / 2,
        //     .width = 100,
        //     .height = 50,
        // });

    }

    // pixel();
    // if (!glfw.init(.{})) {
    //     std.log.err("failed to initialize GLFW: {?s}", .{glfw.getErrorString()});
    //     std.process.exit(1);
    // }
    // defer glfw.terminate();

    // // Create our window
    // const window = glfw.Window.create(640, 480, "Hello, mach-glfw!", null, null, .{}) orelse {
    //     std.log.err("failed to create GLFW window: {?s}", .{glfw.getErrorString()});
    //     std.process.exit(1);
    // };
    // defer window.destroy();

    // // Wait for the user to close the window.
    // while (!window.shouldClose()) {
    //     window.swapBuffers();
    //     glfw.pollEvents();
    // }
}
