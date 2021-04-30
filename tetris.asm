.model small 
.stack 64   
.data 
    play_ground_start_col  dw   100;136;100 
    play_ground_start_row  dw   4;160;4
    play_ground_finish_col dw   220;172;220
    play_ground_finish_row dw   196;196    
    block_start_col dw 208
    block_start_row dw 184
    block_finish_col dw 220
    block_finish_row dw 196    
    ;sc sr fc fr
    active_block_num_one dw ?, ?, ?, ?
    active_block_num_two dw ?, ?, ?, ?
    active_block_num_three dw ?, ?, ?, ?
    active_block_num_four dw ?, ?, ?, ?    
    active_block_center dw ?, ?, ?, ?     
    active_block_num_one_pred dw ?, ?, ?, ?
    active_block_num_two_pred dw ?, ?, ?, ?
    active_block_num_three_pred dw ?, ?, ?, ?
    active_block_num_four_pred dw ?, ?, ?, ? 
    block_start_col_pred dw ?
    block_start_row_pred dw ?
    block_finish_col_pred dw ?
    block_finish_row_pred dw ?  
    block_colour db 4H
    background_colour db 8H 
    temp_colour db 4H
    smart_colour db ?
    block_border_colour db ?
    block_incoming1_colour db ?
    block_incoming2_colour db ?
    random_incoming1_shape_number db ?
    random_incoming2_shape_number db ?  
    position db 1H
    shift_counter dw 0H
    random_shape_number db ?    
    produce_next_shape db 0H    
    seconds db 0  ;?ï¿½ï¿½ VARIABLE IN DATA SEGMENT.   
    block_is_free db 0  
    block_is_free_simple db 0         
    row_is_full db 0
    row_is_smart db 0    
    not_enough_space db 0     
    delay_counter dw 0
    successful_magic_shift dw 0 
    successful_magic_shift_pred dw 0
    score dw 0
    msg_score db "Score:0000$"   
.code
main proc far
    mov ax, @data
    mov ds, ax
    call init_clear_screen
    call init_graphic_mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     
    ;
    ;call draw_playground
    ;mov random_shape_number, 2H
    ;call draw_SP_block;
    ;call generate_random_shape
    ;game_test: 
    ;    call keyboard_actions 
    ;     jmp  game_test
   ;mov ax, 4C00h
   ;int 21h 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
    call draw_playground
    mov block_border_colour, 0H 
    call draw_border
    call display_score
    call genrate_random_number_init 
    call delay_2
    call generate_random_shape
    game_loop:
        ;call keyboard_actions 
        ;call delay_2
        call get_keyboard_char
        call shape_shift_down        
        cmp produce_next_shape, 1H 
        jne skip_genterate_label
    generate_label: 
        call check_and_modify_full_rows
        mov block_border_colour, 0H 
        call draw_border
        call update_score    
        call generate_random_shape
        cmp not_enough_space, 1H
        je game_over
    skip_genterate_label:     
        jmp game_loop 
    game_over:        
        mov block_border_colour, 0H 
        call draw_border
    mov ax, 4C00h
    int 21h         
main endp 
;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
delay proc  
delaying:   
;GET SYSTEM TIME.
  mov  ah, 2ch
  int  21h      ;?ï¿½ï¿½ RETURN SECONDS IN DH.
;CHECK IF ONE SECOND HAS PASSED. 
  cmp  dh, seconds  ;?ï¿½ï¿½ IF SECONDS ARE THE SAME...
  je   delaying     ;    ...WE ARE STILL IN THE SAME SECONDS.
  mov  seconds, dh  ;?ï¿½ï¿½ SECONDS CHANGED. PRESERVE NEW SECONDS.
  ret
delay endp
delay_2 proc
    mov delay_counter, 1
delay_loop1:
    mov cx, 0FFFFH
    inc delay_counter
delay_loop2:
    loop delay_loop2
    cmp delay_counter, 5
    jnz delay_loop1
    ret
endp delay_2  
get_keyboard_char proc
    mov delay_counter, 1
delay_loop3:
    mov cx, 0FFFFH
    inc delay_counter
delay_loop4:
    call keyboard_actions
    loop delay_loop4
    cmp delay_counter, 5
    jnz delay_loop3
    ret
endp get_keyboard_char 
proc is_this_my_block
  ret   
endp is_this_my_block
collapse proc
    mov bx, block_finish_row
    sub bx, 12  
collapse_loop:
    cmp bx, play_ground_start_row
    je  collapse_exit
    mov block_finish_row, bx
    sub bx, 12
    mov block_start_row, bx
    push bx
    mov bx, play_ground_start_col
collapse_inner_loop:
    cmp bx, play_ground_finish_col    
    je collapse_inner_exit
    mov block_start_col, bx
    add bx, 12
    mov block_finish_col, bx
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H  
    jne collapse_inner_loop
    call erase_single_block
    add block_start_row, 12
    add block_finish_row, 12
    push bx
    mov bl, temp_colour
    mov block_colour, bl 
    call draw_single_block
    pop bx
    sub block_start_row, 12
    sub block_finish_row, 12
    jmp collapse_inner_loop
    ;push bx
    ;call magic_shift_down 
    ;pop bx  
collapse_inner_exit:      
    pop bx
    jmp collapse_loop  
collapse_exit:   
   ret 
endp collapse
check_and_modify_full_rows proc
    mov bx, play_ground_finish_row
check_and_modify_full_rows_loop:
    cmp bx,  play_ground_start_row
    je check_and_modify_full_rows_exit
    mov block_finish_row, bx
    sub bx, 12
    mov block_start_row, bx                                  
    push bx                       
    call is_this_row_full
    pop bx
    cmp row_is_full, 1H
    jne check_and_modify_full_rows_loop
    push bx
    call is_this_row_smart
    pop bx
    cmp row_is_smart, 1H
    jne countinue_full_rows
    add score, 10
countinue_full_rows:    
    push bx
    mov bx, play_ground_start_col
    mov block_start_col, bx 
    mov bx, play_ground_finish_col
    mov block_finish_col, bx
    mov bl, background_colour 
    mov block_colour, bl
    call draw_single_block
    call collapse
    add score, 10                    
    pop bx
    add bx, 12
    jmp check_and_modify_full_rows_loop 
check_and_modify_full_rows_exit:
     ret
endp check_and_modify_full_rows
is_this_row_full proc   
    mov bx, play_ground_start_col
    mov row_is_full, 1H 
is_this_row_full_loop:
    cmp bx, play_ground_finish_col
    je is_this_row_full_exit
    mov block_start_col, bx
    add bx, 12
    mov block_finish_col, bx
    call is_this_block_free_simple
    cmp block_is_free_simple, 1H    
    je  is_this_row_full_set
    jmp is_this_row_full_loop
is_this_row_full_set:
     mov row_is_full, 0H     
is_this_row_full_exit:           
    ret
endp is_this_row_full
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
is_this_row_smart proc 
    mov row_is_smart, 1H
    mov bx, play_ground_start_col    
    mov block_start_col, bx
    add bx, 12
    mov block_finish_col, bx  
    inc block_start_col
    inc block_start_row
    dec block_finish_col
    dec block_finish_row 
    mov ah, 0DH                    
    mov cx, block_start_col
    mov dx, block_start_row
    int 10H
    mov smart_colour, al
    dec block_start_col
    dec block_start_row
    inc block_finish_col
    inc block_finish_row
    mov bx, play_ground_start_col  
is_this_row_smart_loop:
    cmp bx, play_ground_finish_col
    je is_this_row_smart_exit
    mov block_start_col, bx
    add bx, 12
    mov block_finish_col, bx
    inc block_start_col
    inc block_start_row
    dec block_finish_col
    dec block_finish_row 
    mov ah, 0DH                    
    mov cx, block_start_col
    mov dx, block_start_row
    int 10H
    dec block_start_col
    dec block_start_row
    inc block_finish_col
    inc block_finish_row  
    cmp al, smart_colour
    jne is_this_row_smart_set     
    jmp is_this_row_smart_loop
is_this_row_smart_set:
    mov row_is_smart, 0H
is_this_row_smart_exit:    
    ret
endp is_this_row_smart                             
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
is_this_block_free_simple proc 
    inc block_start_col
    inc block_start_row
    dec block_finish_col
    dec block_finish_row
    mov block_is_free_simple, 0H 
    mov ah, 0DH                    
    mov cx, block_start_col
    mov dx, block_start_row
    int 10H 
    cmp al, background_colour
    jne is_this_block_free_exit_simple
    mov block_is_free_simple, 1H    
is_this_block_free_exit_simple: 
    mov temp_colour, al
    dec block_start_col
    dec block_start_row
    inc block_finish_col
    inc block_finish_row     
   ret
endp is_this_block_free_simple
is_this_block_free proc 
    inc block_start_col
    inc block_start_row
    dec block_finish_col
    dec block_finish_row
    mov block_is_free, 0H 
    mov ah, 0DH                    
    mov cx, block_start_col
    mov dx, block_start_row
    int 10H 
    cmp al, block_colour
    je same_color_check:
    cmp al, background_colour
    je same_background_check
same_color_check:
    dec block_start_col
    dec block_start_row
    inc block_finish_col
    inc block_finish_row
    mov bx, active_block_num_one[0] 
    cmp bx, block_start_col
    je same_color_check_one_1
    jmp same_color_check_two
same_color_check_one_1:
    mov bx, active_block_num_one[2] 
    cmp bx, block_start_row
    je same_color_check_one_2
    jmp same_color_check_two
same_color_check_one_2:
    mov bx, active_block_num_one[4] 
    cmp bx, block_finish_col
    je same_color_check_one_3
    jmp same_color_check_two
same_color_check_one_3:  
    mov bx, active_block_num_one[6] 
    cmp bx, block_finish_row
    je same_color_check_one_all
    jmp same_color_check_two
same_color_check_one_all: 
     mov block_is_free, 1H
     jmp is_this_block_free_exit 
same_color_check_two: 
    mov bx, active_block_num_two[0] 
    cmp bx, block_start_col
    je same_color_check_two_1
    jmp same_color_check_three
same_color_check_two_1:
    mov bx, active_block_num_two[2] 
    cmp bx, block_start_row
    je same_color_check_two_2
    jmp same_color_check_three
same_color_check_two_2:
    mov bx, active_block_num_two[4] 
    cmp bx, block_finish_col
    je same_color_check_two_3
    jmp same_color_check_three
same_color_check_two_3:  
    mov bx, active_block_num_two[6] 
    cmp bx, block_finish_row
    je same_color_check_two_all
    jmp same_color_check_three
same_color_check_two_all: 
     mov block_is_free, 1H
     jmp is_this_block_free_exit 
same_color_check_three: 
    mov bx, active_block_num_three[0] 
    cmp bx, block_start_col
    je same_color_check_three_1
    jmp same_color_check_four
same_color_check_three_1:
    mov bx, active_block_num_three[2] 
    cmp bx, block_start_row
    je same_color_check_three_2
    jmp same_color_check_four
same_color_check_three_2:
    mov bx, active_block_num_three[4] 
    cmp bx, block_finish_col
    je same_color_check_three_3
    jmp same_color_check_four
same_color_check_three_3:  
    mov bx, active_block_num_three[6] 
    cmp bx, block_finish_row
    je same_color_check_three_all
    jmp same_color_check_four
same_color_check_three_all: 
     mov block_is_free, 1H
     jmp is_this_block_free_exit 
same_color_check_four: 
    mov bx, active_block_num_four[0] 
    cmp bx, block_start_col
    je same_color_check_four_1
    jmp is_this_block_free_exit
same_color_check_four_1:
    mov bx, active_block_num_four[2] 
    cmp bx, block_start_row
    je same_color_check_four_2
    jmp is_this_block_free_exit
same_color_check_four_2:
    mov bx, active_block_num_four[4] 
    cmp bx, block_finish_col
    je same_color_check_four_3
    jmp is_this_block_free_exit
same_color_check_four_3:  
    mov bx, active_block_num_four[6] 
    cmp bx, block_finish_row
    je same_color_check_four_all
    jmp is_this_block_free_exit
same_color_check_four_all: 
     mov block_is_free, 1H
     jmp is_this_block_free_exit 
same_background_check:
    mov block_is_free, 1H
    dec block_start_col
    dec block_start_row
    inc block_finish_col
    inc block_finish_row    
is_this_block_free_exit:    
   ret
