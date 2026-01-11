use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;
use rand::seq::IndexedRandom;

fn default_day() -> u32 { 1 }

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct GameState {
    pub affection: i32,
    pub trust: i32,
    pub name: String,
    pub last_action: String,
    pub time_of_day: String,
    pub hour: u32,
    pub minute: u32,
    #[serde(default = "default_day")]
    pub day: u32,
    pub actions_taken: u32,
    pub daily_affection: i32,
    pub daily_trust: i32,
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
            day: 1,
            actions_taken: 0,
            daily_affection: 0,
            daily_trust: 0,
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
                if self.state.daily_affection < 10 {
                    self.state.affection += 2;
                    self.state.daily_affection += 2;
                }
                if self.state.daily_trust < 5 {
                    self.state.trust += 1;
                    self.state.daily_trust += 1;
                }
            }
            "give_treat" => {
                if self.state.daily_affection < 10 {
                    let gain = (10 - self.state.daily_affection).min(5);
                    self.state.affection += gain;
                    self.state.daily_affection += gain;
                }
                if self.state.daily_trust < 5 {
                    let gain = (5 - self.state.daily_trust).min(2);
                    self.state.trust += gain;
                    self.state.daily_trust += gain;
                }
            }
            "talk" => {
                // Hablar ahora da un poco de afecto/confianza pero muy poco
                if self.state.daily_affection < 10 {
                    self.state.affection += 1;
                    self.state.daily_affection += 1;
                }
            }
            _ => {}
        }

        self.state.last_action = action.to_string();
        self.state.actions_taken += 1;
        self.state.last_dialogue = self.get_random_dialogue(Some(action));

        // Cada acción consume tiempo equilibrado (2 horas)
        let minutes = 120; 
        
        self.advance_time(minutes);

        let _ = self.save_state();
    }

    pub fn advance_time(&mut self, minutes: u32) {
        self.state.minute += minutes;
        while self.state.minute >= 60 {
            self.state.minute -= 60;
            self.state.hour += 1;
        }

        while self.state.hour >= 24 {
            self.state.hour -= 24;
            self.state.day += 1;
            
            // Nuevo día: Resetear límites y empezar a las 8:00
            self.state.daily_affection = 0;
            self.state.daily_trust = 0;
            self.state.hour = 8;
        }

        self.update_time_of_day();
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_time_progression() {
        let mut state = GameState::default();
        state.hour = 22;
        state.minute = 0;
        state.day = 1;

        let mut engine = Engine {
            state: state.clone(),
            dialogues: serde_json::Value::Null,
            save_path: PathBuf::from("test_save.json"),
        };

        // Una acción toma 2 horas (120 min). 22:00 + 2h = 00:00 del día siguiente (8:00 por reset)
        engine.interact("talk");
        assert_eq!(engine.state.day, 2);
        assert_eq!(engine.state.hour, 8);
        assert_eq!(engine.state.minute, 0);
    }

    #[test]
    fn test_daily_limits() {
        let mut engine = Engine {
            state: GameState::default(),
            dialogues: serde_json::Value::Null,
            save_path: PathBuf::from("test_save_limits.json"),
        };

        // Realizamos acciones hasta llegar a la noche sin cambiar de día todavía
        // 8:00, 10:00, 12:00, 14:00, 16:00, 18:00 (6 acciones)
        for _ in 0..6 {
            engine.interact("pat_head");
        }
        assert_eq!(engine.state.daily_affection, 10); // 6 * 2 = 12, pero el límite es 10
        assert_eq!(engine.state.affection, 10);
        assert_eq!(engine.state.daily_trust, 5); // 6 * 1 = 6, pero el límite es 5
        assert_eq!(engine.state.hour, 20);
    }

    #[test]
    fn test_time_of_day_update() {
        let state = GameState::default();
        let mut engine = Engine {
            state,
            dialogues: serde_json::Value::Null,
            save_path: PathBuf::from("test_save_2.json"),
        };

        engine.state.hour = 5;
        engine.update_time_of_day();
        assert_eq!(engine.state.time_of_day, "night");

        engine.state.hour = 8;
        engine.update_time_of_day();
        assert_eq!(engine.state.time_of_day, "morning");

        engine.state.hour = 14;
        engine.update_time_of_day();
        assert_eq!(engine.state.time_of_day, "afternoon");

        engine.state.hour = 20;
        engine.update_time_of_day();
        assert_eq!(engine.state.time_of_day, "night");
    }
}
