#!/usr/bin/env python3
import json
import os
import argparse

# ==============================================================================
# Script: engine.py
# Descripción: Motor de lógica en Python para el simulador de Sylvie.
#              Gestiona estadísticas, persistencia JSON y selección de diálogos.
# ==============================================================================

SAVE_FILE = os.path.expanduser("~/.sylvie_save.json")
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DIALOGUES_FILE = os.path.join(BASE_DIR, "modules", "dialogues.sh")

DEFAULT_STATE = {
    "affection": 0,
    "trust": 0,
    "name": "Sylvie",
    "last_action": "none",
    "time_of_day": "morning",
    "hour": 8,
    "minute": 0,
    "actions_taken": 0
}

class SylvieEngine:
    def __init__(self):
        self.state = self.load_state()

    def load_state(self):
        """Carga el estado desde el archivo JSON o crea uno nuevo."""
        if os.path.exists(SAVE_FILE):
            try:
                with open(SAVE_FILE, 'r') as f:
                    return json.load(f)
            except (json.JSONDecodeError, IOError):
                return DEFAULT_STATE.copy()
        return DEFAULT_STATE.copy()

    def save_state(self):
        """Persiste el estado actual en disco."""
        with open(SAVE_FILE, 'w') as f:
            json.dump(self.state, f, indent=4)

    def advance_time(self, force=False):
        """Avanza el tiempo interno del juego."""
        self.state["minute"] += 30
        if self.state["minute"] >= 60:
            self.state["minute"] = 0
            self.state["hour"] += 1
        
        if self.state["hour"] >= 24:
            self.state["hour"] = 0
            
        self.update_time_of_day()
        self.state["actions_taken"] = 0
        self.save_state()

    def update_time_of_day(self):
        """Actualiza la fase del día basada en la hora."""
        hour = self.state["hour"]
        if 6 <= hour < 12:
            self.state["time_of_day"] = "morning"
        elif 12 <= hour < 18:
            self.state["time_of_day"] = "afternoon"
        else:
            self.state["time_of_day"] = "night"

    def interact(self, action):
        """Procesa una interacción del usuario."""
        if action == "pat_head":
            self.state["affection"] += 2
            self.state["trust"] += 1
            self.state["last_action"] = "pat_head"
        elif action == "give_treat":
            self.state["affection"] += 5
            self.state["trust"] += 2
            self.state["last_action"] = "give_treat"
        elif action == "talk":
            self.state["last_action"] = "talk"
        
        self.state["actions_taken"] += 1
        
        # Lógica de avance de tiempo automático cada 2 acciones
        time_passed = False
        if self.state["actions_taken"] >= 2:
            self.advance_time()
            time_passed = True
            
        self.save_state()
        return time_passed

    def get_status_json(self):
        """Retorna el estado actual en formato JSON para Bash."""
        return json.dumps(self.state)

def main():
    parser = argparse.ArgumentParser(description="Sylvie Logic Engine")
    parser.add_argument("--action", choices=["pat_head", "give_treat", "talk", "status", "advance"], help="Acción a realizar")
    args = parser.parse_args()

    engine = SylvieEngine()

    if args.action == "status":
        print(engine.get_status_json())
    elif args.action in ["pat_head", "give_treat", "talk"]:
        time_passed = engine.interact(args.action)
        # Retornamos JSON del estado actualizado para que Bash lo procese
        print(engine.get_status_json())
    elif args.action == "advance":
        engine.advance_time(force=True)
        print(engine.get_status_json())
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