endp is_this_block_free
check_reach_end proc 
    mov bx, active_block_num_one[6]
    cmp bx, play_ground_finish_row
    je produce_next_shape_label
    mov bx, active_block_num_two[6]
    cmp bx, play_ground_finish_row
    je produce_next_shape_label
    mov bx, active_block_num_three[6]
    cmp bx, play_ground_finish_row
    je produce_next_shape_label
    mov bx, active_block_num_four[6]
    cmp bx, play_ground_finish_row
    je produce_next_shape_label 
    mov produce_next_shape, 0H
    jmp produce_next_shape_exit
produce_next_shape_label:
    mov produce_next_shape, 1H
produce_next_shape_exit:    
    ret
check_reach_end endp   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fill_array_num_one proc
    LEA SI, active_block_num_one
    mov bx, block_start_col   
    mov [SI], bx         
    add SI, 2
    mov bx, block_start_row 
    mov [SI], bx        
    add SI, 2
    mov bx, block_finish_col 
    mov [SI], bx         
    add SI, 2
    mov bx, block_finish_row
    mov [SI], bx         
    add SI, 2   
    ret              
endp fill_array_num_one
fill_array_num_two proc
    LEA SI, active_block_num_two
    mov bx, block_start_col   
    mov [SI], bx            
    add SI, 2
    mov bx, block_start_row 
    mov [SI], bx        
    add SI, 2
    mov bx, block_finish_col 
    mov [SI], bx         
    add SI, 2
    mov bx, block_finish_row
    mov [SI], bx         
    add SI, 2   
    ret              
endp fill_array_num_two
fill_array_num_three proc
    LEA SI, active_block_num_three
    mov bx, block_start_col   
    mov [SI], bx            
    add SI, 2
    mov bx, block_start_row 
    mov [SI], bx         
    add SI, 2
    mov bx, block_finish_col 
    mov [SI], bx         
    add SI, 2
    mov bx, block_finish_row
    mov [SI], bx         
    add SI, 2   
    ret              
endp fill_array_num_three
fill_array_num_four proc
    LEA SI, active_block_num_four
    mov bx, block_start_col   
    mov [SI], bx            
    add SI, 2
    mov bx, block_start_row 
    mov [SI], bx         
    add SI, 2
    mov bx, block_finish_col 
    mov [SI], bx         
    add SI, 2
    mov bx, block_finish_row
    mov [SI], bx          
    add SI, 2   
    ret              
endp fill_array_num_four 
fill_center_block proc
    LEA SI, active_block_center
    mov bx, block_start_col   
    mov [SI], bx            
    add SI, 2
    mov bx, block_start_row 
    mov [SI], bx         
    add SI, 2
    mov bx, block_finish_col 
    mov [SI], bx         
    add SI, 2
    mov bx, block_finish_row
    mov [SI], bx          
    add SI, 2   
    ret              
endp fill_center_block
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init_clear_screen proc
    mov al, 06h   ; scroll down    
    mov bh, 00h
    mov cx, 0000h    ;row 00 | coloumn 00 
    mov dx, 184Fh   
    ret       
endp init_clear_screen  
init_graphic_mode proc 
    mov ah, 00h
    mov al, 13h
    int 10h         
    ret   
endp init_graphic_mode
draw_playground proc
    mov ah, 0ch
    mov al, background_colour
    mov dx, play_ground_start_row  
loop1:
    mov cx, play_ground_start_col
loop2:
    int 10h
    inc cx
    cmp cx, play_ground_finish_col
    jnz loop2
    inc dx
    cmp dx, play_ground_finish_row
    jnz loop1      
    ret   
endp draw_playground
clear_upcoming_panel proc
    mov ah, 0ch
    mov al, 0h
    mov dx, 40  
clear_upcoming_panel_loop1:
    mov cx, 256
clear_upcoming_panel_loop2:
    int 10h
    inc cx
    cmp cx, 304
    jnz clear_upcoming_panel_loop2
    inc dx
    cmp dx, 76
    jnz clear_upcoming_panel_loop1
    mov ah, 0ch
    mov al, 0h
    mov dx, 136  
clear_upcoming_panel_loop3:
    mov cx, 256
clear_upcoming_panel_loop4:
    int 10h
    inc cx
    cmp cx, 304
    jnz clear_upcoming_panel_loop4
    inc dx
    cmp dx, 172
    jnz clear_upcoming_panel_loop3      
    ret   
endp clear_upcoming_panel
draw_single_block_border proc
    mov ah, 0ch
    mov al, block_border_colour
    dec block_finish_row 
    mov dx, block_start_row     
    mov cx, block_start_col
loop4_bb:
    int 10h
    inc cx 
    cmp cx, block_finish_col
    jnz loop4_bb
    inc dx
loop3_b:
    mov cx, block_start_col
loop4_b:
    int 10h
    add cx, 11 
    cmp cx, block_finish_col
    jb loop4_b
    inc dx
    cmp dx, block_finish_row
    jnz loop3_b
    mov dx, block_finish_row     
    mov cx, block_start_col
loop4_bbb:
    int 10h
    inc cx 
    cmp cx, block_finish_col
    jnz loop4_bbb 
    inc block_finish_row
    ret   
endp  draw_single_block_border
draw_border proc
    mov bx,  play_ground_start_row
    mov block_start_row, bx 
    add bx, 12
    mov block_finish_row, bx   
draw_border_loop1:
    mov bx,  play_ground_start_col
    mov block_start_col, bx
    add bx, 12
    mov block_finish_col, bx 
draw_border_loop2:
    call draw_single_block_border
    add block_start_col, 12
    add block_finish_col, 12
    mov bx,  play_ground_finish_col
    cmp bx, block_start_col
    jnz draw_border_loop2
    add block_start_row, 12
    add block_finish_row, 12
    mov bx, play_ground_finish_row
    cmp bx, block_start_row
    jnz draw_border_loop1
    ret
endp draw_border
draw_single_block proc
    mov ah, 0ch
    mov al, block_colour
    inc block_start_col
    inc block_start_row
    dec block_finish_col
    dec block_finish_row 
    mov dx, block_start_row  
loop3:
    mov cx, block_start_col
loop4:
    int 10h
    inc cx 
    cmp cx, block_finish_col
    jnz loop4
    inc dx
    cmp dx, block_finish_row
    jnz loop3
    dec block_start_col
    dec block_start_row
    inc block_finish_col
    inc block_finish_row
    ret   
endp  draw_single_block
erase_single_block proc
    mov ah, 0ch
    mov al, background_colour
    inc block_start_col
    inc block_start_row
    dec block_finish_col
    dec block_finish_row 
    mov dx, block_start_row  
loop3_r:
    mov cx, block_start_col
loop4_r:
    int 10h
    inc cx 
    cmp cx, block_finish_col
    jnz loop4_r
    inc dx
    cmp dx, block_finish_row
    jnz loop3_r
    dec block_start_col
    dec block_start_row
    inc block_finish_col
    inc block_finish_row
    ret   
endp  erase_single_block 
draw_square_block proc
    mov block_start_col, 148
    mov block_start_row, 4
    mov block_finish_col, 160
    mov block_finish_row, 16
    call draw_single_block 
    call fill_array_num_one
    mov block_start_col, 160
    mov block_start_row, 4
    mov block_finish_col, 172
    mov block_finish_row, 16
    call draw_single_block
    call fill_array_num_two
    mov block_start_col, 148
    mov block_start_row, 16
    mov block_finish_col, 160
    mov block_finish_row, 28
    call draw_single_block
    call fill_array_num_three
    mov block_start_col, 160
    mov block_start_row, 16
    mov block_finish_col, 172
    mov block_finish_row, 28
    call draw_single_block
    call fill_array_num_four
    ret
endp draw_square_block
draw_square_block_2 proc
    mov block_start_col, 148
    mov block_start_row, 4
    mov block_finish_col, 160
    mov block_finish_row, 16
    call draw_single_block 
    mov block_start_col, 160
    mov block_start_row, 4
    mov block_finish_col, 172
    mov block_finish_row, 16
    call draw_single_block                             
    ret    
endp draw_square_block_2 
draw_rectangle_block proc
    mov block_start_col, 136
    mov block_start_row, 16
    mov block_finish_col, 148
    mov block_finish_row, 28
    call draw_single_block
    call fill_array_num_one
    mov block_start_col, 148
    mov block_start_row, 16
    mov block_finish_col, 160
    mov block_finish_row, 28
    call draw_single_block
    call fill_array_num_two
    mov block_start_col, 160
    mov block_start_row, 16
    mov block_finish_col, 172
    mov block_finish_row, 28
    call draw_single_block
    call fill_array_num_three
    mov block_start_col, 172
    mov block_start_row, 16
    mov block_finish_col, 184
    mov block_finish_row, 28
    call draw_single_block
    call fill_array_num_four 
    mov block_start_col, 160
    mov block_start_row, 28
    mov block_finish_col, 160
    mov block_finish_row, 28
    call fill_center_block
    ret
endp draw_rectangle_block 
draw_rectangle_block_2 proc
    mov block_start_col, 136
    mov block_start_row, 4
    mov block_finish_col, 148
    mov block_finish_row, 16
    call draw_single_block
    call fill_array_num_one
    mov block_start_col, 148
    mov block_start_row, 4
    mov block_finish_col, 160
    mov block_finish_row, 16
    call draw_single_block
    call fill_array_num_two
    mov block_start_col, 160
    mov block_start_row, 4
    mov block_finish_col, 172
    mov block_finish_row, 16
    call draw_single_block
    call fill_array_num_three
    mov block_start_col, 172
    mov block_start_row, 4
    mov block_finish_col, 184
    mov block_finish_row, 16
    call draw_single_block
    call fill_array_num_four 
    mov block_start_col, 160
    mov block_start_row, 16
    mov block_finish_col, 160
    mov block_finish_row, 16
    call fill_center_block
    ret
endp draw_rectangle_block_2 
draw_L_block proc
    mov block_start_col, 148
    mov block_start_row, 4
    mov block_finish_col, 160
    mov block_finish_row, 16
    call draw_single_block
    call fill_array_num_one
    mov block_start_col, 148
    mov block_start_row, 16
    mov block_finish_col, 160
    mov block_finish_row, 28
    call draw_single_block
    call fill_array_num_two
    mov block_start_col, 148
    mov block_start_row, 28
    mov block_finish_col, 160
    mov block_finish_row, 40
    call draw_single_block
    call fill_array_num_three
    mov block_start_col, 160
    mov block_start_row, 28
    mov block_finish_col, 172
    mov block_finish_row, 40
    call draw_single_block 
    call fill_array_num_four
    mov block_start_col, 160
    mov block_start_row, 16
    mov block_finish_col, 172
    mov block_finish_row, 28
    call fill_center_block
    ret
endp draw_L_block 
draw_L_block_2 proc
    mov block_start_col, 148
    mov block_start_row, 4
    mov block_finish_col, 160
    mov block_finish_row, 16
    call draw_single_block 
    mov block_start_col, 160
    mov block_start_row, 4
    mov block_finish_col, 172
    mov block_finish_row, 16
    call draw_single_block                             
    ret   
endp draw_L_block_2
draw_L_block_3 proc
    mov block_start_col, 148
    mov block_start_row, 16
    mov block_finish_col, 160
    mov block_finish_row, 28
    call draw_single_block 
    mov block_start_col, 160
    mov block_start_row, 16
    mov block_finish_col, 172
    mov block_finish_row, 28
    call draw_single_block                              
    mov block_start_col, 148
    mov block_start_row, 4
    mov block_finish_col, 160
    mov block_finish_row, 16
    call draw_single_block  
    ret 
endp draw_L_block_3
draw_T_block proc
    mov block_start_col, 148
    mov block_start_row, 4
    mov block_finish_col, 160
    mov block_finish_row, 16
    call draw_single_block
    call fill_array_num_one
    mov block_start_col, 136
    mov block_start_row, 16
    mov block_finish_col, 148
    mov block_finish_row, 28
    call draw_single_block 
    call fill_array_num_two
    mov block_start_col, 148
    mov block_start_row, 16
    mov block_finish_col, 160
    mov block_finish_row, 28
    call draw_single_block 
    call fill_array_num_three
    mov block_start_col, 160
    mov block_start_row, 16
    mov block_finish_col, 172
    mov block_finish_row, 28
    call draw_single_block   
    call fill_array_num_four 
    mov block_start_col, 148
    mov block_start_row, 16
    mov block_finish_col, 160
    mov block_finish_row, 28
    call fill_center_block
    ret
