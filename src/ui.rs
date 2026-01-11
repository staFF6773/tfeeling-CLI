use crate::engine::Engine;
use crossterm::event::{self, Event, KeyCode};
use ratatui::{
    backend::Backend,
    layout::{Constraint, Layout},
    style::{Color, Modifier, Style},
    widgets::{Block, Borders, Paragraph, Wrap, List, ListItem, ListState},
    Terminal,
};
use std::error::Error;

pub fn run_app<B: Backend>(terminal: &mut Terminal<B>, mut engine: Engine) -> Result<(), Box<dyn Error>> 
where 
    <B as Backend>::Error: 'static 
{
    let mut menu_state = ListState::default();
    menu_state.select(Some(0));

    loop {
        terminal.draw(|f| ui(f, &engine, &mut menu_state))?;

        if let Event::Key(key) = event::read()? {
            match key.code {
                KeyCode::Char('q') | KeyCode::Esc => return Ok(()),
                KeyCode::Up => {
                    let i = match menu_state.selected() {
                        Some(i) => {
                            if i == 0 {
                                4
                            } else {
                                i - 1
                            }
                        }
                        None => 0,
                    };
                    menu_state.select(Some(i));
                }
                KeyCode::Down => {
                    let i = match menu_state.selected() {
                        Some(i) => {
                            if i >= 4 {
                                0
                            } else {
                                i + 1
                            }
                        }
                        None => 0,
                    };
                    menu_state.select(Some(i));
                }
                KeyCode::Enter => {
                    match menu_state.selected() {
                        Some(0) => engine.interact("pat_head"),
                        Some(1) => engine.interact("talk"),
                        Some(2) => engine.interact("give_treat"),
                        Some(3) => {
                            // Credits handled in dialogue for now or a separate screen
                            // For simplicity, we just set a "credits" dialogue
                            engine.state.last_dialogue = "Concepto Original: Ray-K\nLógica y TUI: Antigravity (Rust Port)\nVersión: 1.0.0 (Rust)".to_string();
                        },
                        Some(4) => return Ok(()),
                        _ => {}
                    }
                }
                _ => {}
            }
        }
    }
}

fn ui(f: &mut ratatui::Frame, engine: &Engine, menu_state: &mut ListState) {
    let chunks = Layout::vertical([
        Constraint::Length(3), // Status bar
        Constraint::Min(10),   // Main area
        Constraint::Length(7), // Menu/Input
    ])
    .split(f.area());

    // Status Bar
    let status_text = format!(
        " Afecto: {} | Confianza: {} | Hora: {}:{:02} | Fase: {}",
        engine.state.affection,
        engine.state.trust,
        engine.state.hour,
        engine.state.minute,
        engine.state.time_of_day
    );
    let status_bar = Paragraph::new(status_text)
        .block(Block::default().borders(Borders::ALL).border_style(Style::default().fg(Color::Cyan)))
        .style(Style::default().fg(Color::Cyan));
    f.render_widget(status_bar, chunks[0]);

    // Main Area: Sylvie + Dialogue
    let main_chunks = Layout::horizontal([
        Constraint::Percentage(40),
        Constraint::Percentage(60),
    ])
    .split(chunks[1]);

    // Sylvie ASCII Art
    let sylvie_art = "
                   #########                      
                 ###+***##*#**                    
                 *#+**++***=*++=:                  
                 #*+****#**+*#+++                  
               # #**###*%##*--*##+                 
                 *#**#%-#*##:::-%*                 
                ####*-%@%@-%:@=-**                 
                %###*#:++::::*%-#*                 
               -%###*--+-:::::: =-                 
               +%#%#**##---::: *#                  
                *#**#*=+++-=-+*=*                  
                -=-=-#*----+------                 
              ====---=--+-=-==--=---               
            ========--=====-=:==--:---:              ";
    
    let sylvie_block = Paragraph::new(format!("\n{}\n\n       [ {} ]", sylvie_art, engine.state.name))
        .block(Block::default().borders(Borders::ALL).title(" Sylvie ").border_style(Style::default().fg(Color::Magenta)))
        .style(Style::default().fg(Color::Magenta));
    f.render_widget(sylvie_block, main_chunks[0]);

    // Dialogue Box
    let dialogue = Paragraph::new(engine.state.last_dialogue.as_str())
        .block(Block::default().borders(Borders::ALL).title(" Diálogo ").border_style(Style::default().fg(Color::White)))
        .style(Style::default().fg(Color::White))
        .wrap(Wrap { trim: true });
    f.render_widget(dialogue, main_chunks[1]);

    // Menu
    let items = [
        ListItem::new("1) Acariciar cabeza"),
        ListItem::new("2) Hablar"),
        ListItem::new("3) Dar dulce"),
        ListItem::new("4) Créditos"),
        ListItem::new("5) Salir"),
    ];
    let menu = List::new(items)
        .block(Block::default().borders(Borders::ALL).title(" Acciones ").border_style(Style::default().fg(Color::Gray)))
        .highlight_style(Style::default().fg(Color::Black).bg(Color::Magenta).add_modifier(Modifier::BOLD))
        .highlight_symbol(">> ");
    f.render_stateful_widget(menu, chunks[2], menu_state);
}
