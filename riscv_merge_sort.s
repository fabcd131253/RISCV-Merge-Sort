.data
num_test: .word 3 
TEST1_SIZE: .word 34
TEST2_SIZE: .word 19
TEST3_SIZE: .word 29
test1: .word 3,41,18,8,40,6,45,1,18,10,24,46,37,23,43,12,3,37,0,15,11,49,47,27,23,30,16,10,45,39,1,23,40,38
   # result: 0,1,1,3,3,6,8,10,10,11,12,15,16,18,18,23,23,23,24,27,30,37,37,38,39,40,40,41,43,45,45,46,47,49
test2: .word -3,-23,-22,-6,-21,-19,-1,0,-2,-47,-17,-46,-6,-30,-50,-13,-47,-9,-50
   # result: -50,-50,-47,-47,-46,-30,-23,-22,-21,-19,-17,-13,-9,-6,-6,-3,-2,-1,0
test3: .word -46,0,-29,-2,23,-46,46,9,-18,-23,35,-37,3,-24,-18,22,0,15,-43,-16,-17,-42,-49,-29,19,-44,0,-18,23
   # result: -49,-46,-46,-44,-43,-42,-37,-29,-29,-24,-23,-18,-18,-18,-17,-16,-2,0,0,0,3,9,15,19,22,23,23,35,46


.text
setup:
    li    ra, -1
    li    sp, 0x7ffffff0
main:

    # Callee Saved
    addi    sp, sp, -16                 # sp = @sp - 16
    sw      s0, 12(sp)                  # @s0 -> mem[@sp - 4]
    sw      s1, 8(sp)                   # @s1 -> mem[@sp - 8]
    sw      s2, 4(sp)                   # @s2 -> mem[@sp - 12]
    sw      s3, 0(sp)                   # @s3 -> mem[@sp - 16]

    ##

    lw      s0, num_test                # s0 = num_test = 3
    li      s1, 0x10000004              # s1 = *size = 0x10000004

    slli    t0, s0, 2                   # 1 memory block == 4bytes

    add     t1, s1, t0                  # t1 = 0x10000004 + 12 = 0x10000010 (test1's start)
    mv      s2, t1                      # s2 = t1 = *test
    li      s3, 0x01000000              # s3 = answer = 0x01000000

    #####   for loop
    ### setup
    li      t0, 0                       # t0 = i = 0
    ### initial condition
    bge     t0, s0, main_exit           # if i >= num_test then branch
    ### do...
    main_loop:
    lw      t1, 0(s1)                   # t1 = test_size = *size
    addi    s1, s1, 4                   # size++


    # Caller Saved
    addi    sp, sp, -16                 # sp = @sp - 16
    sw      ra, 12(sp)                  # @ra -> mem[@sp - 4]
    sw      t0, 8(sp)                   # @t0 -> mem[@sp - 8]
    sw      t1, 4(sp)                   # @t1 -> mem[@sp - 12]
    sw      t2, 0(sp)                   # @t2 -> mem[@sp - 16]
    ##


    # jump
    mv      a1, s2                      # a1 = *test (test1's start)
    li      a2, 0                       # a2 = 0
    addi    a3, t1, -1                  # a3 = test_size - 1
    jal     ra, merge_sort


    # Caller Saved
    lw      t2, 0(sp)                   # t2 = @t2
    lw      t1, 4(sp)                   # t1 = @t1
    lw      t0, 8(sp)                   # t0 = @t0
    lw      ra, 12(sp)                  # ra = @ra
    addi    sp, sp, 16                  # sp = @sp
    ##


    ####    for loop
    ## setup
    li      t2, 0                       # t2 = j = 0
    ## initial condition
    bge     t2, t1, main_endLoop_ans    # if j >= test_size then branch
    ## do...
    main_loop_ans:

    lw      t3, 0(s2)                   # t3 = test 
    sw      t3, 0(s3)                   # t3 = test (number in array) -> mem[answer]
    addi    s3, s3, 4                   # answer++
    addi    s2, s2, 4                   # test++
    ## condition
    addi    t2, t2, 1                   # j++
    blt     t2, t1, main_loop_ans       # if j < test_size then branch 
    main_endLoop_ans:
    ####    for loop ends


    ### condition
    addi    t0, t0, 1                   # i++
    blt     t0, s0, main_loop           # if i < num_test then branch
    main_exit:
    #####   for loop ends

    # Callee Saved
    lw      s3, 0(sp)                   # s3 = @s3
    lw      s2, 4(sp)                   # s2 = @s2
    lw      s1, 8(sp)                   # s1 = @s1
    lw      s0, 12(sp)                  # s0 = @s0
    addi    sp, sp, 16                  # sp = @sp
    ##

    ret