endp draw_T_block 
draw_T_block_2 proc
    mov block_start_col, 136
    mov block_start_row, 4
    mov block_finish_col, 148
    mov block_finish_row, 16
    call draw_single_block 
    mov block_start_col, 148
    mov block_start_row, 4
    mov block_finish_col, 160
    mov block_finish_row, 16
    call draw_single_block 
    mov block_start_col, 160
    mov block_start_row, 4
    mov block_finish_col, 172
    mov block_finish_row, 16
    call draw_single_block   
    ret
endp draw_T_block_2
draw_Z_block proc
    mov block_start_col, 148
    mov block_start_row, 4
    mov block_finish_col, 160
    mov block_finish_row, 16
    call draw_single_block  
    call fill_array_num_one
    mov block_start_col, 148
    mov block_start_row, 16
    mov block_finish_col, 160
    mov block_finish_row, 28
    call draw_single_block 
    call fill_array_num_two
    mov block_start_col, 160
    mov block_start_row, 16
    mov block_finish_col, 172
    mov block_finish_row, 28
    call draw_single_block 
    call fill_array_num_three
    mov block_start_col, 160
    mov block_start_row, 28
    mov block_finish_col, 172
    mov block_finish_row, 40
    call draw_single_block   
    call fill_array_num_four
    mov block_start_col, 160
    mov block_start_row, 16
    mov block_finish_col, 172
    mov block_finish_row, 28
    call fill_center_block 
    mov block_start_col, 148
    mov block_start_row, 16
    mov block_finish_col, 160
    mov block_finish_row, 28
    call fill_center_block
    ret
endp draw_Z_block
draw_Z_block_2 proc
    mov block_start_col, 160
    mov block_start_row, 4
    mov block_finish_col, 172
    mov block_finish_row, 16
    call draw_single_block  
    ret
endp draw_Z_block_2  
draw_Z_block_3 proc
    mov block_start_col, 148
    mov block_start_row, 4
    mov block_finish_col, 160
    mov block_finish_row, 16
    call draw_single_block  
    mov block_start_col, 160
    mov block_start_row, 4
    mov block_finish_col, 172
    mov block_finish_row, 16
    call draw_single_block
    mov block_start_col, 160
    mov block_start_row, 16
    mov block_finish_col, 172
    mov block_finish_row, 28
    call draw_single_block  
    ret
endp draw_Z_block_3
block_shift_right proc
    mov bx, 0  
    inc block_start_col
    inc block_start_row
    dec block_finish_col
    dec block_finish_row 
loop5:    
    mov ah, 0ch
    mov al, background_colour 
    mov dx, block_start_row
    mov cx, block_start_col
loop6:
    int 10h
    inc dx
    cmp dx, block_finish_row
    jnz loop6
    mov ah, 0ch    
    mov al, block_colour    
    mov dx, block_start_row   
    mov cx, block_finish_col 
loop7:
    int 10h
    inc dx
    cmp dx, block_finish_row
    jnz loop7
    inc block_start_col
    inc block_finish_col
    inc bx 
    cmp bx, 12
    jnz loop5
    dec block_start_col
    dec block_start_row
    inc block_finish_col
    inc block_finish_row
    ret
endp block_shift_right
block_shift_left proc 
    mov bx, 0  
    inc block_start_col
    inc block_start_row
    dec block_finish_col
    dec block_finish_row 
loop8:
    mov ah, 0ch
    mov al, background_colour
    mov dx, block_start_row
    mov cx, block_finish_col
    dec cx
loop9:
    int 10h
    inc dx
    cmp dx, block_finish_row
    jnz loop9
    mov ah, 0ch   
    mov al, block_colour    
    mov dx, block_start_row   
    mov cx, block_start_col
    dec cx
loop10:
    int 10h
    inc dx
    cmp dx, block_finish_row
    jnz loop10
    dec block_start_col
    dec block_finish_col
    inc bx 
    cmp bx, 12
    jnz loop8 
    dec block_start_col
    dec block_start_row
    inc block_finish_col
    inc block_finish_row
    ret
endp block_shift_left
block_shift_down proc
    mov bx, 0  
    inc block_start_col
    inc block_start_row
    dec block_finish_col
    dec block_finish_row   
loop11:     
    mov ah, 0ch
    mov al, background_colour    
    mov cx, block_start_col
    mov dx, block_start_row
loop12:
    int 10h
    inc cx
    cmp cx, block_finish_col
    jnz loop12
    mov ah, 0ch   
    mov al, block_colour    
    mov cx, block_start_col   
    mov dx, block_finish_row
loop13:
    int 10h
    inc cx
    cmp cx, block_finish_col
    jnz loop13
    inc block_start_row
    inc block_finish_row 
    inc bx 
    cmp bx, 12
    jnz loop11
    dec block_start_col
    dec block_start_row
    inc block_finish_col
    inc block_finish_row
    ret  
endp block_shift_down
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shape_shift_right proc
    mov successful_magic_shift, 0H
    mov bx, active_block_num_one[4]
    cmp bx, play_ground_finish_col
    je exit_shape_shift_right
    mov bx, active_block_num_two[4]
    cmp bx, play_ground_finish_col
    je exit_shape_shift_right 
    mov bx, active_block_num_three[4]
    cmp bx, play_ground_finish_col
    je exit_shape_shift_right
    mov bx, active_block_num_four[4]
    cmp bx, play_ground_finish_col
    je exit_shape_shift_right
    mov bx, active_block_num_one[0]
    add bx, 12
    mov block_start_col, bx 
    mov bx, active_block_num_one[2]
    mov block_start_row, bx
    mov bx, active_block_num_one[4]
    add bx, 12
    mov block_finish_col, bx    
    mov bx, active_block_num_one[6]
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_right
    mov bx, active_block_num_two[0]
    add bx, 12
    mov block_start_col, bx    
    mov bx, active_block_num_two[2]
    mov block_start_row, bx
    mov bx, active_block_num_two[4]
    add bx, 12
    mov block_finish_col, bx    
    mov bx, active_block_num_two[6]
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_right 
    mov bx, active_block_num_three[0]
    add bx, 12
    mov block_start_col, bx    
    mov bx, active_block_num_three[2]
    mov block_start_row, bx
    mov bx, active_block_num_three[4]
    add bx, 12
    mov block_finish_col, bx    
    mov bx, active_block_num_three[6]
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_right
    mov bx, active_block_num_four[0]
    add bx, 12
    mov block_start_col, bx    
    mov bx, active_block_num_four[2]
    mov block_start_row, bx
    mov bx, active_block_num_four[4]
    add bx, 12
    mov block_finish_col, bx    
    mov bx, active_block_num_four[6]
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_right                  
    call magic_shift_right
    mov successful_magic_shift, 1H
exit_shape_shift_right:
    mov block_border_colour, 0H 
    call draw_border
    call predict
    ret   
endp shape_shift_right 
shape_shift_left proc
    mov successful_magic_shift, 0H 
    mov bx, active_block_num_one[0]
    cmp bx, play_ground_start_col
    je exit_shape_shift_left
    mov bx, active_block_num_two[0]
    cmp bx, play_ground_start_col
    je exit_shape_shift_left 
    mov bx, active_block_num_three[0]
    cmp bx, play_ground_start_col
    je exit_shape_shift_left
    mov bx, active_block_num_four[0]
    cmp bx, play_ground_start_col
    je exit_shape_shift_left
    mov bx, active_block_num_one[0]
    sub bx, 12
    mov block_start_col, bx 
    mov bx, active_block_num_one[2]
    mov block_start_row, bx
    mov bx, active_block_num_one[4]
    sub bx, 12
    mov block_finish_col, bx    
    mov bx, active_block_num_one[6]
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_left
    mov bx, active_block_num_two[0]
    sub bx, 12
    mov block_start_col, bx    
    mov bx, active_block_num_two[2]
    mov block_start_row, bx
    mov bx, active_block_num_two[4]
    sub bx, 12
    mov block_finish_col, bx    
    mov bx, active_block_num_two[6]
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_left 
    mov bx, active_block_num_three[0]
    sub bx, 12
    mov block_start_col, bx    
    mov bx, active_block_num_three[2]
    mov block_start_row, bx
    mov bx, active_block_num_three[4]
    sub bx, 12
    mov block_finish_col, bx    
    mov bx, active_block_num_three[6]
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_left
    mov bx, active_block_num_four[0]
    sub bx, 12
    mov block_start_col, bx    
    mov bx, active_block_num_four[2]
    mov block_start_row, bx
    mov bx, active_block_num_four[4]
    sub bx, 12
    mov block_finish_col, bx    
    mov bx, active_block_num_four[6]
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_left
    call magic_shift_left
    mov successful_magic_shift, 1H
exit_shape_shift_left:
    mov block_border_colour, 0H 
    call draw_border
    call predict
    ret   
endp shape_shift_left
shape_shift_down proc 
    mov produce_next_shape, 0H
    mov successful_magic_shift, 0H 
    mov bx, active_block_num_one[6]
    cmp bx, play_ground_finish_row
    je exit_shape_shift_down
    mov bx, active_block_num_two[6]
    cmp bx, play_ground_finish_row
    je exit_shape_shift_down 
    mov bx, active_block_num_three[6]
    cmp bx, play_ground_finish_row
    je exit_shape_shift_down
    mov bx, active_block_num_four[6]
    cmp bx, play_ground_finish_row
    je exit_shape_shift_down
    mov bx, active_block_num_one[0]
    mov block_start_col, bx 
    mov bx, active_block_num_one[2]
    add bx, 12
    mov block_start_row, bx
    mov bx, active_block_num_one[4]
    mov block_finish_col, bx    
    mov bx, active_block_num_one[6]
    add bx, 12
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_down
    mov bx, active_block_num_two[0]
    mov block_start_col, bx    
    mov bx, active_block_num_two[2]
    add bx, 12
    mov block_start_row, bx
    mov bx, active_block_num_two[4]
    mov block_finish_col, bx    
    mov bx, active_block_num_two[6]
    add bx, 12
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_down 
    mov bx, active_block_num_three[0]
    mov block_start_col, bx    
    mov bx, active_block_num_three[2]
    add bx, 12
    mov block_start_row, bx
    mov bx, active_block_num_three[4]
    mov block_finish_col, bx    
    mov bx, active_block_num_three[6]
    add bx, 12
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_down
    mov bx, active_block_num_four[0]
    mov block_start_col, bx    
    mov bx, active_block_num_four[2]
    add bx, 12
    mov block_start_row, bx
    mov bx, active_block_num_four[4]
    mov block_finish_col, bx    
    mov bx, active_block_num_four[6]
    add bx, 12
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_down    
    call magic_shift_down
    mov successful_magic_shift, 1H
    jmp exit_shape_shift_down_without_any_produce
exit_shape_shift_down:
    mov produce_next_shape, 1H 
exit_shape_shift_down_without_any_produce:
    ;call predict
    ret
endp shape_shift_down   
shape_shift_up proc 
    mov successful_magic_shift, 0H 
    mov bx, active_block_num_one[2]
    cmp bx, play_ground_start_row
    je exit_shape_shift_up
    mov bx, active_block_num_two[2]
    cmp bx, play_ground_start_row
    je exit_shape_shift_up 
    mov bx, active_block_num_three[2]
    cmp bx, play_ground_start_row
    je exit_shape_shift_up
    mov bx, active_block_num_four[2]
    cmp bx, play_ground_start_row
    je exit_shape_shift_up
    mov bx, active_block_num_one[0]
    mov block_start_col, bx 
    mov bx, active_block_num_one[2]
    sub bx, 12
    mov block_start_row, bx
    mov bx, active_block_num_one[4]
    mov block_finish_col, bx    
    mov bx, active_block_num_one[6]
    sub bx, 12
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_up
    mov bx, active_block_num_two[0]
    mov block_start_col, bx    
    mov bx, active_block_num_two[2]
    sub bx, 12
    mov block_start_row, bx
    mov bx, active_block_num_two[4]
    mov block_finish_col, bx    
    mov bx, active_block_num_two[6]
    sub bx, 12
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_up 
    mov bx, active_block_num_three[0]
    mov block_start_col, bx    
    mov bx, active_block_num_three[2]
    sub bx, 12
    mov block_start_row, bx
    mov bx, active_block_num_three[4]
    mov block_finish_col, bx    
    mov bx, active_block_num_three[6]
    sub bx, 12
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_up
    mov bx, active_block_num_four[0]
    mov block_start_col, bx    
    mov bx, active_block_num_four[2]
    sub bx, 12
    mov block_start_row, bx
    mov bx, active_block_num_four[4]
    mov block_finish_col, bx    
    mov bx, active_block_num_four[6]
    sub bx, 12
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_up    
    call magic_shift_up
    mov successful_magic_shift, 1H
