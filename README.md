# Cargo-GO

A simple and efficient image description tool built with Rust. This tool analyzes images and provides detailed descriptions including format, dimensions, color characteristics, and more.

## Features

- 🖼️ Support for multiple image formats (PNG, JPEG, GIF, BMP, WebP)
- 📊 Detailed image analysis including:
  - Image dimensions and resolution
  - Format detection
  - Color type and bit depth
  - Brightness analysis
  - Dominant color detection
  - Orientation detection (portrait/landscape/square)
- ⚡ Fast and efficient processing
- 🛠️ Simple command-line interface

## Installation

Make sure you have Rust installed. If not, install it from [rustup.rs](https://rustup.rs/).

```bash
cargo build --release
```

## Usage

```bash
cargo run -- <path-to-image>
```

Or, after building:

```bash
./target/release/cargo-go <path-to-image>
```

### Example

```bash
cargo run -- examples/test_image.png
```

Output:
```
Image Description:
==================

Format: Png
Dimensions: 400x300 pixels (0.12 MP)
Orientation: landscape
Color Type: Rgb8
Average Brightness: 57.6%

Color Analysis:
  - Dominant color tone: blue
  - Overall brightness: bright (57.6%)
  - Average RGB: (100, 150, 255)
```

## Supported Image Formats

- PNG (.png)
- JPEG (.jpg, .jpeg)
- GIF (.gif)
- BMP (.bmp)
- WebP (.webp)

## How It Works

The tool analyzes images by:

1. Loading the image using the `image` crate
2. Extracting basic metadata (dimensions, format, color type)
3. Sampling pixels throughout the image
4. Computing color statistics and brightness levels
5. Determining dominant color tones and orientation

## Development

### Building

```bash
cargo build
```

### Testing

```bash
# Test with the example image
cargo run -- examples/test_image.png

# Test with your own images
cargo run -- path/to/your/image.jpg
```

## Dependencies

- `image` - Image processing library
- `clap` - Command-line argument parsing

## License

This project is open source and available under the MIT License.