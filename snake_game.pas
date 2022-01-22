program game_snake;
uses crt;
const
    my_delay = 100;
    game_screen_color = cyan;
type
    type_direction = (up, down, right, left, no_direction);
    coordinates_type = longint;
    
    link_segment = ^segment_snake;
    segment_snake = record
        cor_x, cor_y: coordinates_type;
        link_next: link_segment;
        symbol_segment: string;
    end;

    snake = record
        link_first: link_segment;
        direction_head: type_direction;
    end;

    food = record
        cor_x, cor_y : coordinates_type;
    end;

procedure write_coordinate_snake(var input_snake : snake);
var
    tmp: ^link_segment;
begin
    tmp := @(input_snake.link_first);
    while tmp^ <> nil do
    begin
        writeln(tmp^^.cor_x, ' ', tmp^^.cor_y);
        tmp := @(tmp^^.link_next);
    end
end;

procedure add_head_snake(var input_snake : snake;
    x_head, y_head : coordinates_type{symbol, color...});
var
    tmp: link_segment;
begin
    if input_snake.link_first = nil then
    begin
        new(input_snake.link_first);
        input_snake.link_first^.link_next := nil;
        input_snake.link_first^.cor_x := x_head;
        input_snake.link_first^.cor_y := y_head;
    end
    else
    begin
        new(tmp);
        tmp^.link_next := @(input_snake.link_first^);
        input_snake.link_first := @(tmp^);
        input_snake.link_first^.cor_x := x_head;
        input_snake.link_first^.cor_y := y_head;
    end
end;

procedure add_end_snake(var input_snake : snake;
    x_end, y_end : coordinates_type);
var
    tmp: ^link_segment;
begin
    if input_snake.link_first = nil then
    begin
        new(input_snake.link_first);
        input_snake.link_first^.link_next := nil;
        input_snake.link_first^.cor_x := x_end;
        input_snake.link_first^.cor_y := y_end;
    end
    else
    begin
        tmp := @(input_snake.link_first);
        while tmp^^.link_next <> nil do
        begin
            tmp := @(tmp^^.link_next);
        end;
        new(tmp^^.link_next);
        tmp^^.link_next^.link_next := nil;
        tmp^^.link_next^.cor_x := x_end;
        tmp^^.link_next^.cor_y := y_end;
    end
end;

procedure init_snake(var input_snake : snake;
    direction_head : type_direction;
    cor_head_x, cor_head_y : coordinates_type);
begin
    input_snake.link_first := nil;
    add_head_snake(input_snake, cor_head_x, cor_head_y);
    input_snake.direction_head := direction_head;
end;

{this procedure correct if count segment more that 2 [2, 3, 4 ..]} 
procedure remove_last(input_snake: snake);
var
    tmp: ^link_segment;
begin
    tmp := @(input_snake.link_first);
    while tmp^^.link_next <> nil do
    begin
       tmp := @(tmp^^.link_next);
    end;
    dispose(tmp^);
    tmp^ := nil;
end;

procedure snake_move(var input_snake : snake;
    MAX_X, MAX_Y, MIN_X, MIN_Y: coordinates_type);
var
    delta_x : coordinates_type = 0;
    delta_y : coordinates_type = 0;
begin
    case input_snake.direction_head of
        up: delta_y := -1;
        down: delta_y := 1;
        right: delta_x := 1;
        left: delta_x := -1;
    end;
    add_head_snake(input_snake, 
                    (input_snake.link_first^.cor_x + delta_x),
                    (input_snake.link_first^.cor_y + delta_y));
    if input_snake.link_first^.cor_x > MAX_X then
         input_snake.link_first^.cor_x := MIN_X;       

    if input_snake.link_first^.cor_y > MAX_Y then 
        input_snake.link_first^.cor_y := MIN_Y;

    if input_snake.link_first^.cor_x < MIN_X then 
        input_snake.link_first^.cor_x := MAX_X;

    if input_snake.link_first^.cor_y < MIN_Y then
        input_snake.link_first^.cor_y := MAX_Y;
    remove_last(input_snake);
end;

procedure get_key(var code:integer);
var
    c: char;
begin
    c := ReadKey;
    if c = #0 then
    begin
        c := ReadKey;
        code := -ord(c)
    end
    else
    begin
        code := ord(c)
    end
end;

procedure draw_snake(var input_snake : snake);
const
    snake_part = '0';
    snake_head = '0';
var
    tmp: ^link_segment;
    i: integer;
begin
    TextBackground(Green);
    i := 0;
    tmp := @(input_snake.link_first);
    while tmp^ <> nil do
    begin
        GotoXY(tmp^^.cor_x, tmp^^.cor_y);
        if i = 0 then
            write(snake_head)
        else
            write(snake_part);
        tmp := @(tmp^^.link_next);
        i := i + 1;
    end;
    TextBackground(Black);
    GotoXY(1, 1);
end;

procedure input_sybol(c : integer; var input_snake : snake);
begin
    case c of
        -75:{left <-}
        begin
            if input_snake.direction_head <> right then
                input_snake.direction_head := left;
        end;
        -77:{right ->}
        begin
             if input_snake.direction_head <> left then
                input_snake.direction_head := right;           
        end;
        -72:{up}
        begin
              if input_snake.direction_head <> down then
                input_snake.direction_head := up;           
        end;
        -80:{down}
        begin
              if input_snake.direction_head <> up then
                input_snake.direction_head := down;
        end;
    end