exit_shape_shift_up:
    call predict
    ret
endp shape_shift_up
keyboard_actions proc
    mov ah, 01h
    int 16h
    jz arrow_exit
    mov ah, 00h
    int 16h
    cmp al, 'd'
    je shape_shift_right_label
    cmp al, 'a'
    je  shape_shift_left_label
    cmp al, 's' 
    je shape_shift_down_label 
    cmp al, 'w'
    je shape_rotate_label
    cmp al, 'f'
    je fast_shape_shift_down_label
shape_shift_right_label: 
    call shape_shift_right
    jmp arrow_exit
shape_shift_left_label:
    call shape_shift_left
    jmp arrow_exit 
shape_shift_down_label:
    call shape_shift_down
    jmp arrow_exit                        
shape_rotate_label:
    call shape_rotate
    jmp arrow_exit 
fast_shape_shift_down_label:
fast_loop:
        call shape_shift_down
        cmp successful_magic_shift, 0H
        je arrow_exit
        jmp fast_loop
arrow_exit:
    ret
endp keyboard_actions
genrate_random_number_init proc
   MOV AH, 00h  ; interrupts to get system time        
   INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
   mov  ax, dx
   xor  dx, dx
   mov  cx, 5    
   div  cx       ; here dx contains the remainder of the division - from 0 to 4
   mov random_incoming1_shape_number, dl 
   call delay_2
   MOV AH, 00h  ; interrupts to get system time        
   INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
   mov  ax, dx
   xor  dx, dx
   mov  cx, 5    
   div  cx       ; here dx contains the remainder of the division - from 0 to 4
   mov random_incoming2_shape_number, dl
   ret
endp genrate_random_number_init 
proc display_upcoming_1     
    cmp random_incoming1_shape_number, 0
    je display_upcoming_1_0
    cmp random_incoming1_shape_number, 1
    je display_upcoming_1_1
    cmp random_incoming1_shape_number, 2
    je display_upcoming_1_2
    cmp random_incoming1_shape_number, 3
    je display_upcoming_1_3
    cmp random_incoming1_shape_number, 4
    je display_upcoming_1_4
display_upcoming_1_0:
    mov block_colour, 0EH
    mov block_start_col, 268
    mov block_start_row, 40
    mov block_finish_col, 280
    mov block_finish_row, 52
    call draw_single_block
    mov block_start_col, 268
    mov block_start_row, 52
    mov block_finish_col, 280 
    mov block_finish_row, 64
    call draw_single_block
    mov block_start_col, 280
    mov block_start_row,  40
    mov block_finish_col, 292 
    mov block_finish_row,  52
    call draw_single_block
    mov block_start_col, 280
    mov block_start_row, 52
    mov block_finish_col, 292 
    mov block_finish_row, 64
    call draw_single_block
    jmp display_upcoming_1_exit
display_upcoming_1_1:
    mov block_colour, 9H
    mov block_start_col, 256
    mov block_start_row,  40
    mov block_finish_col, 268
    mov block_finish_row, 52
    call draw_single_block
    mov block_start_col, 268
    mov block_start_row, 40
    mov block_finish_col, 280
    mov block_finish_row, 52
    call draw_single_block
    mov block_start_col, 280
    mov block_start_row, 40
    mov block_finish_col, 292
    mov block_finish_row, 52
    call draw_single_block
    mov block_start_col, 292
    mov block_start_row, 40
    mov block_finish_col, 304
    mov block_finish_row, 52
    call draw_single_block
    jmp display_upcoming_1_exit
display_upcoming_1_2:
    mov block_colour, 2H
    mov block_start_col, 268
    mov block_start_row,  40
    mov block_finish_col, 280
    mov block_finish_row,  52
    call draw_single_block
    mov block_start_col, 268
    mov block_start_row, 52
    mov block_finish_col, 280
    mov block_finish_row, 64
    call draw_single_block
    mov block_start_col, 268
    mov block_start_row, 64
    mov block_finish_col, 280
    mov block_finish_row, 76
    call draw_single_block
    mov block_start_col, 280
    mov block_start_row, 64
    mov block_finish_col, 292
    mov block_finish_row,  76
    call draw_single_block
    jmp display_upcoming_1_exit
display_upcoming_1_3:
    mov block_colour, 4H
    mov block_start_col, 256
    mov block_start_row, 64
    mov block_finish_col, 268
    mov block_finish_row, 76
    call draw_single_block
    mov block_start_col, 268
    mov block_start_row, 64
    mov block_finish_col, 280 
    mov block_finish_row, 76
    call draw_single_block
    mov block_start_col, 268
    mov block_start_row, 52
    mov block_finish_col, 280
    mov block_finish_row,  64
    call draw_single_block
    mov block_start_col, 280
    mov block_start_row,  64
    mov block_finish_col, 292
    mov block_finish_row,  76
    call draw_single_block
    jmp display_upcoming_1_exit
display_upcoming_1_4: 
    mov block_colour, 6H
    mov block_start_col, 268
    mov block_start_row, 40
    mov block_finish_col, 280
    mov block_finish_row, 52
    call draw_single_block
    mov block_start_col, 268
    mov block_start_row, 52
    mov block_finish_col, 280 
    mov block_finish_row,  64
    call draw_single_block
    mov block_start_col, 280
    mov block_start_row,  52
    mov block_finish_col, 292 
    mov block_finish_row,  64
    call draw_single_block
    mov block_start_col, 280
    mov block_start_row, 64
    mov block_finish_col, 292 
    mov block_finish_row,  76
    call draw_single_block
display_upcoming_1_exit:
    ret
endp display_upcoming_1 
proc display_upcoming_2
    cmp random_incoming2_shape_number, 0
    je display_upcoming_2_0
    cmp random_incoming2_shape_number, 1
    je display_upcoming_2_1
    cmp random_incoming2_shape_number, 2
    je display_upcoming_2_2
    cmp random_incoming2_shape_number, 3
    je display_upcoming_2_3
    cmp random_incoming2_shape_number, 4
    je display_upcoming_2_4
display_upcoming_2_0:
    mov block_colour, 0EH
    mov block_start_col, 268
    mov block_start_row, 136
    mov block_finish_col, 280
    mov block_finish_row, 148
    call draw_single_block
    mov block_start_col, 268
    mov block_start_row, 148
    mov block_finish_col, 280 
    mov block_finish_row, 160
    call draw_single_block
    mov block_start_col, 280
    mov block_start_row,  136
    mov block_finish_col, 292 
    mov block_finish_row,  148
    call draw_single_block
    mov block_start_col, 280
    mov block_start_row, 148
    mov block_finish_col, 292 
    mov block_finish_row, 160
    call draw_single_block
    jmp display_upcoming_2_exit
display_upcoming_2_1:
    mov block_colour, 9H
    mov block_start_col, 256
    mov block_start_row,  136
    mov block_finish_col, 268
    mov block_finish_row, 148
    call draw_single_block
    mov block_start_col, 268
    mov block_start_row, 136
    mov block_finish_col, 280
    mov block_finish_row, 148
    call draw_single_block
    mov block_start_col, 280
    mov block_start_row, 136
    mov block_finish_col, 292
    mov block_finish_row, 148
    call draw_single_block
    mov block_start_col, 292
    mov block_start_row, 136
    mov block_finish_col, 304
    mov block_finish_row, 148
    call draw_single_block
    jmp display_upcoming_2_exit
display_upcoming_2_2:
    mov block_colour, 2H
    mov block_start_col, 268
    mov block_start_row,  136
    mov block_finish_col, 280
    mov block_finish_row,  148
    call draw_single_block
    mov block_start_col, 268
    mov block_start_row, 148
    mov block_finish_col, 280
    mov block_finish_row, 160
    call draw_single_block
    mov block_start_col, 268
    mov block_start_row, 160
    mov block_finish_col, 280
    mov block_finish_row, 172
    call draw_single_block
    mov block_start_col, 280
    mov block_start_row, 160
    mov block_finish_col, 292
    mov block_finish_row,  172
    call draw_single_block
    jmp display_upcoming_2_exit
display_upcoming_2_3:
    mov block_colour, 4H
    mov block_start_col, 256
    mov block_start_row, 160
    mov block_finish_col, 268
    mov block_finish_row, 172
    call draw_single_block
    mov block_start_col, 268
    mov block_start_row, 160
    mov block_finish_col, 280 
    mov block_finish_row, 172
    call draw_single_block
    mov block_start_col, 268
    mov block_start_row, 148
    mov block_finish_col, 280
    mov block_finish_row,  160
    call draw_single_block
    mov block_start_col, 280
    mov block_start_row,  160
    mov block_finish_col, 292
    mov block_finish_row,  172
    call draw_single_block
    jmp display_upcoming_2_exit
display_upcoming_2_4: 
    mov block_colour, 6H
    mov block_start_col, 268
    mov block_start_row, 136
    mov block_finish_col, 280
    mov block_finish_row, 148
    call draw_single_block
    mov block_start_col, 268
    mov block_start_row, 148
    mov block_finish_col, 280 
    mov block_finish_row,  160
    call draw_single_block
    mov block_start_col, 280
    mov block_start_row,  148
    mov block_finish_col, 292 
    mov block_finish_row,  160
    call draw_single_block
    mov block_start_col, 280
    mov block_start_row, 160
    mov block_finish_col, 292 
    mov block_finish_row,  172
    call draw_single_block
display_upcoming_2_exit:      
    ret
endp display_upcoming_2 
generate_random_shape proc
   mov bl, random_incoming1_shape_number 
   mov random_shape_number, bl
   mov bl, random_incoming2_shape_number 
   mov random_incoming1_shape_number, bl 
   MOV AH, 00h  ; interrupts to get system time        
   INT 1AH      ; CX:DX now hold number of clock ticks since midnight      
   mov  ax, dx
   xor  dx, dx
   mov  cx, 5    
   div  cx       ; here dx contains the remainder of the division - from 0 to 4
   mov random_incoming2_shape_number, dl
   call clear_upcoming_panel
   call display_upcoming_1
   call display_upcoming_2
   cmp random_shape_number, 0
   je draw_square_block_label
   cmp random_shape_number, 1
   je draw_rectangle_block_label
   cmp random_shape_number, 2
   je draw_L_block_label
   cmp random_shape_number, 3   
   je draw_T_block_label
   cmp random_shape_number, 4  
   je draw_Z_block_label 
draw_square_block_label:
    mov block_colour, 0EH
    mov block_start_col, 148
    mov block_start_row, 4
    mov block_finish_col, 160
    mov block_finish_row, 16  
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je generate_random_shape_set
    mov block_start_col, 160
    mov block_start_row, 4
    mov block_finish_col, 172
    mov block_finish_row, 16
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je generate_random_shape_set
    mov block_start_col, 148
    mov block_start_row, 16
    mov block_finish_col, 160
    mov block_finish_row, 28
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je not_enough_space_label_squ
    mov block_start_col, 160
    mov block_start_row, 16
    mov block_finish_col, 172
    mov block_finish_row, 28
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je not_enough_space_label_squ
   call draw_square_block
   jmp generate_random_shape_exit
draw_rectangle_block_label:
   mov block_colour, 9H 
    mov block_start_col, 136
    mov block_start_row, 4
    mov block_finish_col, 148
    mov block_finish_row, 16
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je generate_random_shape_set
    mov block_start_col, 148
    mov block_start_row, 4
    mov block_finish_col, 160
    mov block_finish_row, 16
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je generate_random_shape_set
    mov block_start_col, 160
    mov block_start_row, 4
    mov block_finish_col, 172
    mov block_finish_row, 16
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je generate_random_shape_set
    mov block_start_col, 172
    mov block_start_row, 4
    mov block_finish_col, 184
    mov block_finish_row, 16
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je generate_random_shape_set
    mov block_start_col, 136
    mov block_start_row, 16
    mov block_finish_col, 148
    mov block_finish_row, 28
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je not_enough_space_label_rec
    mov block_start_col, 148
    mov block_start_row, 16
    mov block_finish_col, 160
    mov block_finish_row, 28
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je not_enough_space_label_rec
    mov block_start_col, 160
    mov block_start_row, 16
    mov block_finish_col, 172
    mov block_finish_row, 28
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je not_enough_space_label_rec
    mov block_start_col, 172
    mov block_start_row, 16
    mov block_finish_col, 184
    mov block_finish_row, 28
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je not_enough_space_label_rec
   call draw_rectangle_block
   jmp generate_random_shape_exit
