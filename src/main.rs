use clap::Parser;
use image::{GenericImageView, ImageFormat};
use std::path::PathBuf;

#[derive(Parser)]
#[command(name = "cargo-go")]
#[command(about = "A simple image description tool", long_about = None)]
struct Cli {
    /// Path to the image file to describe
    #[arg(value_name = "IMAGE")]
    image_path: PathBuf,
}

fn main() {
    let cli = Cli::parse();

    match describe_image(&cli.image_path) {
        Ok(description) => println!("{}", description),
        Err(e) => {
            eprintln!("Error: {}", e);
            std::process::exit(1);
        }
    }
}

fn describe_image(path: &PathBuf) -> Result<String, Box<dyn std::error::Error>> {
    // Load the image
    let img = image::open(path)?;
    
    // Get basic image properties
    let (width, height) = img.dimensions();
    let format = detect_format(path)?;
    let color_type = img.color();
    
    // Analyze image characteristics
    let aspect_ratio = width as f64 / height as f64;
    let orientation = if aspect_ratio > 1.2 {
        "landscape"
    } else if aspect_ratio < 0.8 {
        "portrait"
    } else {
        "square"
    };
    
    let megapixels = (width * height) as f64 / 1_000_000.0;
    
    // Analyze color characteristics
    let (avg_brightness, color_analysis) = analyze_colors(&img);
    
    // Build description
    let mut description = String::new();
    description.push_str(&format!("Image Description:\n"));
    description.push_str(&format!("==================\n\n"));
    description.push_str(&format!("Format: {:?}\n", format));
    description.push_str(&format!("Dimensions: {}x{} pixels ({:.2} MP)\n", width, height, megapixels));
    description.push_str(&format!("Orientation: {}\n", orientation));
    description.push_str(&format!("Color Type: {:?}\n", color_type));
    description.push_str(&format!("Average Brightness: {:.1}%\n", avg_brightness));
    description.push_str(&format!("\nColor Analysis:\n{}", color_analysis));
    
    Ok(description)
}

fn detect_format(path: &PathBuf) -> Result<ImageFormat, Box<dyn std::error::Error>> {
    match path.extension().and_then(|s| s.to_str()) {
        Some("png") => Ok(ImageFormat::Png),
        Some("jpg") | Some("jpeg") => Ok(ImageFormat::Jpeg),
        Some("gif") => Ok(ImageFormat::Gif),
        Some("bmp") => Ok(ImageFormat::Bmp),
        Some("webp") => Ok(ImageFormat::WebP),
        Some(ext) => Err(format!("Unsupported image format: .{}", ext).into()),
        None => Err("Could not determine file extension".into()),
    }
}

fn analyze_colors(img: &image::DynamicImage) -> (f64, String) {
    let rgb_img = img.to_rgb8();
    let (width, height) = img.dimensions();
    
    // Sample pixels for analysis (every 10th pixel to keep it fast)
    let mut total_brightness = 0u64;
    let mut red_sum = 0u64;
    let mut green_sum = 0u64;
    let mut blue_sum = 0u64;
    let mut sample_count = 0u64;
    
    for y in (0..height).step_by(10) {
        for x in (0..width).step_by(10) {
            let pixel = rgb_img.get_pixel(x, y);
            let r = pixel[0] as u64;
            let g = pixel[1] as u64;
            let b = pixel[2] as u64;
            
            red_sum += r;
            green_sum += g;
            blue_sum += b;
            
            // Calculate brightness (perceived luminance)
            let brightness = (0.299 * r as f64 + 0.587 * g as f64 + 0.114 * b as f64) as u64;
            total_brightness += brightness;
            sample_count += 1;
        }
    }
    
    let avg_brightness = (total_brightness as f64 / sample_count as f64) / 255.0 * 100.0;
    let avg_red = red_sum / sample_count;
    let avg_green = green_sum / sample_count;
    let avg_blue = blue_sum / sample_count;
    
    // Determine dominant color
    let dominant = if avg_red > avg_green && avg_red > avg_blue {
        "red"
    } else if avg_green > avg_red && avg_green > avg_blue {
        "green"
    } else if avg_blue > avg_red && avg_blue > avg_green {
        "blue"
    } else {
        "neutral"
    };
    
    let brightness_desc = if avg_brightness > 75.0 {
        "very bright"
    } else if avg_brightness > 50.0 {
        "bright"
    } else if avg_brightness > 25.0 {
        "dim"
    } else {
        "very dark"
    };
    
    let color_analysis = format!(
        "  - Dominant color tone: {}\n  - Overall brightness: {} ({:.1}%)\n  - Average RGB: ({}, {}, {})",
        dominant, brightness_desc, avg_brightness, avg_red, avg_green, avg_blue
    );
    
    (avg_brightness, color_analysis)
}
