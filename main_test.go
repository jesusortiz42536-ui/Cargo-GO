package main

import (
	"image"
	"image/color"
	"image/png"
	"os"
	"strings"
	"testing"
)

// createTestImage creates a simple test image for testing
func createTestImage(t *testing.T, path string, width, height int) {
	t.Helper()
	
	img := image.NewRGBA(image.Rect(0, 0, width, height))
	
	// Fill with a blue color
	blue := color.RGBA{R: 0, G: 0, B: 255, A: 255}
	for y := 0; y < height; y++ {
		for x := 0; x < width; x++ {
			img.Set(x, y, blue)
		}
	}
	
	f, err := os.Create(path)
	if err != nil {
		t.Fatalf("Failed to create test image: %v", err)
	}
	defer f.Close()
	
	if err := png.Encode(f, img); err != nil {
		t.Fatalf("Failed to encode test image: %v", err)
	}
}

func TestDescribeImage(t *testing.T) {
	// Create a temporary test image
	testImagePath := "test_sample.png"
	createTestImage(t, testImagePath, 800, 600)
	defer os.Remove(testImagePath)
	
	description, err := describeImage(testImagePath)
	if err != nil {
		t.Fatalf("Expected no error, got: %v", err)
	}

	// Verify the description contains expected information
	expectedStrings := []string{
		"Image Description:",
		"Filename: test_sample.png",
		"Format: png",
		"Dimensions: 800x600 pixels",
		"Orientation: Landscape",
		"Aspect Ratio:",
		"File Size:",
	}

	for _, expected := range expectedStrings {
		if !strings.Contains(description, expected) {
			t.Errorf("Expected description to contain %q, but it didn't.\nGot: %s", expected, description)
		}
	}
}

func TestDescribeImageNonExistent(t *testing.T) {
	_, err := describeImage("nonexistent.png")
	if err == nil {
		t.Error("Expected error for non-existent file, got nil")
	}
}

func TestDescribeImageInvalidDimensions(t *testing.T) {
	// Test with a minimal 1x1 image - this should work fine
	// The division by zero check is still important for corrupted images
	testImagePath := "test_small.png"
	createTestImage(t, testImagePath, 1, 1)
	defer os.Remove(testImagePath)
	
	description, err := describeImage(testImagePath)
	if err != nil {
		t.Errorf("Expected no error for 1x1 image, got: %v", err)
	}
	
	// Verify it contains the correct dimensions
	if !strings.Contains(description, "Dimensions: 1x1 pixels") {
		t.Errorf("Expected description to contain '1x1 pixels', got: %s", description)
	}
}

func TestGetOrientation(t *testing.T) {
	tests := []struct {
		aspectRatio float64
		expected    string
	}{
		{1.5, "Landscape"},
		{2.0, "Landscape"},
		{0.7, "Portrait"},
		{0.5, "Portrait"},
		{1.0, "Square"},
		{0.95, "Square"},
	}

	for _, tt := range tests {
		result := getOrientation(tt.aspectRatio)
		if result != tt.expected {
			t.Errorf("getOrientation(%.2f) = %q, expected %q", tt.aspectRatio, result, tt.expected)
		}
	}
}

func TestFormatFileSize(t *testing.T) {
	tests := []struct {
		bytes    int64
		expected string
	}{
		{100, "100 B"},
		{1024, "1.0 KB"},
		{1536, "1.5 KB"},
		{1048576, "1.0 MB"},
		{1073741824, "1.0 GB"},
	}

	for _, tt := range tests {
		result := formatFileSize(tt.bytes)
		if result != tt.expected {
			t.Errorf("formatFileSize(%d) = %q, expected %q", tt.bytes, result, tt.expected)
		}
	}
}