draw_L_block_label:
    mov block_colour, 2H
    mov block_start_col, 148
    mov block_start_row, 4
    mov block_finish_col, 160
    mov block_finish_row, 16
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je generate_random_shape_set 
    mov block_start_col, 148
    mov block_start_row, 16
    mov block_finish_col, 160
    mov block_finish_row, 28
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je not_enough_space_label_L1 
    mov block_start_col, 148
    mov block_start_row, 28
    mov block_finish_col, 160
    mov block_finish_row, 40
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je not_enough_space_label_L2 
    mov block_start_col, 160
    mov block_start_row, 28
    mov block_finish_col, 172
    mov block_finish_row, 40
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je not_enough_space_label_L2 
   call draw_L_block
   jmp generate_random_shape_exit 
draw_T_block_label: 
    mov block_colour, 4H
    mov block_start_col, 148
    mov block_start_row, 4
    mov block_finish_col, 160
    mov block_finish_row, 16
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je generate_random_shape_set 
    mov block_start_col, 136
    mov block_start_row, 16
    mov block_finish_col, 148
    mov block_finish_row, 28
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je not_enough_space_label_T
    mov block_start_col, 148
    mov block_start_row, 16
    mov block_finish_col, 160
    mov block_finish_row, 28
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je not_enough_space_label_T
    mov block_start_col, 160
    mov block_start_row, 16
    mov block_finish_col, 172
    mov block_finish_row, 28
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je not_enough_space_label_T
   call draw_T_block
   jmp generate_random_shape_exit 
draw_Z_block_label: 
    mov block_colour, 6H
    mov block_start_col, 148
    mov block_start_row, 4
    mov block_finish_col, 160
    mov block_finish_row, 16
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je generate_random_shape_set
    mov block_start_col, 148
    mov block_start_row, 16
    mov block_finish_col, 160
    mov block_finish_row, 28
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je not_enough_space_label_Z1
    mov block_start_col, 160
    mov block_start_row, 16
    mov block_finish_col, 172
    mov block_finish_row, 28
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je not_enough_space_label_Z1
    mov block_start_col, 160
    mov block_start_row, 28
    mov block_finish_col, 172
    mov block_finish_row, 40
    call is_this_block_free_simple
    cmp block_is_free_simple, 0H
    je not_enough_space_label_Z2
   call draw_Z_block
   jmp generate_random_shape_exit
not_enough_space_label_rec: 
   call draw_rectangle_block_2
   jmp generate_random_shape_set 
not_enough_space_label_squ:
    call draw_square_block_2
    jmp generate_random_shape_set 
not_enough_space_label_L1:
    call draw_L_block_2
    jmp generate_random_shape_set 
not_enough_space_label_L2:
    call draw_L_block_3
    jmp generate_random_shape_set 
not_enough_space_label_T:
    call draw_T_block_2
    jmp generate_random_shape_set       
not_enough_space_label_Z1:
    call draw_Z_block_2
    jmp generate_random_shape_set 
not_enough_space_label_Z2:
    call draw_Z_block_3
    jmp generate_random_shape_set      
generate_random_shape_set:
    mov not_enough_space, 1H               
generate_random_shape_exit:
    call predict
    ret
endp generate_random_shape
shape_rotate proc
    mov shift_counter, 0H
    cmp random_shape_number, 0
    je  shape_rotate_exit 
    cmp random_shape_number, 1
    je  four_big_block_rotate 
    cmp random_shape_number, 2
    je  three_big_block_rotate 
    cmp random_shape_number, 3
    je  three_big_block_rotate 
    cmp random_shape_number, 4
    je  three_big_block_rotate
three_big_block_rotate:
    mov bx, active_block_center[0] ;c c s
    cmp bx, play_ground_start_col
    je  three_big_block_rotate_free_first_col
    mov bx, active_block_center[2] ;c r s
    cmp bx, play_ground_start_row
    je  three_big_block_rotate_free_first_row
    mov bx, active_block_center[4] ;c c f
    cmp bx, play_ground_finish_col
    je  three_big_block_rotate_free_finish_col
    mov bx, active_block_center[6] ;c r f
    cmp bx, play_ground_finish_row
    je  three_big_block_rotate_free_finish_row
three_big_block_rotate_check:
    push cx
    ;one  
    mov bx, active_block_num_one[0] ;b0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_center[0] ;y0
    sub bx, cx
    mov block_start_row, bx    
    mov bx, active_block_center[0] ;y0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_num_one[2] ;a0
    sub bx, cx
    mov block_start_col, bx        
    mov bx, active_block_num_one[4] ;b1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_center[4] ;y1
    sub bx, cx
    mov block_finish_row, bx    
    mov bx, active_block_center[4] ;y1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_num_one[6] ;a1
    sub bx, cx
    mov block_finish_col, bx
    call is_this_block_free
    cmp block_is_free, 0H
    je shift_counter_label_one
    jmp three_big_block_rotate_1_two
shift_counter_label_one:
    inc shift_counter
three_big_block_rotate_1_two:    
    ;two
    mov bx, active_block_num_two[0] ;b0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_center[0] ;y0
    sub bx, cx
    mov block_start_row, bx
    mov bx, active_block_center[0] ;y0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_num_two[2] ;a0
    sub bx, cx
    mov block_start_col, bx
    mov bx, active_block_num_two[4] ;b1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_center[4] ;y1
    sub bx, cx
    mov block_finish_row, bx
    mov bx, active_block_center[4] ;y1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_num_two[6] ;a1
    sub bx, cx
    mov block_finish_col, bx    
    call is_this_block_free
    cmp block_is_free, 0H
    je shift_counter_label_two
    jmp three_big_block_rotate_1_three
shift_counter_label_two:
    inc shift_counter
three_big_block_rotate_1_three: 
    ;three 
    mov bx, active_block_num_three[0] ;b0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_center[0] ;y0
    sub bx, cx
    mov block_start_row, bx
    mov bx, active_block_center[0] ;y0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_num_three[2] ;a0
    sub bx, cx
    mov block_start_col, bx
    mov bx, active_block_num_three[4] ;b1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_center[4] ;y1
    sub bx, cx
    mov block_finish_row, bx
    mov bx, active_block_center[4] ;y1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_num_three[6] ;a1
    sub bx, cx
    mov block_finish_col, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je shift_counter_label_three
    jmp three_big_block_rotate_1_four
shift_counter_label_three:
    inc shift_counter
three_big_block_rotate_1_four:    
    ;four  
    mov bx, active_block_num_four[0] ;b0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_center[0] ;y0
    sub bx, cx
    mov block_start_row, bx
    mov bx, active_block_center[0] ;y0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_num_four[2] ;a0
    sub bx, cx
    mov block_start_col, bx
    mov bx, active_block_num_four[4] ;b1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_center[4] ;y1
    sub bx, cx
    mov block_finish_row, bx
    mov bx, active_block_center[4] ;y1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_num_four[6] ;a1
    sub bx, cx
    mov block_finish_col, bx     
    pop cx
    call is_this_block_free
    cmp block_is_free, 0H
    je shift_counter_label_four
    jmp three_big_block_rotate_1_conc
shift_counter_label_four:
    inc shift_counter
three_big_block_rotate_1_conc:
     cmp shift_counter, 0H
     je three_big_block_rotate_1_conc_exit
     ;je three_big_block_rotate_start
     cmp random_shape_number, 2H
     je three_big_block_rotate_1_conc_2
     cmp random_shape_number, 3H
     je three_big_block_rotate_1_conc_3
     cmp random_shape_number, 4H 
     je three_big_block_rotate_1_conc_4 
three_big_block_rotate_1_conc_2:
     cmp position, 1H
     je three_big_block_rotate_1_conc_2_1
     cmp position, 2H
     je three_big_block_rotate_1_conc_2_2
     cmp position, 3H
     je three_big_block_rotate_1_conc_2_3
     cmp position, 4H
     je three_big_block_rotate_1_conc_2_4
three_big_block_rotate_1_conc_2_1: 
    cmp shift_counter, 0H
    je three_big_block_rotate_1_conc_exit
    call shape_shift_left
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    dec shift_counter
three_big_block_rotate_1_conc_2_2:
    cmp shift_counter, 0H
    je three_big_block_rotate_1_conc_exit
    call shape_shift_up
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    dec shift_counter
three_big_block_rotate_1_conc_2_3:
    cmp shift_counter, 0H
    je three_big_block_rotate_1_conc_exit
    call shape_shift_right
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    dec shift_counter
three_big_block_rotate_1_conc_2_4:
    cmp shift_counter, 0H
    je three_big_block_rotate_1_conc_exit
    call shape_shift_down
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    dec shift_counter     
three_big_block_rotate_1_conc_3:
     cmp position, 1H
     je three_big_block_rotate_1_conc_3_1
     cmp position, 2H
     je three_big_block_rotate_1_conc_3_2
     cmp position, 3H
     je three_big_block_rotate_1_conc_3_3
     cmp position, 4H
     je three_big_block_rotate_1_conc_3_4
three_big_block_rotate_1_conc_3_1: 
    cmp shift_counter, 0H
    je three_big_block_rotate_1_conc_exit
    call shape_shift_up
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    dec shift_counter
three_big_block_rotate_1_conc_3_2:
    cmp shift_counter, 0H
    je three_big_block_rotate_1_conc_exit
    call shape_shift_right
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    dec shift_counter     
three_big_block_rotate_1_conc_3_3:
    cmp shift_counter, 0H
    je three_big_block_rotate_1_conc_exit
    call shape_shift_down
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    dec shift_counter
three_big_block_rotate_1_conc_3_4:
    cmp shift_counter, 0H
    je three_big_block_rotate_1_conc_exit
    call shape_shift_left
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    dec shift_counter
three_big_block_rotate_1_conc_4: 
     cmp position, 1H
     je three_big_block_rotate_1_conc_4_1
     cmp position, 2H
     je three_big_block_rotate_1_conc_4_2
     cmp position, 3H
     je three_big_block_rotate_1_conc_4_3
     cmp position, 4H
     je three_big_block_rotate_1_conc_4_4
three_big_block_rotate_1_conc_4_1: 
    cmp shift_counter, 0H
    je three_big_block_rotate_1_conc_exit
    call shape_shift_left
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    dec shift_counter
three_big_block_rotate_1_conc_4_2:
    cmp shift_counter, 0H
    je three_big_block_rotate_1_conc_exit
    call shape_shift_up
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    dec shift_counter   
three_big_block_rotate_1_conc_4_3:
    cmp shift_counter, 0H
    je three_big_block_rotate_1_conc_exit
    call shape_shift_right
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    dec shift_counter
three_big_block_rotate_1_conc_4_4:
    cmp shift_counter, 0H
    je three_big_block_rotate_1_conc_exit
    call shape_shift_down
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    dec shift_counter
three_big_block_rotate_1_conc_exit:
    jmp three_big_block_rotate_start 
