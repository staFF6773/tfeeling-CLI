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
use std::time::Duration;
use ratatui_image::{
    picker::Picker,
    protocol::StatefulProtocol,
    StatefulImage,
    Resize,
};

pub fn run_app<B: Backend>(terminal: &mut Terminal<B>, mut engine: Engine) -> Result<(), Box<dyn Error>> 
where 
    <B as Backend>::Error: 'static 
{
    let mut menu_state = ListState::default();
    menu_state.select(Some(0));

    let mut visible_chars = 0;

    // Load image
    let image_path = "modules/art/Sylvie-base.png";
    let dyn_image = image::open(image_path)?;
    let picker = Picker::from_query_stdio().unwrap_or_else(|_| Picker::halfblocks());
    let mut image_state = picker.new_resize_protocol(dyn_image);

    loop {
        terminal.draw(|f| ui(f, &engine, &mut menu_state, visible_chars, &mut image_state))?;

        if event::poll(Duration::from_millis(30))? {
            if let Event::Key(key) = event::read()? {
                match key.code {
                    KeyCode::Char('q') | KeyCode::Esc => return Ok(()),
                    KeyCode::Up => {
                        let i = match menu_state.selected() {
                            Some(i) => {
                                if i == 0 {
                                    5
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
                                if i >= 5 {
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
                        let dialogue_len = engine.state.last_dialogue.chars().count();
                        if visible_chars < dialogue_len {
                            // Skip animation
                            visible_chars = dialogue_len;
                        } else if !engine.state.last_dialogue.is_empty() && engine.state.last_dialogue != "..." {
                            // Dialogue is finished, clear it
                            engine.state.last_dialogue = "...".to_string();
                            visible_chars = 3;
                        } else {
                            // Dialogue is empty/cleared, perform action
                            match menu_state.selected() {
                                Some(0) => engine.interact("pat_head"),
                                Some(1) => engine.interact("talk"),
                                Some(2) => engine.interact("give_treat"),
                                Some(3) => {
                                    engine.state.last_dialogue = "Concepto Original: Ray-K\nLógica y TUI: staFF6773 (Rust Port)\nVersión: 1.1.0 (Rust)".to_string();
                                },
                                Some(4) => {
                                    engine.state.last_dialogue = "Buscando actualizaciones...".to_string();
                                    visible_chars = 0;
                                    terminal.draw(|f| ui(f, &engine, &mut menu_state, visible_chars, &mut image_state))?;
                                    match crate::update::check_version() {
                                        Ok(msg) => engine.state.last_dialogue = msg,
                                        Err(e) => engine.state.last_dialogue = format!("Error al comprobar versión: {}", e),
                                    }
                                }
                                Some(5) => return Ok(()),
                                _ => {}
                            }
                            visible_chars = 0;
                        }
                    }
                    _ => {}
                }
            }
        }
        else {
            let dialogue_len = engine.state.last_dialogue.chars().count();
            if visible_chars < dialogue_len {
                visible_chars += 1;
            }
        }
    }
}

fn ui(f: &mut ratatui::Frame, engine: &Engine, menu_state: &mut ListState, visible_chars: usize, image_state: &mut StatefulProtocol) {
    let chunks = Layout::vertical([
        Constraint::Length(3), // Status bar
        Constraint::Min(10),   // Main area
        Constraint::Length(8), // Menu/Input (increased length)
    ])
    .split(f.area());

    // Status Bar
    let status_text = format!(
        " [ Día {} ] Afecto: {} (+{}/10) | Confianza: {} (+{}/5) | Hora: {}:{:02} | Fase: {}",
        engine.state.day,
        engine.state.affection,
        engine.state.daily_affection,
        engine.state.trust,
        engine.state.daily_trust,
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

    // Sylvie Image
    let sylvie_block = Block::default()
        .borders(Borders::ALL)
        .title(" Sylvie ")
        .border_style(Style::default().fg(Color::Magenta));
    
    let inner_area = sylvie_block.inner(main_chunks[0]);
    f.render_widget(sylvie_block, main_chunks[0]);
    
    let image = StatefulImage::new().resize(Resize::Fit(None));
    f.render_stateful_widget(image, inner_area, image_state);

    // Dialogue Box
    let displayed_text: String = engine.state.last_dialogue.chars().take(visible_chars).collect();
    let dialogue = Paragraph::new(displayed_text)
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
        ListItem::new("5) Comprobar versión"),
        ListItem::new("6) Salir"),
    ];
    let menu = List::new(items)
        .block(Block::default().borders(Borders::ALL).title(" Acciones ").border_style(Style::default().fg(Color::Gray)))
        .highlight_style(Style::default().fg(Color::Black).bg(Color::Magenta).add_modifier(Modifier::BOLD))
        .highlight_symbol(">> ");
    f.render_stateful_widget(menu, chunks[2], menu_state);
}
