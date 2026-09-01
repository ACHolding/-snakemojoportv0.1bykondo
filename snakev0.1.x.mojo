from std.python import Python
from std.random import random_si64, seed

comptime WIDTH = 800
comptime HEIGHT = 600
comptime CELL = 25
comptime GRID_W = WIDTH // CELL
comptime GRID_H = HEIGHT // CELL


@fieldwise_init
struct Point(Copyable, Movable):
    var x: Int
    var y: Int


def same_points(ax: Int, ay: Int, bx: Int, by: Int) -> Bool:
    return ax == bx and ay == by


def contains(snake: List[Point], px: Int, py: Int) -> Bool:
    for i in range(len(snake)):
        if same_points(snake[i].x, snake[i].y, px, py):
            return True
    return False


def hits_snake(
    snake: List[Point], px: Int, py: Int, exclude_tail: Bool
) -> Bool:
    var end = len(snake)
    if exclude_tail and end > 0:
        end -= 1

    for i in range(end):
        if same_points(snake[i].x, snake[i].y, px, py):
            return True
    return False


def spawn_food(snake: List[Point]) -> Point:
    var max_cells = GRID_W * GRID_H
    if len(snake) >= max_cells:
        return Point(-1, -1)

    for _ in range(max_cells * 4):
        var p = Point(
            Int(random_si64(0, GRID_W - 1)),
            Int(random_si64(0, GRID_H - 1)),
        )

        if not contains(snake, p.x, p.y):
            return p^

    return Point(-1, -1)


def reset_snake() -> List[Point]:
    var snake = List[Point]()

    snake.append(Point(15, 12))
    snake.append(Point(14, 12))
    snake.append(Point(13, 12))

    return snake^


