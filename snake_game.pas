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
        {пока не сделал}
        symbol_segment: string;
    end;

    snake = record
        link_first: link_segment;
        direction_head: type_direction;
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

{draw all elements}
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
            snake_is_die := true;
            break;
        end;
        tmp := @(tmp^^.link_next);
    end
   
end;

var
    my_snake: snake;
    foods: link_segment;
    c: integer;
    MAX_GAME_SCREEN_X, MAX_GAME_SCREEN_Y,
    MIN_GAME_SCREEN_X, MIN_GAME_SCREEN_Y: coordinates_type;

begin
    MAX_GAME_SCREEN_X := ScreenWidth;
    MAX_GAME_SCREEN_Y := ScreenHeight - 1;
    MIN_GAME_SCREEN_X := 1;
    MIN_GAME_SCREEN_Y := 1;
    clrscr;
    GotoXY(1, 1);

    init_snake(my_snake, right, 20, 20);
    {create procedure that create start}
    add_end_snake(my_snake, 20, 20);
    add_end_snake(my_snake, 20, 20);
    add_end_snake(my_snake, 20, 20);
    add_end_snake(my_snake, 20, 20);

    while true do
    begin
        if not Keypressed then
        begin
            {обрабатываю данные: не наступила ли змейка на себя?
            тогда она умерает
            не наступила ли змейка на стену?
            тогда умирает
            не скушала ли змейка еду?
            тогд она растёт}

            {смотрю есть ли еда на поле, если нет, то добавляю
            меняю координаты сегментов змейки, будто она сделала движение
            }
            snake_move(my_snake, MAX_GAME_SCREEN_X, MAX_GAME_SCREEN_Y,
                MIN_GAME_SCREEN_X, MIN_GAME_SCREEN_Y);
            {удаляю всё на экране}
            {clrscr;}
            draw_clean_screen(MAX_GAME_SCREEN_X, MAX_GAME_SCREEN_Y,
                MIN_GAME_SCREEN_X, MIN_GAME_SCREEN_Y);
            {отрисовываю всё на экране}
            draw_snake(my_snake);
            {draw_walls}
            {жду какое-то веремя, т.к иначе она двигается слишком быстро}
            delay(my_delay);

            continue
        end;
        get_key(c);
        {обработчик нажатых клавиш}
        input_sybol(c, my_snake);
    end;
end.
