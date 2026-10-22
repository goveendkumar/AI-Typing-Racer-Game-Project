import random
import sys
import time
import math
import array
import pygame

# ============================================================
# CONFIG
# ============================================================
WIDTH, HEIGHT = 960, 640
FPS = 60

BACKGROUND = (28, 30, 40)
PANEL = (42, 45, 58)
TEXT = (225, 228, 235)
MUTED = (145, 151, 166)
GREEN = (99, 220, 145)
RED = (245, 105, 105)
YELLOW = (255, 220, 90)
BLUE = (105, 170, 255)

PASSAGES = [
    "The quick brown fox jumps over the lazy dog. Python is a powerful language for building amazing projects.",
    "Artificial intelligence is transforming the world. Machine learning can recognize images, understand speech, and write code.",
    "Success is not final, failure is not fatal. It is the courage to continue that counts. Keep practicing and you will improve.",
    "The ocean covers more than seventy percent of the earth's surface. It remains one of the least explored places on our planet.",
    "Coding is like solving a puzzle. Every bug teaches you something new. Patience and practice are the keys to mastery.",
]

DIFFICULTIES = {"Easy": 30, "Medium": 45, "Fast": 65}


# ============================================================
# SOUND GENERATION (No external file needed)
# ============================================================
def make_beep(frequency=800, duration_ms=30, volume=0.25, sample_rate=44100):
    """Generate a short beep sound using raw audio samples."""
    n_samples = int(sample_rate * duration_ms / 1000)
    buf = array.array("h")
    amplitude = int(32767 * volume)
    for i in range(n_samples):
        fade = 1.0 - (i / n_samples)  # fade out to avoid clicks
        value = int(amplitude * fade * math.sin(2 * math.pi * frequency * i / sample_rate))
        buf.append(value)
        buf.append(value)  # stereo
    return pygame.mixer.Sound(buffer=buf.tobytes())


def make_typing_sound():
    sample_rate = 44100
    duration_ms = 55
    n_samples = int(sample_rate * duration_ms / 1000)
    buf = array.array("h")
    amplitude = 0.28 * 32767

    for i in range(n_samples):
        t = i / sample_rate
        click_envelope = math.exp(-t / 0.0035)
        thock_time = max(t - 0.006, 0.0)
        thock_envelope = math.exp(-thock_time / 0.014) if t >= 0.006 else 0.0
        click = random.uniform(-1.0, 1.0) * click_envelope
        thock = (
            0.65 * math.sin(2 * math.pi * 185 * thock_time)
            + random.uniform(-1.0, 1.0) * 0.35
        ) * thock_envelope
        value = int(amplitude * (0.55 * click + 0.7 * thock))
        buf.append(value)
        buf.append(value)

    return pygame.mixer.Sound(buffer=buf.tobytes())


def make_error_sound():
    return make_beep(frequency=400, duration_ms=60, volume=0.2)


def make_win_sound():
    return make_beep(frequency=1500, duration_ms=150, volume=0.3)


