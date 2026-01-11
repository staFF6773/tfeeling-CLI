use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;
use rand::seq::IndexedRandom;

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct GameState {
    pub affection: i32,
    pub trust: i32,
    pub name: String,
    pub last_action: String,
    pub time_of_day: String,
    pub hour: u32,
    pub minute: u32,
    pub actions_taken: u32,
    pub last_dialogue: String,
}

impl Default for GameState {
    fn default() -> Self {
        Self {
            affection: 0,
            trust: 0,
            name: "Sylvie".to_string(),
            last_action: "none".to_string(),
            time_of_day: "morning".to_string(),
            hour: 8,
            minute: 0,
            actions_taken: 0,
            last_dialogue: "...".to_string(),
        }
    }
}

pub struct Engine {
    pub state: GameState,
    pub dialogues: serde_json::Value,
    save_path: PathBuf,
}

impl Engine {
    pub fn new() -> Self {
        let home = std::env::var("HOME").unwrap_or_else(|_| ".".to_string());
        let save_path = PathBuf::from(home).join(".sylvie_save.json");
        
        let mut engine = Self {
            state: GameState::default(),
            dialogues: serde_json::Value::Null,
            save_path,
        };
        
        engine.load_state();
        engine.load_dialogues();
        engine
    }

    fn load_state(&mut self) {
        if let Ok(content) = fs::read_to_string(&self.save_path) {
            if let Ok(state) = serde_json::from_str(&content) {
                self.state = state;
            }
        }
    }

    fn load_dialogues(&mut self) {
        let path = PathBuf::from("modules/dialogues.json");
        if let Ok(content) = fs::read_to_string(path) {
            if let Ok(dialogues) = serde_json::from_str(&content) {
                self.dialogues = dialogues;
            }
        }
    }

    pub fn save_state(&self) -> Result<(), Box<dyn std::error::Error>> {
        let content = serde_json::to_string_pretty(&self.state)?;
        fs::write(&self.save_path, content)?;
        Ok(())
    }

    pub fn interact(&mut self, action: &str) {
        match action {
            "pat_head" => {
                self.state.affection += 2;
                self.state.trust += 1;
            }
            "give_treat" => {
                self.state.affection += 5;
                self.state.trust += 2;
            }
            "talk" => {}
            _ => {}
        }

        self.state.last_action = action.to_string();
        self.state.actions_taken += 1;
        self.state.last_dialogue = self.get_random_dialogue(Some(action));

        if self.state.actions_taken >= 2 {
            self.advance_time();
        }

        let _ = self.save_state();
    }

    pub fn advance_time(&mut self) {
        self.state.minute += 30;
        if self.state.minute >= 60 {
            self.state.minute = 0;
            self.state.hour += 1;
        }

        if self.state.hour >= 24 {
            self.state.hour = 0;
        }

        self.update_time_of_day();
        self.state.actions_taken = 0;
    }

    fn update_time_of_day(&mut self) {
        let hour = self.state.hour;
        self.state.time_of_day = if (6..12).contains(&hour) {
            "morning".to_string()
        } else if (12..18).contains(&hour) {
            "afternoon".to_string()
        } else {
            "night".to_string()
        };
    }

    pub fn get_random_dialogue(&self, action_override: Option<&str>) -> String {
        let mut choices = Vec::new();
        let affection = self.state.affection;
        let trust = self.state.trust;

        // 1. Base stats
        if affection < 20 || trust < 10 {
            if let Some(list) = self.dialogues.get("distrust").and_then(|v| v.as_array()) {
                choices.extend(list);
            }
        } else if affection < 60 || trust < 30 {
            if let Some(list) = self.dialogues.get("neutral").and_then(|v| v.as_array()) {
                choices.extend(list);
            }
        } else {
            if let Some(list) = self.dialogues.get("trust").and_then(|v| v.as_array()) {
                choices.extend(list);
            }
        }

        // 2. Time of day
        if let Some(time_node) = self.dialogues.get("time") {
            if let Some(list) = time_node.get(&self.state.time_of_day).and_then(|v| v.as_array()) {
                choices.extend(list);
            }
        }

        // 3. Action
        let action = action_override.unwrap_or(&self.state.last_action);
        if let Some(action_node) = self.dialogues.get("actions").and_then(|v| v.get(action)) {
            let tier = if affection >= 40 { "high" } else { "low" };
            if let Some(list) = action_node.get(tier).and_then(|v| v.as_array()) {
                choices.extend(list);
            }
        }

        // 4. Special for treats
        if action_override == Some("give_treat") {
            if let Some(action_node) = self.dialogues.get("actions").and_then(|v| v.get("give_treat")) {
                let tier = if affection >= 40 { "high" } else { "low" };
                if let Some(list) = action_node.get(tier).and_then(|v| v.as_array()) {
                    // Override choices with just treat dialogues
                    if !list.is_empty() {
                        let mut rng = rand::rng();
                        return list.choose(&mut rng).and_then(|v: &serde_json::Value| v.as_str()).unwrap_or("...").to_string();
                    }
                }
            }
        }

        if choices.is_empty() {
            return "...".to_string();
        }

        let mut rng = rand::rng();
        choices.choose(&mut rng).and_then(|v: &&serde_json::Value| v.as_str()).unwrap_or("...").to_string()
    }
}
