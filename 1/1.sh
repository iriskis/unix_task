#!/bin/bash


PLAYER=''
ENEMY=''
MOVE='YOUR'
GAME_FIELD='         '
COLUMN=0
ROW=0

function draw_game_field() {

    tput reset
    echo 'Use arrows to move and SPACE or ENTER to select'$'\n'
    echo 'YOU: ' ${PLAYER}
    echo 'MOVE: ' ${MOVE}$'\n'

    for r in 0 1 2; do
        for c in 0 1 2; do
            m=${GAME_FIELD:3 * r + c:1}

            if [[ $r = $ROW ]] && [[ $c = $COLUMN ]] && [[ $m = ' ' ]];
                then echo -n ' '${PLAYER}' '
                else echo -n ' '${m}' '
            fi
			
			if [[ $c != 2 ]]; 
				then echo -n '┃'
	        fi
        done
		echo
        if [[ $r != 2 ]];
            then echo '━━━╋━━━╋━━━'

        fi
    done

}

function move_up() {
    ROW=$(((ROW + 2) % 3))	
}

function move_down() {
    ROW=$(((ROW + 1) % 3))
}

function move_left() {
    COLUMN=$(((COLUMN + 2) % 3))
}

function move_right() {
    COLUMN=$(((COLUMN + 1) % 3))
}

function add_char() {
    cell=$((3 * $3 + $2))       #calculate cell number

    if [[ ${GAME_FIELD:cell:1} = ' ' ]]; then
        GAME_FIELD=${GAME_FIELD:0:cell}${1}${GAME_FIELD:cell + 1}
    fi
}

function make_move() {
    add_char $PLAYER $COLUMN $ROW
    echo $COLUMN $ROW > channel
    MOVE='ENEMY'
}

function my_move() {
    read -r -sn1 k

    case $k in
        A) move_up;;
        B) move_down;;
        C) move_right;;
        D) move_left;;
        '') make_move;;
    esac
}

function wait_enemy_move() {
    enemy_move=`cat channel`
    add_char $ENEMY $enemy_move
    MOVE='YOUR'
}


function check_end_game() {
     if [[ ! $GAME_FIELD =~ " " ]]; 
            then echo 'DEAD HEAT!'
        sleep 3
        exit
    fi

    choose_win=(0 1 2 3 4 5 6 7 8 0 3 6 1 4 7 2 5 8 0 4 8 2 4 6)

    for i in 0 3 6 9 12 15 18 21; do
        a=${GAME_FIELD:choose_win[i]:1}
        b=${GAME_FIELD:choose_win[i + 1]:1}
        c=${GAME_FIELD:choose_win[i + 2]:1}

        if [[ $a = $b ]] && [[ $b = $c ]] && [[ $a != ' ' ]]; then
            if [[ $a = $PLAYER ]];
                then echo 'YOU WIN!'
            elif [[ $a = $ENEMY ]];
                then echo 'YOU LOSE!'
            fi

            sleep 3
            exit
        fi
    done
}


function connect_first_player() {
    trap 'rm channel; reset' EXIT
    echo 'Waiting for the second player...'
    
    PLAYER='☭'
    ENEMY='☮'

    enemy_pid=`cat channel`
    trap 'kill -INT -'$enemy_pid' &>/dev/null; reset; exit' INT
    echo $$ > channel
}

function connect_second_player() {
    trap 'reset' EXIT

    PLAYER='☮'
    ENEMY='☭'
    MOVE='ENEMY'

    echo $$ > channel
    enemy_pid=`cat channel`
    trap 'kill -INT -'$enemy_pid' &>/dev/null; reset; exit' INT
}

function main() {
    stty -echo                  
    mkfifo channel 

    if [[ $? = 0 ]];                    
        then connect_first_player
        else connect_second_player     
    fi

    while true; do
        draw_game_field

        if [[ $MOVE = 'YOUR' ]]; 
            then my_move
            else wait_enemy_move
        fi

        check_end_game
    done
}

main