# ============================================================
# DRAWING HELPERS
# ============================================================
def draw_centered(surface, text, font, color, y):
    rendered = font.render(text, True, color)
    surface.blit(rendered, (WIDTH // 2 - rendered.get_width() // 2, y))


def passage_positions(passage, font, start_y, max_width):
    positions = []
    x, y = 50, start_y

    index = 0
    while index < len(passage):
        if passage[index].isspace():
            positions.append((x, y))
            x += font.size(passage[index])[0]
            index += 1
            continue

        word_end = index
        while word_end < len(passage) and not passage[word_end].isspace():
            word_end += 1
        word_width = sum(font.size(char)[0] for char in passage[index:word_end])
        if x + word_width > max_width and x > 50:
            x = 50
            y += 42
        for char in passage[index:word_end]:
            positions.append((x, y))
            x += font.size(char)[0]
        index = word_end

    return positions


def draw_passage(surface, passage, typed_text, font):
    positions = passage_positions(passage, font, 225, WIDTH - 50)

    for index, char in enumerate(passage):
        color = TEXT
        if index < len(typed_text):
            color = GREEN if typed_text[index] == char else RED
        surface.blit(font.render(char, True, color), positions[index])

    # Safe cursor
    if not positions:
        return
    if len(typed_text) < len(passage):
        cursor_x, cursor_y = positions[len(typed_text)]
    else:
        last_x, last_y = positions[-1]
        cursor_x = last_x + font.size(passage[-1])[0]
        cursor_y = last_y
    pygame.draw.rect(surface, YELLOW, (cursor_x, cursor_y, 3, 30))


def draw_progress_bars(surface, human_progress, ai_progress, total, small_font):
    bar_x, bar_width, bar_height = 50, WIDTH - 100, 18
    for label, progress, color, y in (
        ("YOU", human_progress, YELLOW, 65),
        ("AI", ai_progress, BLUE, 105),
    ):
        ratio = min(progress / total, 1.0) if total else 0.0
        surface.blit(small_font.render(label, True, color), (bar_x, y - 23))
        pygame.draw.rect(surface, PANEL, (bar_x, y, bar_width, bar_height), border_radius=8)
        if ratio > 0:
            pygame.draw.rect(
                surface,
                color,
                (bar_x, y, max(8, int(bar_width * ratio)), bar_height),
                border_radius=8,
            )


# ============================================================
# MAIN
# ============================================================
def main():
    global WIDTH, HEIGHT

    pygame.init()

    screen = pygame.display.set_mode((WIDTH, HEIGHT), pygame.RESIZABLE)
    pygame.display.set_caption("AI Typing Racer")

    clock = pygame.time.Clock()

    body_font = pygame.font.SysFont("consolas", 25)
    small_font = pygame.font.SysFont("consolas", 19)
    title_font = pygame.font.SysFont("consolas", 42, bold=True)

    # Sounds
    try:
        pygame.mixer.init(frequency=44100, size=-16, channels=2, buffer=512)
        typing_sound = make_typing_sound()
        error_sound = make_error_sound()
        win_sound = make_win_sound()
        sound_ok = True
    except Exception as e:
        print(f"Sound init failed: {e}", file=sys.stderr)
        typing_sound = error_sound = win_sound = None
        sound_ok = False

    state = "menu"
    selected_difficulty = "Medium"
    passage = random.choice(PASSAGES)
    typed_text = ""
    start_time = None
    ai_progress = 0.0
    wpm = 0.0
    accuracy = 100.0
    scores = []
    running = True

    while running:
        delta_time = min(clock.tick(FPS) / 1000.0, 0.1)

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

            elif event.type == pygame.VIDEORESIZE:
                WIDTH, HEIGHT = event.w, event.h
                screen = pygame.display.set_mode((WIDTH, HEIGHT), pygame.RESIZABLE)

            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_ESCAPE:
                    running = False

                elif state == "menu":
                    if event.key == pygame.K_UP:
                        names = list(DIFFICULTIES)
                        selected_difficulty = names[
                            (names.index(selected_difficulty) - 1) % len(names)
                        ]
                    elif event.key == pygame.K_DOWN:
                        names = list(DIFFICULTIES)
                        selected_difficulty = names[
                            (names.index(selected_difficulty) + 1) % len(names)
                        ]
                    elif event.key == pygame.K_RETURN:
                        passage = random.choice(PASSAGES)
                        typed_text = ""
                        start_time = None
                        ai_progress = 0.0
                        wpm = 0.0
                        accuracy = 100.0
                        state = "playing"

                elif state == "playing":
                    if event.key == pygame.K_BACKSPACE:
                        typed_text = typed_text[:-1]
                    elif event.unicode and event.unicode.isprintable():
                        if len(typed_text) < len(passage):
                            if start_time is None:
                                start_time = time.perf_counter()
                            is_correct = event.unicode == passage[len(typed_text)]
                            typed_text += event.unicode
                            # Typing sound
                            if sound_ok:
                                if is_correct and typing_sound:
                                    typing_sound.play()
                                elif not is_correct and error_sound:
                                    error_sound.play()

                elif state == "finished" and event.key == pygame.K_RETURN:
                    state = "menu"

            elif event.type == pygame.MOUSEBUTTONDOWN and state == "menu":
                if event.button == 1:
                    for index, name in enumerate(DIFFICULTIES):
                        button = pygame.Rect(WIDTH // 2 - 180, 260 + index * 72, 360, 54)
                        if button.collidepoint(event.pos):
                            selected_difficulty = name
                            break

        screen.fill(BACKGROUND)

        # ---------- MENU ----------
        if state == "menu":
            draw_centered(screen, "AI TYPING RACER", title_font, TEXT, 105)
            draw_centered(screen, "Choose how fast your AI opponent types", body_font, MUTED, 190)

            for index, (name, ai_wpm) in enumerate(DIFFICULTIES.items()):
                button = pygame.Rect(WIDTH // 2 - 180, 260 + index * 72, 360, 54)
                color = BLUE if name == selected_difficulty else PANEL
                pygame.draw.rect(screen, color, button, border_radius=10)
                label_color = BACKGROUND if name == selected_difficulty else TEXT
                label = body_font.render(f"{name}  -  {ai_wpm} WPM", True, label_color)
                screen.blit(
                    label,
                    (button.centerx - label.get_width() // 2,
                     button.centery - label.get_height() // 2),
                )

            draw_centered(screen, "Click a difficulty or use UP/DOWN, then press ENTER",
                          small_font, MUTED, 500)
            draw_centered(screen, "Type the passage before the AI reaches the finish!",
                          small_font, MUTED, 532)

        # ---------- PLAYING ----------
        elif state == "playing":
            if start_time is not None:
                elapsed = max(time.perf_counter() - start_time, 0.001)
                wpm = (len(typed_text) / 5) * (60 / elapsed)
                correct_chars = sum(
                    typed_text[index] == passage[index]
                    for index in range(len(typed_text))
                )
                accuracy = correct_chars / len(typed_text) * 100 if typed_text else 100.0
                ai_cps = DIFFICULTIES[selected_difficulty] * 5 / 60
                ai_progress = min(ai_progress + ai_cps * delta_time, len(passage))

            draw_progress_bars(screen, len(typed_text), ai_progress, len(passage), small_font)
            draw_passage(screen, passage, typed_text, body_font)

            stats = f"WPM: {wpm:.0f}     Accuracy: {accuracy:.1f}%"
            screen.blit(small_font.render(stats, True, TEXT), (50, 155))
            screen.blit(
                small_font.render("Backspace = correct | ESC = quit", True, MUTED),
                (50, HEIGHT - 42),
            )

            human_won = len(typed_text) == len(passage)
            ai_won = ai_progress >= len(passage)
            if human_won or ai_won:
                state = "finished"
                scores.append((wpm, accuracy, selected_difficulty))
                if sound_ok and human_won and win_sound:
                    win_sound.play()

        # ---------- FINISHED ----------
        else:
            human_won = len(typed_text) == len(passage)
            headline = "YOU WIN!" if human_won else "AI WINS!"
            headline_color = YELLOW if human_won else BLUE
            draw_centered(screen, headline, title_font, headline_color, 85)
            draw_centered(screen, f"Your speed: {wpm:.0f} WPM", body_font, TEXT, 165)
            draw_centered(screen, f"Accuracy: {accuracy:.1f}%", body_font, TEXT, 205)
            draw_centered(screen, f"Difficulty: {selected_difficulty}", body_font, TEXT, 245)
            draw_centered(screen, "Recent results", body_font, MUTED, 330)

            for index, (score_wpm, score_accuracy, difficulty) in enumerate(scores[-5:]):
                result = f"{score_wpm:.0f} WPM  |  {score_accuracy:.1f}%  |  {difficulty}"
                draw_centered(screen, result, small_font, TEXT, 375 + index * 30)

            draw_centered(screen, "Press ENTER for menu | ESC to quit",
                          small_font, MUTED, HEIGHT - 55)

        pygame.display.flip()

    pygame.quit()
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except pygame.error as error:
        pygame.quit()
        print(f"Could not start the game: {error}", file=sys.stderr)
        raise SystemExit(1) from error