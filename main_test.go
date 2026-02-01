package main

import (
	"strings"
	"testing"
)

func TestDescribeImage(t *testing.T) {
	// Test with the sample.png that we know exists
	description, err := describeImage("sample.png")
	if err != nil {
		t.Fatalf("Expected no error, got: %v", err)
	}

	// Verify the description contains expected information
	expectedStrings := []string{
		"Image Description:",
		"Filename: sample.png",
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
