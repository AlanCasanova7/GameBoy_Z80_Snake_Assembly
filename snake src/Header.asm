SECTION "Copy Data",ROM0[$28]

COPY_DATA:
  ; pop return address off stack into hl
  pop hl
  push bc

  ; here we get the number of bytes to copy
  ; hl contains the address of the bytes following the "rst $28" call

  ; put first byte into b ($00 in this context)
  ld  a,[hli]
  ld  b,a

  ; put second byte into c ($0D in this context)
  ld  a,[hli]
  ld  c,a

  ; bc now contains $000D
  ; hl now points to the first byte of our assembled subroutine (which is $F5)
  ; begin copying data
.copy_data_loop
  
  ; load a byte of data into a
  ld  a,[hli]

  ; store the byte in de, our destination ($FF80 in this context)
  ld  [de],a
  
  ; go to the next destination byte, decrease counter
  inc de
  dec bc

  ; check if counter is zero, if not repeat loop
  ld  a,b
  or  c
  jr  nz,.copy_data_loop
  
  ; all done, return home
  pop bc
  jp  hl
  reti