three_big_block_rotate_free_first_col:
    call shape_shift_right
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    jmp three_big_block_rotate_start
three_big_block_rotate_free_first_row:    
    call shape_shift_down
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    jmp three_big_block_rotate_start
three_big_block_rotate_free_finish_col:
    call shape_shift_left
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    jmp three_big_block_rotate_start
three_big_block_rotate_free_finish_row:
    call shape_shift_up
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    dec shift_counter 
three_big_block_rotate_start: 
    push cx
    mov bx, active_block_num_one[0] ;b0
    mov block_start_col, bx
    mov bx, active_block_num_one[2] ;a0 
    mov block_start_row, bx
    mov bx, active_block_num_one[4] ;b1
    mov block_finish_col, bx
    mov bx, active_block_num_one[6] ;a1
    mov block_finish_row, bx
    call erase_single_block  
    mov bx, active_block_num_two[0] ;b0
    mov block_start_col, bx
    mov bx, active_block_num_two[2] ;a0 
    mov block_start_row, bx
    mov bx, active_block_num_two[4] ;b1
    mov block_finish_col, bx
    mov bx, active_block_num_two[6] ;a1
    mov block_finish_row, bx
    call erase_single_block 
    mov bx, active_block_num_three[0] ;b0
    mov block_start_col, bx
    mov bx, active_block_num_three[2] ;a0 
    mov block_start_row, bx
    mov bx, active_block_num_three[4] ;b1
    mov block_finish_col, bx
    mov bx, active_block_num_three[6] ;a1
    mov block_finish_row, bx
    call erase_single_block
    mov bx, active_block_num_four[0] ;b0
    mov block_start_col, bx
    mov bx, active_block_num_four[2] ;a0 
    mov block_start_row, bx
    mov bx, active_block_num_four[4] ;b1
    mov block_finish_col, bx
    mov bx, active_block_num_four[6] ;a1
    mov block_finish_row, bx
    call erase_single_block   
    ;one  
    mov bx, active_block_num_one[0] ;b0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_center[0] ;y0
    sub bx, cx
    mov block_start_row, bx
    mov bx, active_block_center[0] ;y0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_num_one[2] ;a0
    sub bx, cx
    mov block_start_col, bx
    mov bx, active_block_num_one[4] ;b1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_center[4] ;y1
    sub bx, cx
    mov block_finish_row, bx
    mov bx, active_block_center[4] ;y1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_num_one[6] ;a1
    sub bx, cx
    mov block_finish_col, bx
    call draw_single_block
    call fill_array_num_one
    ;two
    mov bx, active_block_num_two[0] ;b0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_center[0] ;y0
    sub bx, cx
    mov block_start_row, bx
    mov bx, active_block_center[0] ;y0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_num_two[2] ;a0
    sub bx, cx
    mov block_start_col, bx
    mov bx, active_block_num_two[4] ;b1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_center[4] ;y1
    sub bx, cx
    mov block_finish_row, bx
    mov bx, active_block_center[4] ;y1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_num_two[6] ;a1
    sub bx, cx
    mov block_finish_col, bx    
    call draw_single_block
    call fill_array_num_two
    ;three 
    mov bx, active_block_num_three[0] ;b0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_center[0] ;y0
    sub bx, cx
    mov block_start_row, bx
    mov bx, active_block_center[0] ;y0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_num_three[2] ;a0
    sub bx, cx
    mov block_start_col, bx
    mov bx, active_block_num_three[4] ;b1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_center[4] ;y1
    sub bx, cx
    mov block_finish_row, bx
    mov bx, active_block_center[4] ;y1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_num_three[6] ;a1
    sub bx, cx
    mov block_finish_col, bx
    call draw_single_block
    call fill_array_num_three
    ;four  
    mov bx, active_block_num_four[0] ;b0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_center[0] ;y0
    sub bx, cx
    mov block_start_row, bx
    mov bx, active_block_center[0] ;y0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_num_four[2] ;a0
    sub bx, cx
    mov block_start_col, bx
    mov bx, active_block_num_four[4] ;b1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_center[4] ;y1
    sub bx, cx
    mov block_finish_row, bx
    mov bx, active_block_center[4] ;y1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_num_four[6] ;a1
    sub bx, cx
    mov block_finish_col, bx     
    call draw_single_block
    call fill_array_num_four
    pop cx
    jmp shape_rotate_exit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;      
four_big_block_rotate:  
    mov bx, active_block_num_two[0] ; c s   
    cmp bx, play_ground_start_col 
    je four_big_block_rotate_free_first_col_label 
    mov bx, active_block_num_two[4] ; c f   
    cmp bx, play_ground_finish_col
    je four_big_block_rotate_free_finish_col_label
    mov bx, active_block_num_two[6] ; r f   
    cmp bx, play_ground_finish_row
    je four_big_block_rotate_free_finish_row_label
    ;jmp four_big_block_rotate_start            
    ;push cx
    ;one  
    mov bx, active_block_num_one[0] ;b0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_center[0] ;y0
    sub bx, cx
    mov block_start_row, bx
    mov bx, active_block_center[0] ;y0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_num_one[2] ;a0
    sub bx, cx
    mov block_finish_col, bx
    mov bx, active_block_num_one[4] ;b1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_center[4] ;y1
    sub bx, cx
    mov block_finish_row, bx
    mov bx, active_block_center[4] ;y1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_num_one[6] ;a1
    sub bx, cx
    mov block_start_col, bx
    call is_this_block_free
    cmp block_is_free, 0H
    je four_big_block_conc
    ;two
    mov bx, active_block_num_two[0] ;b0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_center[0] ;y0
    sub bx, cx
    mov block_start_row, bx
    mov bx, active_block_center[0] ;y0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_num_two[2] ;a0
    sub bx, cx
    mov block_finish_col, bx
    mov bx, active_block_num_two[4] ;b1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_center[4] ;y1
    sub bx, cx
    mov block_finish_row, bx
    mov bx, active_block_center[4] ;y1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_num_two[6] ;a1
    sub bx, cx
    mov block_start_col, bx    
    call is_this_block_free
    cmp block_is_free, 0H
    je four_big_block_conc
    ;three 
    mov bx, active_block_num_three[0] ;b0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_center[0] ;y0
    sub bx, cx
    mov block_start_row, bx
    mov bx, active_block_center[0] ;y0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_num_three[2] ;a0
    sub bx, cx
    mov block_finish_col, bx
    mov bx, active_block_num_three[4] ;b1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_center[4] ;y1
    sub bx, cx
    mov block_finish_row, bx
    mov bx, active_block_center[4] ;y1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_num_three[6] ;a1
    sub bx, cx
    mov block_start_col, bx
    call is_this_block_free
    cmp block_is_free, 0H
    je four_big_block_conc
    ;four  
    mov bx, active_block_num_four[0] ;b0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_center[0] ;y0
    sub bx, cx
    mov block_start_row, bx
    mov bx, active_block_center[0] ;y0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_num_four[2] ;a0
    sub bx, cx
    mov block_finish_col, bx
    mov bx, active_block_num_four[4] ;b1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_center[4] ;y1
    sub bx, cx
    mov block_finish_row, bx
    mov bx, active_block_center[4] ;y1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_num_four[6] ;a1
    sub bx, cx
    mov block_start_col, bx       
    ;pop cx
    call is_this_block_free
    cmp block_is_free, 0H
    je four_big_block_conc
    jmp four_big_block_rotate_start
four_big_block_conc: 
     cmp position, 1H
     je four_big_block_conc_1
     cmp position, 2H
     je four_big_block_conc_2
     cmp position, 3H
     je four_big_block_conc_3
     cmp position, 4H
     je four_big_block_conc_4
     jmp four_big_block_rotate_start
four_big_block_conc_1:
    cmp shift_counter, 0H
    call shape_shift_left
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    jmp four_big_block_rotate_start
four_big_block_conc_2:
    cmp shift_counter, 0H
    call shape_shift_up
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    jmp four_big_block_rotate_start
four_big_block_conc_3:
    cmp shift_counter, 0H
    call shape_shift_right
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    jmp four_big_block_rotate_start
four_big_block_conc_4: 
    cmp shift_counter, 0H
    call shape_shift_down
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    jmp four_big_block_rotate_start
four_big_block_rotate_free_first_col_label:   
    mov bx, active_block_center[0] ;c c s
    sub bx, 12
    cmp bx, play_ground_start_col
    je  four_big_block_rotate_free_first_col 
    mov bx, active_block_center[0] ;c c s
    cmp bx, play_ground_start_col
    je  four_big_block_rotate_free_first_col_2
    jmp four_big_block_rotate_start
four_big_block_rotate_free_finish_col_label:    
    mov bx, active_block_center[4] ;c c f
    add bx, 12
    cmp bx, play_ground_finish_col
    je  four_big_block_rotate_free_finish_col 
    mov bx, active_block_center[4] ;c c f
    cmp bx, play_ground_finish_col
    je  four_big_block_rotate_free_finish_col_2
    jmp four_big_block_rotate_start
four_big_block_rotate_free_finish_row_label:    
    mov bx, active_block_center[6] ;c r f
    add bx, 12
    cmp bx, play_ground_finish_row
    je  four_big_block_rotate_free_finish_row
    mov bx, active_block_center[6] ;c r f
    cmp bx, play_ground_finish_row
    je  four_big_block_rotate_free_finish_row_2  
    jmp four_big_block_rotate_start 
four_big_block_rotate_free_first_col: 
    call shape_shift_right
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    jmp four_big_block_rotate_start 
four_big_block_rotate_free_first_col_2: 
    call shape_shift_right
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    call shape_shift_right
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    jmp four_big_block_rotate_start
four_big_block_rotate_free_finish_col:     
    call shape_shift_left
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    jmp four_big_block_rotate_start 
four_big_block_rotate_free_finish_col_2:     
    call shape_shift_left
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    call shape_shift_left
    cmp successful_magic_shift, 0H 
    je shape_rotate_exit
    jmp four_big_block_rotate_start
four_big_block_rotate_free_finish_row:
    call magic_shift_up 
    jmp four_big_block_rotate_start
four_big_block_rotate_free_finish_row_2:
    call magic_shift_up
    call magic_shift_up  
    jmp four_big_block_rotate_start
four_big_block_rotate_start:
    push cx
    mov bx, active_block_num_one[0] ;b0
    mov block_start_col, bx
    mov bx, active_block_num_one[2] ;a0 
    mov block_start_row, bx
    mov bx, active_block_num_one[4] ;b1
    mov block_finish_col, bx
    mov bx, active_block_num_one[6] ;a1
    mov block_finish_row, bx
    call erase_single_block  
    mov bx, active_block_num_two[0] ;b0
    mov block_start_col, bx
    mov bx, active_block_num_two[2] ;a0 
    mov block_start_row, bx
    mov bx, active_block_num_two[4] ;b1
    mov block_finish_col, bx
    mov bx, active_block_num_two[6] ;a1
    mov block_finish_row, bx
    call erase_single_block 
    mov bx, active_block_num_three[0] ;b0
    mov block_start_col, bx
    mov bx, active_block_num_three[2] ;a0 
    mov block_start_row, bx
    mov bx, active_block_num_three[4] ;b1
    mov block_finish_col, bx
    mov bx, active_block_num_three[6] ;a1
    mov block_finish_row, bx
    call erase_single_block
    mov bx, active_block_num_four[0] ;b0
    mov block_start_col, bx
    mov bx, active_block_num_four[2] ;a0 
    mov block_start_row, bx
    mov bx, active_block_num_four[4] ;b1
    mov block_finish_col, bx
    mov bx, active_block_num_four[6] ;a1
    mov block_finish_row, bx
    call erase_single_block   
    ;one  
    mov bx, active_block_num_one[0] ;b0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_center[0] ;y0
    sub bx, cx
    mov block_start_row, bx
    mov bx, active_block_center[0] ;y0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_num_one[2] ;a0
    sub bx, cx
    mov block_finish_col, bx
    mov bx, active_block_num_one[4] ;b1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_center[4] ;y1
    sub bx, cx
    mov block_finish_row, bx
    mov bx, active_block_center[4] ;y1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_num_one[6] ;a1
    sub bx, cx
    mov block_start_col, bx
    call draw_single_block
    call fill_array_num_one
    ;two
    mov bx, active_block_num_two[0] ;b0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_center[0] ;y0
    sub bx, cx
    mov block_start_row, bx
    mov bx, active_block_center[0] ;y0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_num_two[2] ;a0
    sub bx, cx
    mov block_finish_col, bx
    mov bx, active_block_num_two[4] ;b1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_center[4] ;y1
    sub bx, cx
    mov block_finish_row, bx
    mov bx, active_block_center[4] ;y1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_num_two[6] ;a1
    sub bx, cx
    mov block_start_col, bx    
    call draw_single_block
    call fill_array_num_two
    ;three 
    mov bx, active_block_num_three[0] ;b0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_center[0] ;y0
    sub bx, cx
    mov block_start_row, bx
    mov bx, active_block_center[0] ;y0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_num_three[2] ;a0
    sub bx, cx
    mov block_finish_col, bx
    mov bx, active_block_num_three[4] ;b1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_center[4] ;y1
    sub bx, cx
    mov block_finish_row, bx
    mov bx, active_block_center[4] ;y1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_num_three[6] ;a1
    sub bx, cx
    mov block_start_col, bx
    call draw_single_block
    call fill_array_num_three
    ;four  
    mov bx, active_block_num_four[0] ;b0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_center[0] ;y0
    sub bx, cx
    mov block_start_row, bx
    mov bx, active_block_center[0] ;y0
    mov cx, active_block_center[2] ;x0
    add bx, cx
    mov cx, active_block_num_four[2] ;a0
    sub bx, cx
    mov block_finish_col, bx
    mov bx, active_block_num_four[4] ;b1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_center[4] ;y1
    sub bx, cx
    mov block_finish_row, bx
    mov bx, active_block_center[4] ;y1
    mov cx, active_block_center[6] ;x1
    add bx, cx
    mov cx, active_block_num_four[6] ;a1
    sub bx, cx
    mov block_start_col, bx     
    call draw_single_block
    call fill_array_num_four
    pop cx
    jmp shape_rotate_exit