end;

procedure draw_clean_screen(MAX_X,MAX_Y,MIN_X,MIN_Y: coordinates_type);
var
    tmp_x, tmp_y : coordinates_type;
begin
    TextBackground(game_screen_color);
    for tmp_y := MIN_Y to MAX_Y do
        begin
            GotoXY(MIN_X, tmp_y);
            for tmp_x := MIN_X to MAX_X do
            begin
            write(' ');
            end
        end;
    TextBackground(Black);
    GotoXY(1,1);
end;

function snake_is_die(var input_snake : snake): boolean;
var
    tmp: ^link_segment;
    counter_head_coordinate : coordinates_type;
begin
    counter_head_coordinate := 0;
    tmp := @(input_snake.link_first);
    while tmp^ <> nil do
    begin
        if ((tmp^^.cor_x = input_snake.link_first^.cor_x) and
            (tmp^^.cor_y = input_snake.link_first^.cor_y)) then
        begin
            counter_head_coordinate := counter_head_coordinate + 1;
        end;
        tmp := @(tmp^^.link_next);
    end;
    if counter_head_coordinate > 1 then
        snake_is_die := true
    else
        snake_is_die := false
   
end;

procedure print_message_in_center(MAX_X, MAX_Y, MIN_X, MIN_Y:coordinates_type;
    message : string);
var
    cor_x : coordinates_type;
    cor_y : coordinates_type;
begin
    cor_y := ((MAX_Y - MIN_Y + 1) div 2) + MIN_Y - 1;
    cor_x := ((MAX_X - MIN_Y + 1 - length(message)) div 2) + MIN_X - 1;
    GotoXY(cor_x, cor_y);
    write(message);
    GotoXY(1, 1);
end;

function is_snake_eat_food(var input_snake : snake; input_food : food) : boolean;
var
    eat_food : boolean;
begin
    eat_food := false;
    if ((input_snake.link_first^.cor_x = input_food.cor_x) and
        (input_snake.link_first^.cor_y = input_food.cor_y)) then
    begin
        eat_food := true;
    end;
    is_snake_eat_food := eat_food;
end;   

procedure print_food(input_food : food);
begin
    GotoXY(input_food.cor_x, input_food.cor_y);
    write('#');
    GotoXY(1, 1);
end;

procedure generate_coord_food(var input_snake : snake; var input_food : food;
    MAX_X, MAX_Y, MIN_X, MIN_Y : coordinates_type);
begin
    input_food.cor_x := random(MAX_X - MIN_X + 1) + MIN_X;
    input_food.cor_y := random(MAX_Y - MIN_Y + 1) + MIN_Y;
end;

var
    my_snake: snake;
    c: integer;
    MAX_GAME_SCREEN_X, MAX_GAME_SCREEN_Y,
    MIN_GAME_SCREEN_X, MIN_GAME_SCREEN_Y: coordinates_type;
    game_food : food;
begin
    MAX_GAME_SCREEN_X := ScreenWidth - 1;
    MAX_GAME_SCREEN_Y := ScreenHeight - 1;
    MIN_GAME_SCREEN_X := 2;
    MIN_GAME_SCREEN_Y := 2;
    clrscr;
    GotoXY(1, 1);

    init_snake(my_snake, right, 20, 20);
    {create procedure that create start}
    add_end_snake(my_snake, 19, 20);
    add_end_snake(my_snake, 18, 20);
    add_end_snake(my_snake, 17, 20);
    add_end_snake(my_snake, 16, 20);

    generate_coord_food(my_snake, game_food,MAX_GAME_SCREEN_X,
                    MAX_GAME_SCREEN_Y, MIN_GAME_SCREEN_X, MIN_GAME_SCREEN_Y);

    while true do
    begin
        if not Keypressed then
        begin
            if snake_is_die(my_snake) then
            begin
                print_message_in_center(MAX_GAME_SCREEN_X, MAX_GAME_SCREEN_Y,
                    MIN_GAME_SCREEN_X, MIN_GAME_SCREEN_Y, 'you die');
                delay(3000);
                break;
            end;
            if is_snake_eat_food(my_snake, game_food) then
            begin
                add_end_snake(my_snake, 1, 1);
                generate_coord_food(my_snake, game_food,MAX_GAME_SCREEN_X,
                    MAX_GAME_SCREEN_Y, MIN_GAME_SCREEN_X, MIN_GAME_SCREEN_Y);
            end;
            snake_move(my_snake, MAX_GAME_SCREEN_X, MAX_GAME_SCREEN_Y,
                MIN_GAME_SCREEN_X, MIN_GAME_SCREEN_Y);
            draw_clean_screen(MAX_GAME_SCREEN_X, MAX_GAME_SCREEN_Y,
                MIN_GAME_SCREEN_X, MIN_GAME_SCREEN_Y);
            draw_snake(my_snake);
            print_food(game_food);
            delay(my_delay);

            continue
        end;
        get_key(c);
        input_sybol(c, my_snake);
    end;
end.
