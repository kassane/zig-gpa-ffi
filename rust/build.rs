fn main() {
    if std::process::Command::new("zig")
        .arg("version")
        .status()
        .is_err()
    {
        panic!("Zig compiler is not installed. Please install Zig to build this project.");
    }

    // Use zig page_allocator (backing allocator) - replace libc to syscall
    std::process::Command::new("zig")
        .arg("build-lib")
        .arg("../zig/src/lib.zig")
        .arg(if cfg!(debug_assertions) {
            "-ODebug"
        } else {
            "-OReleaseSafe"
        })
        .arg("-fcompiler-rt") // Use zig compiler-rt (runtime_safety on)
        .arg("--name")
        .arg("zalloc")
        .arg("-fPIE")
        .arg("-target")
        .arg(
            if cfg!(target_os = "windows") && cfg!(target_env = "msvc") {
                "native-windows-msvc" // x86/x86_64/arm64-windows-msvc
            } else {
                "native-native" // default target
            },
        )
        .status()
        .expect("Failed to run zig build-lib");

    println!("cargo:rerun-if-changed=src/main.rs");
    println!("cargo:rustc-link-lib=zalloc");
    println!(
        "cargo:rustc-link-search={}",
        std::env::current_dir().unwrap().display()
    );
}