revert_position:
    mov position, 1H
    jmp shape_rotate_exit_final    
shape_rotate_exit:
       inc position
       cmp position, 5H
       je revert_position
shape_rotate_exit_final:
    mov block_border_colour, 0H 
    call draw_border
    call predict
      ret
endp shape_rotate  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
magic_shift_right proc
    mov bx, active_block_num_one[0]
    mov block_start_col, bx 
    mov bx, active_block_num_one[2]
    mov block_start_row, bx 
    mov bx, active_block_num_one[4]
    mov block_finish_col, bx 
    mov bx, active_block_num_one[6]
    mov block_finish_row, bx
    call erase_single_block
    mov bx, active_block_num_two[0]
    mov block_start_col, bx   
    mov bx, active_block_num_two[2]
    mov block_start_row, bx  
    mov bx, active_block_num_two[4]
    mov block_finish_col, bx  
    mov bx, active_block_num_two[6]
    mov block_finish_row, bx
    call erase_single_block
    mov bx, active_block_num_three[0]
    mov block_start_col, bx   
    mov bx, active_block_num_three[2]
    mov block_start_row, bx 
    mov bx, active_block_num_three[4]
    mov block_finish_col, bx
    mov bx, active_block_num_three[6]
    mov block_finish_row, bx
    call erase_single_block
    mov bx, active_block_num_four[0]
    mov block_start_col, bx
    mov bx, active_block_num_four[2]
    mov block_start_row, bx 
    mov bx, active_block_num_four[4]
    mov block_finish_col, bx 
    mov bx, active_block_num_four[6]
    mov block_finish_row, bx
    call erase_single_block 
    mov bx, active_block_num_one[0]
    mov block_start_col, bx
    add block_start_col, 12
    mov bx, active_block_num_one[2]
    mov block_start_row, bx
    ;add block_start_row, 12  
    mov bx, active_block_num_one[4]
    mov block_finish_col, bx
    add block_finish_col, 12   
    mov bx, active_block_num_one[6]
    mov block_finish_row, bx
    ;add block_finish_row, 12
    call draw_single_block
    call fill_array_num_one
    mov bx, active_block_num_two[0]
    mov block_start_col, bx
    add block_start_col, 12
    mov bx, active_block_num_two[2]
    mov block_start_row, bx
    ;add block_start_row, 12  
    mov bx, active_block_num_two[4]
    mov block_finish_col, bx
    add block_finish_col, 12   
    mov bx, active_block_num_two[6]
    mov block_finish_row, bx
    ;add block_finish_row, 12
    call draw_single_block
    call fill_array_num_two
    mov bx, active_block_num_three[0]
    mov block_start_col, bx
    add block_start_col, 12
    mov bx, active_block_num_three[2]
    mov block_start_row, bx
    ;add block_start_row, 12  
    mov bx, active_block_num_three[4]
    mov block_finish_col, bx
    add block_finish_col, 12   
    mov bx, active_block_num_three[6]
    mov block_finish_row, bx
    ;add block_finish_row, 12
    call draw_single_block
    call fill_array_num_three
    mov bx, active_block_num_four[0]
    mov block_start_col, bx
    add block_start_col, 12
    mov bx, active_block_num_four[2]
    mov block_start_row, bx
    ;add block_start_row, 12  
    mov bx, active_block_num_four[4]
    mov block_finish_col, bx
    add block_finish_col, 12   
    mov bx, active_block_num_four[6]
    mov block_finish_row, bx
    ;add block_finish_row, 12
    call draw_single_block
    call fill_array_num_four
    mov bx, active_block_center[0]
    mov block_start_col, bx
    add block_start_col, 12
    mov bx, active_block_center[2]
    mov block_start_row, bx
    ;add block_start_row, 12  
    mov bx, active_block_center[4]
    mov block_finish_col, bx
    add block_finish_col, 12   
    mov bx, active_block_center[6]
    mov block_finish_row, bx
    ;add block_finish_row, 12
    call fill_center_block
    ret
endp  magic_shift_right
magic_shift_left proc
    mov bx, active_block_num_one[0]
    mov block_start_col, bx 
    mov bx, active_block_num_one[2]
    mov block_start_row, bx 
    mov bx, active_block_num_one[4]
    mov block_finish_col, bx 
    mov bx, active_block_num_one[6]
    mov block_finish_row, bx
    call erase_single_block
    mov bx, active_block_num_two[0]
    mov block_start_col, bx   
    mov bx, active_block_num_two[2]
    mov block_start_row, bx  
    mov bx, active_block_num_two[4]
    mov block_finish_col, bx  
    mov bx, active_block_num_two[6]
    mov block_finish_row, bx
    call erase_single_block
    mov bx, active_block_num_three[0]
    mov block_start_col, bx   
    mov bx, active_block_num_three[2]
    mov block_start_row, bx 
    mov bx, active_block_num_three[4]
    mov block_finish_col, bx
    mov bx, active_block_num_three[6]
    mov block_finish_row, bx
    call erase_single_block
    mov bx, active_block_num_four[0]
    mov block_start_col, bx
    mov bx, active_block_num_four[2]
    mov block_start_row, bx 
    mov bx, active_block_num_four[4]
    mov block_finish_col, bx 
    mov bx, active_block_num_four[6]
    mov block_finish_row, bx
    call erase_single_block 
    mov bx, active_block_num_one[0]
    mov block_start_col, bx
    sub block_start_col, 12
    mov bx, active_block_num_one[2]
    mov block_start_row, bx
    ;add block_start_row, 12  
    mov bx, active_block_num_one[4]
    mov block_finish_col, bx
    sub block_finish_col, 12   
    mov bx, active_block_num_one[6]
    mov block_finish_row, bx
    ;add block_finish_row, 12
    call draw_single_block
    call fill_array_num_one
    mov bx, active_block_num_two[0]
    mov block_start_col, bx
    sub block_start_col, 12
    mov bx, active_block_num_two[2]
    mov block_start_row, bx
    ;add block_start_row, 12  
    mov bx, active_block_num_two[4]
    mov block_finish_col, bx
    sub block_finish_col, 12   
    mov bx, active_block_num_two[6]
    mov block_finish_row, bx
    ;add block_finish_row, 12
    call draw_single_block
    call fill_array_num_two
    mov bx, active_block_num_three[0]
    mov block_start_col, bx
    sub block_start_col, 12
    mov bx, active_block_num_three[2]
    mov block_start_row, bx
    ;add block_start_row, 12  
    mov bx, active_block_num_three[4]
    mov block_finish_col, bx
    sub block_finish_col, 12   
    mov bx, active_block_num_three[6]
    mov block_finish_row, bx
    ;add block_finish_row, 12
    call draw_single_block
    call fill_array_num_three
    mov bx, active_block_num_four[0]
    mov block_start_col, bx
    sub block_start_col, 12
    mov bx, active_block_num_four[2]
    mov block_start_row, bx
    ;add block_start_row, 12  
    mov bx, active_block_num_four[4]
    mov block_finish_col, bx
    sub block_finish_col, 12   
    mov bx, active_block_num_four[6]
    mov block_finish_row, bx
    ;add block_finish_row, 12
    call draw_single_block
    call fill_array_num_four 
    mov bx, active_block_center[0]
    mov block_start_col, bx
    sub block_start_col, 12
    mov bx, active_block_center[2]
    mov block_start_row, bx
    ;add block_start_row, 12  
    mov bx, active_block_center[4]
    mov block_finish_col, bx
    sub block_finish_col, 12   
    mov bx, active_block_center[6]
    mov block_finish_row, bx
    ;add block_finish_row, 12
    call fill_center_block 
    ret
endp  magic_shift_left
magic_shift_down proc
    mov bx, active_block_num_one[0]
    mov block_start_col, bx 
    mov bx, active_block_num_one[2]
    mov block_start_row, bx 
    mov bx, active_block_num_one[4]
    mov block_finish_col, bx 
    mov bx, active_block_num_one[6]
    mov block_finish_row, bx
    call erase_single_block
    mov bx, active_block_num_two[0]
    mov block_start_col, bx   
    mov bx, active_block_num_two[2]
    mov block_start_row, bx  
    mov bx, active_block_num_two[4]
    mov block_finish_col, bx  
    mov bx, active_block_num_two[6]
    mov block_finish_row, bx
    call erase_single_block
    mov bx, active_block_num_three[0]
    mov block_start_col, bx   
    mov bx, active_block_num_three[2]
    mov block_start_row, bx 
    mov bx, active_block_num_three[4]
    mov block_finish_col, bx
    mov bx, active_block_num_three[6]
    mov block_finish_row, bx
    call erase_single_block
    mov bx, active_block_num_four[0]
    mov block_start_col, bx
    mov bx, active_block_num_four[2]
    mov block_start_row, bx 
    mov bx, active_block_num_four[4]
    mov block_finish_col, bx 
    mov bx, active_block_num_four[6]
    mov block_finish_row, bx
    call erase_single_block 
    mov bx, active_block_num_one[0]
    mov block_start_col, bx
    ;sub block_start_col, 12
    mov bx, active_block_num_one[2]
    mov block_start_row, bx
    add block_start_row, 12  
    mov bx, active_block_num_one[4]
    mov block_finish_col, bx
    ;sub block_finish_col, 12   
    mov bx, active_block_num_one[6]
    mov block_finish_row, bx
    add block_finish_row, 12
    call draw_single_block
    call fill_array_num_one
    mov bx, active_block_num_two[0]
    mov block_start_col, bx
    ;sub block_start_col, 12
    mov bx, active_block_num_two[2]
    mov block_start_row, bx
    add block_start_row, 12  
    mov bx, active_block_num_two[4]
    mov block_finish_col, bx
    ;sub block_finish_col, 12   
    mov bx, active_block_num_two[6]
    mov block_finish_row, bx
    add block_finish_row, 12
    call draw_single_block
    call fill_array_num_two
    mov bx, active_block_num_three[0]
    mov block_start_col, bx
    ;sub block_start_col, 12
    mov bx, active_block_num_three[2]
    mov block_start_row, bx
    add block_start_row, 12  
    mov bx, active_block_num_three[4]
    mov block_finish_col, bx
    ;sub block_finish_col, 12   
    mov bx, active_block_num_three[6]
    mov block_finish_row, bx
    add block_finish_row, 12
    call draw_single_block
    call fill_array_num_three
    mov bx, active_block_num_four[0]
    mov block_start_col, bx
    ;sub block_start_col, 12
    mov bx, active_block_num_four[2]
    mov block_start_row, bx
    add block_start_row, 12  
    mov bx, active_block_num_four[4]
    mov block_finish_col, bx
    ;sub block_finish_col, 12   
    mov bx, active_block_num_four[6]
    mov block_finish_row, bx
    add block_finish_row, 12
    call draw_single_block
    call fill_array_num_four 
    mov bx, active_block_center[0]
    mov block_start_col, bx
    ;sub block_start_col, 12
    mov bx, active_block_center[2]
    mov block_start_row, bx
    add block_start_row, 12  
    mov bx, active_block_center[4]
    mov block_finish_col, bx
    ;sub block_finish_col, 12   
    mov bx, active_block_center[6]
    mov block_finish_row, bx
    add block_finish_row, 12
    call fill_center_block
    ret
