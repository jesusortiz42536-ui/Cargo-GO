package main

import (
	"fmt"
	"image"
	_ "image/gif"
	_ "image/jpeg"
	_ "image/png"
	"os"
	"path/filepath"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: cargo-go <image-file>")
		fmt.Println("Example: cargo-go image.jpg")
		os.Exit(1)
	}

	imagePath := os.Args[1]
	description, err := describeImage(imagePath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}

	fmt.Println(description)
}

// describeImage analyzes an image file and returns a description
func describeImage(path string) (string, error) {
	// Open the image file
	file, err := os.Open(path)
	if err != nil {
		return "", fmt.Errorf("failed to open image: %w", err)
	}
	defer file.Close()

	// Decode the image
	img, format, err := image.Decode(file)
	if err != nil {
		return "", fmt.Errorf("failed to decode image: %w", err)
	}

	// Get image dimensions
	bounds := img.Bounds()
	width := bounds.Max.X - bounds.Min.X
	height := bounds.Max.Y - bounds.Min.Y

	// Analyze image properties
	aspectRatio := float64(width) / float64(height)
	orientation := getOrientation(aspectRatio)
	
	// Calculate file size
	fileInfo, err := os.Stat(path)
	if err != nil {
		return "", fmt.Errorf("failed to get file info: %w", err)
	}
	fileSize := fileInfo.Size()

	// Build description
	description := fmt.Sprintf("Image Description:\n")
	description += fmt.Sprintf("  Filename: %s\n", filepath.Base(path))
	description += fmt.Sprintf("  Format: %s\n", format)
	description += fmt.Sprintf("  Dimensions: %dx%d pixels\n", width, height)
	description += fmt.Sprintf("  Orientation: %s\n", orientation)
	description += fmt.Sprintf("  Aspect Ratio: %.2f:1\n", aspectRatio)
	description += fmt.Sprintf("  File Size: %s\n", formatFileSize(fileSize))

	return description, nil
}

// getOrientation returns the orientation of the image based on aspect ratio
func getOrientation(aspectRatio float64) string {
	if aspectRatio > 1.1 {
		return "Landscape"
	} else if aspectRatio < 0.9 {
		return "Portrait"
	}
	return "Square"
}

// formatFileSize converts bytes to a human-readable format
func formatFileSize(bytes int64) string {
	const unit = 1024
	if bytes < unit {
		return fmt.Sprintf("%d B", bytes)
	}
	div, exp := int64(unit), 0
	for n := bytes / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.1f %cB", float64(bytes)/float64(div), "KMGTPE"[exp])
}