def main() raises:
    seed()

    var pygame = Python.import_module("pygame")

    pygame.init()

    var screen = pygame.display.set_mode(
        Python.tuple(WIDTH, HEIGHT)
    )

    pygame.display.set_caption(
        "CATSDK MOJO SNAKE 0.1"
    )

    var clock = pygame.time.Clock()

    var font = pygame.font.Font(None, 36)
    var big_font = pygame.font.Font(None, 64)

    var snake = reset_snake()

    var dx = 1
    var dy = 0

    var next_dx = 1
    var next_dy = 0

    var food = spawn_food(snake)

    var score = 0

    var running = True
    var game_over = False

    var move_timer: Float64 = 0.0
    var move_delay: Float64 = 0.095

    while running:

        # PythonObject -> native Mojo conversion
        var tick_ms = Int(py=clock.tick(60))
        var dt = Float64(tick_ms) / 1000.0

        # ----------------------------------------------------
        # EVENTS
        # ----------------------------------------------------

        for event in pygame.event.get():

            if Bool(event.type == pygame.QUIT):
                running = False

            elif Bool(event.type == pygame.KEYDOWN):

                if Bool(event.key == pygame.K_ESCAPE):
                    running = False

                elif Bool(event.key == pygame.K_r) and game_over:

                    snake = reset_snake()

                    dx = 1
                    dy = 0

                    next_dx = 1
                    next_dy = 0

                    score = 0

                    game_over = False

                    move_timer = 0.0

                    food = spawn_food(snake)

                elif not game_over:

                    if (
                        (
                            Bool(event.key == pygame.K_UP)
                            or Bool(event.key == pygame.K_w)
                        )
                        and dy != 1
                    ):
                        next_dx = 0
                        next_dy = -1

                    elif (
                        (
                            Bool(event.key == pygame.K_DOWN)
                            or Bool(event.key == pygame.K_s)
                        )
                        and dy != -1
                    ):
                        next_dx = 0
                        next_dy = 1

                    elif (
                        (
                            Bool(event.key == pygame.K_LEFT)
                            or Bool(event.key == pygame.K_a)
                        )
                        and dx != 1
                    ):
                        next_dx = -1
                        next_dy = 0

                    elif (
                        (
                            Bool(event.key == pygame.K_RIGHT)
                            or Bool(event.key == pygame.K_d)
                        )
                        and dx != -1
                    ):
                        next_dx = 1
                        next_dy = 0

        # ----------------------------------------------------
        # UPDATE
        # ----------------------------------------------------

        if not game_over:

            move_timer += dt

            while move_timer >= move_delay:

                move_timer -= move_delay

                dx = next_dx
                dy = next_dy

                var head_x = snake[0].x
                var head_y = snake[0].y

                var new_head = Point(
                    head_x + dx,
                    head_y + dy,
                )

                var eating = same_points(new_head.x, new_head.y, food.x, food.y)

                var collision = (
                    new_head.x < 0
                    or new_head.x >= GRID_W
                    or new_head.y < 0
                    or new_head.y >= GRID_H
                    or hits_snake(
                        snake, new_head.x, new_head.y, not eating
                    )
                )

                if collision:
                    game_over = True
                    break

                snake.insert(
                    0,
                    new_head^,
                )

                if eating:

                    score += 10
                    food = spawn_food(snake)

                    if food.x < 0 or food.y < 0:
                        game_over = True

                else:
                    _ = snake.pop()

        # ----------------------------------------------------
        # RENDER
        # ----------------------------------------------------

        screen.fill(
            Python.tuple(
                10,
                15,
                25,
            )
        )

        # Grid vertical
        for x in range(0, WIDTH, CELL):

            pygame.draw.line(
                screen,
                Python.tuple(
                    22,
                    30,
                    44,
                ),
                Python.tuple(
                    x,
                    0,
                ),
                Python.tuple(
                    x,
                    HEIGHT,
                ),
            )

        # Grid horizontal
        for y in range(0, HEIGHT, CELL):

            pygame.draw.line(
                screen,
                Python.tuple(
                    22,
                    30,
                    44,
                ),
                Python.tuple(
                    0,
                    y,
                ),
                Python.tuple(
                    WIDTH,
                    y,
                ),
            )

        # ----------------------------------------------------
        # FOOD
        # ----------------------------------------------------

        if food.x >= 0 and food.y >= 0:
            var food_x = (
                food.x * CELL
                + CELL // 2
            )

            var food_y = (
                food.y * CELL
                + CELL // 2
            )

            # Outer glow
            pygame.draw.circle(
                screen,
                Python.tuple(
                    100,
                    25,
                    40,
                ),
                Python.tuple(
                    food_x,
                    food_y,
                ),
                CELL // 2,
            )

            # Core
            pygame.draw.circle(
                screen,
                Python.tuple(
                    255,
                    70,
                    90,
                ),
                Python.tuple(
                    food_x,
                    food_y,
                ),
                CELL // 2 - 4,
            )

        # ----------------------------------------------------
        # SNAKE
        # ----------------------------------------------------

        for i in range(len(snake)):

            var px = (
                snake[i].x * CELL
                + 2
            )

            var py = (
                snake[i].y * CELL
                + 2
            )

            if i == 0:

                # Head
                pygame.draw.rect(
                    screen,
                    Python.tuple(
                        80,
                        220,
                        255,
                    ),
                    Python.tuple(
                        px,
                        py,
                        CELL - 4,
                        CELL - 4,
                    ),
                    border_radius=7,
                )

                # Eyes
                pygame.draw.circle(
                    screen,
                    Python.tuple(
                        10,
                        25,
                        35,
                    ),
                    Python.tuple(
                        px + 8,
                        py + 8,
                    ),
                    2,
                )

                pygame.draw.circle(
                    screen,
                    Python.tuple(
                        10,
                        25,
                        35,
                    ),
                    Python.tuple(
                        px + CELL - 12,
                        py + 8,
                    ),
                    2,
                )

            else:

                pygame.draw.rect(
                    screen,
                    Python.tuple(
                        70,
                        255,
                        150,
                    ),
                    Python.tuple(
                        px,
                        py,
                        CELL - 4,
                        CELL - 4,
                    ),
                    border_radius=6,
                )

        # ----------------------------------------------------
        # HUD
        # ----------------------------------------------------

        var score_text = font.render(
            "SCORE " + String(score),
            True,
            Python.tuple(
                245,
                250,
                255,
            ),
        )

        screen.blit(
            score_text,
            Python.tuple(
                14,
                12,
            ),
        )

        var title = font.render(
            "CATSDK MOJO SNAKE 0.1",
            True,
            Python.tuple(
                90,
                220,
                255,
            ),
        )

        var title_rect = title.get_rect()

        title_rect.centerx = WIDTH // 2
        title_rect.y = 12

        screen.blit(
            title,
            title_rect,
        )

        # ----------------------------------------------------
        # GAME OVER
        # ----------------------------------------------------

        if game_over:

            var overlay = pygame.Surface(
                Python.tuple(
                    WIDTH,
                    HEIGHT,
                ),
                pygame.SRCALPHA,
            )

            overlay.fill(
                Python.tuple(
                    0,
                    0,
                    0,
                    175,
                )
            )

            screen.blit(
                overlay,
                Python.tuple(
                    0,
                    0,
                ),
            )

            var game_over_text = big_font.render(
                "GAME OVER",
                True,
                Python.tuple(
                    255,
                    80,
                    100,
                ),
            )

            var game_over_rect = game_over_text.get_rect()

            game_over_rect.center = Python.tuple(
                WIDTH // 2,
                HEIGHT // 2 - 40,
            )

            screen.blit(
                game_over_text,
                game_over_rect,
            )

            var restart_text = font.render(
                "PRESS R TO RESTART",
                True,
                Python.tuple(
                    245,
                    245,
                    255,
                ),
            )

            var restart_rect = restart_text.get_rect()

            restart_rect.center = Python.tuple(
                WIDTH // 2,
                HEIGHT // 2 + 35,
            )

            screen.blit(
                restart_text,
                restart_rect,
            )

        pygame.display.flip()

    pygame.quit()