endp  magic_shift_down
magic_shift_up proc
    mov bx, active_block_num_one[0]
    mov block_start_col, bx 
    mov bx, active_block_num_one[2]
    mov block_start_row, bx 
    mov bx, active_block_num_one[4]
    mov block_finish_col, bx 
    mov bx, active_block_num_one[6]
    mov block_finish_row, bx
    call erase_single_block
    mov bx, active_block_num_two[0]
    mov block_start_col, bx   
    mov bx, active_block_num_two[2]
    mov block_start_row, bx  
    mov bx, active_block_num_two[4]
    mov block_finish_col, bx  
    mov bx, active_block_num_two[6]
    mov block_finish_row, bx
    call erase_single_block
    mov bx, active_block_num_three[0]
    mov block_start_col, bx   
    mov bx, active_block_num_three[2]
    mov block_start_row, bx 
    mov bx, active_block_num_three[4]
    mov block_finish_col, bx
    mov bx, active_block_num_three[6]
    mov block_finish_row, bx
    call erase_single_block
    mov bx, active_block_num_four[0]
    mov block_start_col, bx
    mov bx, active_block_num_four[2]
    mov block_start_row, bx 
    mov bx, active_block_num_four[4]
    mov block_finish_col, bx 
    mov bx, active_block_num_four[6]
    mov block_finish_row, bx
    call erase_single_block 
    mov bx, active_block_num_one[0]
    mov block_start_col, bx
    ;sub block_start_col, 12
    mov bx, active_block_num_one[2]
    mov block_start_row, bx
    sub block_start_row, 12  
    mov bx, active_block_num_one[4]
    mov block_finish_col, bx
    ;sub block_finish_col, 12   
    mov bx, active_block_num_one[6]
    mov block_finish_row, bx
    sub block_finish_row, 12
    call draw_single_block
    call fill_array_num_one
    mov bx, active_block_num_two[0]
    mov block_start_col, bx
    ;sub block_start_col, 12
    mov bx, active_block_num_two[2]
    mov block_start_row, bx
    sub block_start_row, 12  
    mov bx, active_block_num_two[4]
    mov block_finish_col, bx
    ;sub block_finish_col, 12   
    mov bx, active_block_num_two[6]
    mov block_finish_row, bx
    sub block_finish_row, 12
    call draw_single_block
    call fill_array_num_two
    mov bx, active_block_num_three[0]
    mov block_start_col, bx
    ;sub block_start_col, 12
    mov bx, active_block_num_three[2]
    mov block_start_row, bx
    sub block_start_row, 12  
    mov bx, active_block_num_three[4]
    mov block_finish_col, bx
    ;sub block_finish_col, 12   
    mov bx, active_block_num_three[6]
    mov block_finish_row, bx
    sub block_finish_row, 12
    call draw_single_block
    call fill_array_num_three
    mov bx, active_block_num_four[0]
    mov block_start_col, bx
    ;sub block_start_col, 12
    mov bx, active_block_num_four[2]
    mov block_start_row, bx
    sub block_start_row, 12  
    mov bx, active_block_num_four[4]
    mov block_finish_col, bx
    ;sub block_finish_col, 12   
    mov bx, active_block_num_four[6]
    mov block_finish_row, bx
    sub block_finish_row, 12
    call draw_single_block
    call fill_array_num_four 
    mov bx, active_block_center[0]
    mov block_start_col, bx
    ;sub block_start_col, 12
    mov bx, active_block_center[2]
    mov block_start_row, bx
    sub block_start_row, 12  
    mov bx, active_block_center[4]
    mov block_finish_col, bx
    ;sub block_finish_col, 12   
    mov bx, active_block_center[6]
    mov block_finish_row, bx
    sub block_finish_row, 12
    call fill_center_block 
    ret
endp  magic_shift_up 
proc display_score     
    mov ah, 02H
    mov bh, 00H
    mov dh, 04H
    mov dl, 01H    
    int 10h
    mov ah, 09H
    lea dx, msg_score
    int 21h  
    ret
endp display_score
proc update_score 
    xor ax, ax
    mov si, 9 
    mov ax, score
    mov bx, 10
label:
    cmp si, 5
    je exit_label
    xor dx, dx
    div bx
    add dx, 30h
    mov [msg_score+si], dl
    dec si
    jmp label
exit_label:
    call display_score 
    ret
endp update_score 
shape_shift_down_pred proc 
    mov successful_magic_shift_pred, 0H 
    mov bx, active_block_num_one_pred[6]
    cmp bx, play_ground_finish_row
    je exit_shape_shift_down_pred
    mov bx, active_block_num_two_pred[6]
    cmp bx, play_ground_finish_row
    je exit_shape_shift_down_pred 
    mov bx, active_block_num_three_pred[6]
    cmp bx, play_ground_finish_row
    je exit_shape_shift_down_pred
    mov bx, active_block_num_four_pred[6]
    cmp bx, play_ground_finish_row
    je exit_shape_shift_down_pred
    mov bx, active_block_num_one_pred[0]
    mov block_start_col, bx 
    mov bx, active_block_num_one_pred[2]
    add bx, 12
    mov block_start_row, bx
    mov bx, active_block_num_one_pred[4]
    mov block_finish_col, bx    
    mov bx, active_block_num_one_pred[6]
    add bx, 12
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_down_pred
    mov bx, active_block_num_two_pred[0]
    mov block_start_col, bx    
    mov bx, active_block_num_two_pred[2]
    add bx, 12
    mov block_start_row, bx
    mov bx, active_block_num_two_pred[4]
    mov block_finish_col, bx    
    mov bx, active_block_num_two_pred[6]
    add bx, 12
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_down_pred 
    mov bx, active_block_num_three_pred[0]
    mov block_start_col, bx    
    mov bx, active_block_num_three_pred[2]
    add bx, 12
    mov block_start_row, bx
    mov bx, active_block_num_three_pred[4]
    mov block_finish_col, bx    
    mov bx, active_block_num_three_pred[6]
    add bx, 12
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_down_pred
    mov bx, active_block_num_four_pred[0]
    mov block_start_col, bx    
    mov bx, active_block_num_four_pred[2]
    add bx, 12
    mov block_start_row, bx
    mov bx, active_block_num_four_pred[4]
    mov block_finish_col, bx    
    mov bx, active_block_num_four_pred[6]
    add bx, 12
    mov block_finish_row, bx 
    call is_this_block_free
    cmp block_is_free, 0H
    je exit_shape_shift_down_pred    
    call magic_shift_down_pred
    mov successful_magic_shift_pred, 1H
exit_shape_shift_down_pred:
    ret
endp shape_shift_down_pred
magic_shift_down_pred proc
    mov bx, active_block_num_one_pred[0]
    mov block_start_col, bx
    ;sub block_start_col, 12
    mov bx, active_block_num_one_pred[2]
    mov block_start_row, bx
    add block_start_row, 12
    mov bx, block_start_row
    mov active_block_num_one_pred[2], bx  
    mov bx, active_block_num_one_pred[4]
    mov block_finish_col, bx 
    ;sub block_finish_col, 12   
    mov bx, active_block_num_one_pred[6]
    mov block_finish_row, bx
    add block_finish_row, 12
    mov bx, block_finish_row
    mov active_block_num_one_pred[6], bx  
    mov bx, active_block_num_two_pred[0]
    mov block_start_col, bx
    ;sub block_start_col, 12
    mov bx, active_block_num_two_pred[2]
    mov block_start_row, bx
    add block_start_row, 12
    mov bx, block_start_row
    mov active_block_num_two_pred[2], bx    
    mov bx, active_block_num_two_pred[4]
    mov block_finish_col, bx
    ;sub block_finish_col, 12   
    mov bx, active_block_num_two_pred[6]
    mov block_finish_row, bx
    add block_finish_row, 12
    mov bx, block_finish_row
    mov active_block_num_two_pred[6], bx 
    mov bx, active_block_num_three_pred[0]
    mov block_start_col, bx
    ;sub block_start_col, 12
    mov bx, active_block_num_three_pred[2]
    mov block_start_row, bx
    add block_start_row, 12
    mov bx, block_start_row
    mov active_block_num_three_pred[2], bx    
    mov bx, active_block_num_three_pred[4]
    mov block_finish_col, bx
    ;sub block_finish_col, 12   
    mov bx, active_block_num_three_pred[6]
    mov block_finish_row, bx
    add block_finish_row, 12
    mov bx, block_finish_row
    mov active_block_num_three_pred[6], bx 
    mov bx, active_block_num_four_pred[0]
    mov block_start_col, bx
    ;sub block_start_col, 12
    mov bx, active_block_num_four_pred[2]
    mov block_start_row, bx
    add block_start_row, 12
    mov bx, block_start_row
    mov active_block_num_four_pred[2], bx    
    mov bx, active_block_num_four_pred[4]
    mov block_finish_col, bx
    ;sub block_finish_col, 12   
    mov bx, active_block_num_four_pred[6]
    mov block_finish_row, bx
    add block_finish_row, 12
    mov bx, block_finish_row
    mov active_block_num_four_pred[6], bx 
    ;mov bx, active_block_center[0]
    ;mov block_start_col, bx
    ;sub block_start_col, 12
    ;mov bx, active_block_center[2]
    ;mov block_start_row, bx
    ;add block_start_row, 12  
    ;mov bx, active_block_center[4]
    ;mov block_finish_col, bx
    ;sub block_finish_col, 12   
    ;mov bx, active_block_center[6]
    ;mov block_finish_row, bx
    ;add block_finish_row, 12
    ret
endp  magic_shift_down_pred
proc predict
        mov bx, active_block_num_one[0]  
        mov active_block_num_one_pred[0], bx
        mov bx, active_block_num_one[2]  
        mov active_block_num_one_pred[2], bx 
        mov bx, active_block_num_one[4]  
        mov active_block_num_one_pred[4], bx 
        mov bx, active_block_num_one[6]  
        mov active_block_num_one_pred[6], bx 
        mov bx, active_block_num_two[0] 
        mov active_block_num_two_pred[0], bx 
        mov bx, active_block_num_two[2] 
        mov active_block_num_two_pred[2], bx
        mov bx, active_block_num_two[4] 
        mov active_block_num_two_pred[4], bx
        mov bx, active_block_num_two[6] 
        mov active_block_num_two_pred[6], bx  
        mov bx, active_block_num_three[0]
        mov active_block_num_three_pred[0], bx
        mov bx, active_block_num_three[2]
        mov active_block_num_three_pred[2], bx
        mov bx, active_block_num_three[4]
        mov active_block_num_three_pred[4], bx
        mov bx, active_block_num_three[6]
        mov active_block_num_three_pred[6], bx 
        mov bx, active_block_num_four[0]
        mov active_block_num_four_pred[0], bx 
        mov bx, active_block_num_four[2]
        mov active_block_num_four_pred[2], bx
        mov bx, active_block_num_four[4]
        mov active_block_num_four_pred[4], bx
        mov bx, active_block_num_four[6]
        mov active_block_num_four_pred[6], bx
fast_loop_pred: 
        call shape_shift_down_pred
        cmp successful_magic_shift_pred, 0H
        je fast_loop_pred_exit
        jmp fast_loop_pred
fast_loop_pred_exit: 
    mov bl, block_colour 
    mov block_border_colour, bl
    mov bx, active_block_num_one_pred[0]
    mov block_start_col, bx
    mov bx, active_block_num_one_pred[2]
    mov block_start_row, bx 
    mov bx, active_block_num_one_pred[4]
    mov block_finish_col, bx 
    mov bx, active_block_num_one_pred[6]
    mov block_finish_row, bx  
    call draw_single_block_border
    mov bx, active_block_num_two_pred[0]
    mov block_start_col, bx
    mov bx, active_block_num_two_pred[2]
    mov block_start_row, bx 
    mov bx, active_block_num_two_pred[4]
    mov block_finish_col, bx 
    mov bx, active_block_num_two_pred[6]
    mov block_finish_row, bx  
    call draw_single_block_border
    mov bx, active_block_num_three_pred[0]
    mov block_start_col, bx
    mov bx, active_block_num_three_pred[2]
    mov block_start_row, bx 
    mov bx, active_block_num_three_pred[4]
    mov block_finish_col, bx 
    mov bx, active_block_num_three_pred[6]
    mov block_finish_row, bx  
    call draw_single_block_border
    mov bx, active_block_num_four_pred[0]
    mov block_start_col, bx
    mov bx, active_block_num_four_pred[2]
    mov block_start_row, bx 
    mov bx, active_block_num_four_pred[4]
    mov block_finish_col, bx 
    mov bx, active_block_num_four_pred[6]
    mov block_finish_row, bx  
    call draw_single_block_border
    ret
endp predict    