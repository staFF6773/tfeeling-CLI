use self_update::backends::github::Update;
use std::error::Error;

pub fn update() -> Result<(), Box<dyn Error>> {
    let status = Update::configure()
        .repo_owner("staFF6773")
        .repo_name("tfeeling-CLI")
        .bin_name("tfeeling-CLI")
        .show_download_progress(true)
        .current_version(env!("CARGO_PKG_VERSION"))
        .build()?
        .update()?;
    
    if status.updated() {
        println!("¡Actualizado a la versión {}!", status.version());
    } else {
        println!("Ya estás en la versión más reciente: {}", status.version());
    }
    
    Ok(())
}

pub fn check_version() -> Result<String, Box<dyn Error>> {
    let releases = self_update::backends::github::ReleaseList::configure()
        .repo_owner("staFF6773")
        .repo_name("tfeeling-CLI")
        .build()?
        .fetch()?;

    if releases.is_empty() {
        return Ok("No se encontraron releases en GitHub.".to_string());
    }

    let latest = &releases[0];
    let current = env!("CARGO_PKG_VERSION");

    if self_update::version::bump_is_greater(current, &latest.version)? {
        Ok(format!("Nueva versión disponible: v{} (Actual: v{})", latest.version, current))
    } else {
        Ok(format!("Estás actualizado. Versión: v{}", current))
    }
}
