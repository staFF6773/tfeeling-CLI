mod engine;
mod ui;
mod update;

use crate::engine::Engine;
use clap::{Parser, Subcommand};
use crossterm::{
    event::{DisableMouseCapture, EnableMouseCapture},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::{backend::CrosstermBackend, Terminal};
use std::{error::Error, io};

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    /// Actualiza la CLI desde GitHub
    Update,
}

fn main() -> Result<(), Box<dyn Error>> {
    let cli = Cli::parse();

    if let Some(Commands::Update) = cli.command {
        return update::update();
    }

    // Auto-check for update before starting
    println!("Comprobando actualizaciones...");
    match update::check_version() {
        Ok(msg) if msg.contains("Nueva versión disponible") => {
            println!("{}", msg);
            println!("¿Deseas actualizar ahora? (s/n)");
            let mut input = String::new();
            std::io::stdin().read_line(&mut input)?;
            if input.trim().to_lowercase() == "s" {
                return update::update();
            }
        }
        _ => {} // Continue if up to date or error
    }

    // Setup terminal
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen, EnableMouseCapture)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    // Create game engine
    let engine = Engine::new();

    // Run app
    let res = ui::run_app(&mut terminal, engine);

    // Restore terminal
    disable_raw_mode()?;
    execute!(
        terminal.backend_mut(),
        LeaveAlternateScreen,
        DisableMouseCapture
    )?;
    terminal.show_cursor()?;

    if let Err(err) = res {
        eprintln!("Error: {:?}", err);
    }

    Ok(())
}