merge:

    # Callee Saved
    addi    sp, sp, -24                 # sp = @sp - 24
    sw      s0, 20(sp)                  # @s0 -> mem[@sp - 4]
    sw      s1, 16(sp)                  # @s1 -> mem[@sp - 8]
    sw      s2, 12(sp)                  # @s2 -> mem[@sp - 12]
    sw      s3, 8(sp)                   # @s3 -> mem[@sp - 16]
    sw      s4, 4(sp)                   # @s4 -> mem[@sp - 20]
    sw      s5, 0(sp)                   # @s5 -> mem[@sp - 24]
    ## 

    # a0 = return value
    # a1 = *arr
    # a2 = start
    # a3 = mid
    # a4 = end

    slli    a2, a2, 2                   #
    slli    a3, a3, 2                   # in 4 bytes
    slli    a4, a4, 2                   #

    sub     t1, a4, a2                  # t1 = end - start (in 4 bytes)
    addi    t2, t1, 4                   # t2 = temp_size = end - start + 1 (in 4 bytes)


    addi    s0, sp, -4                  # s0 = start of the temp array
    sub     t0, sp, t2                  # t0 = end of the temp array

    #####   for loop
    ###setup
    li      t3, 0                       # t3 = i = 0
    ###initial condition
    bge     t3, t2, merge_endLoop_cp    # if i >= temp_size then branch
    ### do...
    merge_loop_cp:

    add     t4, t3, a2                  # t4 = i + start (in 4 bytes)
    add     t4, t4, a1                  # t4 = *arr[i + start]

    lw      t5, 0(t4)                   # t5 = arr[i + start] 
    
    addi    sp, sp, -4                  # allocate memory 
    sw      t5, 0(sp)                   # t5 -> mem[@sp - 4]

    ### condition
    addi    t3, t3, 4                   # i++ (in 4 bytes)
    blt     t3, t2, merge_loop_cp       # if i < temp_size then branch
    merge_endLoop_cp:
    #####   for loop ends

    li      s1, 0                       # s1 = left_index = 0
    
    sub     s2, a3, a2                  # s2 = mid - start
    addi    s2, s2, 4                   # s2 = right_index = mid - start + 1 (in 4 bytes)

    sub     s3, a3, a2                  # s3 = left_max = mid - start (in 4 bytes)

    sub     s4, a4, a2                  # s4 = right_max = end - start (in 4 bytes)

    mv      s5, a2                      # s5 = arr_index = start

    #####   while loop
    ### initial condition
    blt     s3, s1, merge_endWhile_comp # if left_max < left_index then branch
    blt     s4, s2, merge_endWhile_comp # if right_max < right_index then branch
    ### do...
    merge_while_comp:
    
    ####    if condition
    sub     t1, s0, s1                  # t1 = *temp[left_index]
    sub     t2, s0, s2                  # t2 = *temp[right_index]

    lw      t3, 0(t1)                   # t3 = temp[left_index]
    lw      t4, 0(t2)                   # t4 = temp[right_index]
    ## if
    blt     t4, t3, merge_else_comp     # if temp[right_index] < temp[left_index] then branch

    add     t1, a1, s5                  # t1 = *arr[arr_index]
    sw      t3, 0(t1)                   # arr[arr_index] = temp[left_index]

    addi    s5, s5, 4                   # arr_index++ (in 4 bytes)
    addi    s1, s1, 4                   # left_index++ (in 4 bytes)

    jal     x0, merge_endIf_comp        # break
    ## else
    merge_else_comp:
    
    add     t1, a1, s5                  # t1 = *arr[arr_index]
    sw      t4, 0(t1)                   # arr[arr_index] = temp[right_index]

    addi    s5, s5, 4                   # arr_index++ (in 4 bytes)
    addi    s2, s2, 4                   # right_index++ (in 4 bytes)

    merge_endIf_comp:
    ####    if condition ends

    ### condition
    blt     s3, s1, merge_endWhile_comp # if left_max < left_index then branch
    blt     s4, s2, merge_endWhile_comp # if right_max < right_index then branch
    jal     x0, merge_while_comp        # loop

    merge_endWhile_comp:
    #####   while loop ends

    #####   while loop
    ### initial condition
    blt     s3, s1, merge_endWhile_catch_l  # if left_max < left_index then branch
    ### do...
    merge_while_catch_l:
    
    add     t1, a1, s5                  # t1 = *arr[arr_index]
    sub     t2, s0, s1                  # t2 = *temp[left_index]

    lw      t3, 0(t2)                   # t3 = temp[left_index]

    sw      t3, 0(t1)                   # arr[arr_index] = temp[left_index]

    addi    s5, s5, 4                   # arr_index++ (in 4 bytes)
    addi    s1, s1, 4                   # left_index++ (in 4 bytes)
    ### condition
    blt     s3, s1, merge_endWhile_catch_l  # if left_max < left_index then branch
    jal     x0, merge_while_catch_l     # loop

    merge_endWhile_catch_l:
    #####   while loop ends

    #####   while loop
    ### initial condition
    blt     s4, s2, merge_endWhile_catch_r  # if right_max < right_index then branch
    ### do...
    merge_while_catch_r:

    add     t1, a1, s5                  # t1 = *arr[arr_index]
    sub     t2, s0, s2                  # t2 = *temp[right_index]

    lw      t3, 0(t2)                   # t3 = temp[right_index]

    sw      t3, 0(t1)                   # arr[arr_index] = temp[right_index]

    addi    s5, s5, 4                   # arr_index++ (in 4 bytes)
    addi    s2, s2, 4                   # right_index++ (in 4 bytes)
    ### condition
    blt     s4, s2, merge_endWhile_catch_r  # if right_max < right_index then branch
    jal     x0, merge_while_catch_r     # loop

    merge_endWhile_catch_r:
    #####   while loop ends

    addi    s0, s0, 4
    mv      sp, s0                      # release the memory of temp array

    # Callee Saved
    lw      s5, 0(sp)                   # s5 = @s5
    lw      s4, 4(sp)                   # s4 = @s4
    lw      s3, 8(sp)                   # s3 = @s3
    lw      s2, 12(sp)                  # s2 = @s2
    lw      s1, 16(sp)                  # s1 = @s1
    lw      s0, 20(sp)                  # s0 = @s0
    addi    sp, sp, 24                  # sp = @sp
    ##

    ret

