use std::process::Command;
use std::path::Path;

#[test]
fn test_describe_example_image() {
    // Run the binary with the test image using cargo run
    let output = Command::new(env!("CARGO"))
        .args(["run", "--", "examples/test_image.png"])
        .output()
        .expect("Failed to execute command");
    
    assert!(output.status.success(), "Command should succeed");
    
    let stdout = String::from_utf8_lossy(&output.stdout);
    
    // Check that output contains expected information
    assert!(stdout.contains("Image Description"), "Should contain description header");
    assert!(stdout.contains("Format: Png"), "Should contain format");
    assert!(stdout.contains("Dimensions:"), "Should contain dimensions");
    assert!(stdout.contains("Orientation:"), "Should contain orientation");
    assert!(stdout.contains("Color Analysis:"), "Should contain color analysis");
}

#[test]
fn test_nonexistent_file() {
    // Try to describe a file that doesn't exist
    let output = Command::new(env!("CARGO"))
        .args(["run", "--", "nonexistent_file.png"])
        .output()
        .expect("Failed to execute command");
    
    assert!(!output.status.success(), "Should fail for nonexistent file");
    
    let stderr = String::from_utf8_lossy(&output.stderr);
    assert!(stderr.contains("Error") || stderr.contains("error"), "Should print error message");
}

#[test]
fn test_example_image_exists() {
    let example_path = Path::new("examples/test_image.png");
    assert!(example_path.exists(), "Example image should exist");
}
