# Cargo-GO

A simple Go-based command-line tool for describing images. This tool analyzes image files and provides detailed information about their properties.

## Features

- Supports multiple image formats (JPEG, PNG, GIF)
- Provides image dimensions, orientation, and aspect ratio
- Displays file size in human-readable format
- Simple command-line interface

## Installation

```bash
go build -o cargo-go
```

## Usage

```bash
./cargo-go <image-file>
```

### Example

```bash
./cargo-go photo.jpg
```

Output:
```
Image Description:
  Filename: photo.jpg
  Format: jpeg
  Dimensions: 1920x1080 pixels
  Orientation: Landscape
  Aspect Ratio: 1.78:1
  File Size: 245.3 KB
```

## Requirements

- Go 1.21 or higher