merge_sort:

    # ra Saved
    addi    sp, sp, -4
    sw      ra, 0(sp)
    ##

    # a1 = *arr
    # a2 = start
    # a3 = end

    ##### if condition
    bge     a2, a3, sort_endIf          # if start >= end then branch
    ### do...

    add     t0, a2, a3                  # t0 = start + end
    srai    t0, t0, 1                   # t0 = mid = (start + end)/2


    # Caller Saved
    addi    sp, sp, -12                 # sp = @sp - 12
    sw      a2, 8(sp)                   # @a2 -> mem[@sp - 4]
    sw      a3, 4(sp)                   # @a3 -> mem[@sp - 8]
    sw      t0, 0(sp)                   # @t0 -> mem[@sp - 12]
    ##

    mv      a3, t0                      # 
    jal     ra, merge_sort              # mergesort(arr, start, mid)

    lw      a2, 8(sp)                   # 
    lw      a3, 4(sp)                   # load data, but no need to allocate new memory
    lw      t0, 0(sp)                   #

    addi    t1, t0, 1                   # t1 = mid + 1
    mv      a2, t1

    # a3 = end   
    jal     ra, merge_sort              # mergesort(arr, mid+1, end)

    lw      t0, 0(sp)                   #
    lw      a3, 4(sp)                   # load data, but no need to allocate new memory
    lw      a2, 8(sp)                   #

    mv      a4, a3                      #
    mv      a3, t0                      #
    # mv      a2, a2                    # merge(arr, start, mid, end)
    # mv      a1, a1                    #
    jal     ra, merge                   #
    # a0 = return value

    # Caller Saved
    lw      t0, 0(sp)                   # t0 = @t0
    lw      a3, 4(sp)                   # a3 = @a3
    lw      a2, 8(sp)                   # a2 = @a2
    addi    sp, sp, 12                  # sp = @sp
    ##

    sort_endIf:
    
    # ra Saved
    lw      ra, 0(sp)
    addi    sp, sp, 4
    ##

    ret