.model small

.stack 100h

.data
    ; data trong bai chuyen chuoi sang ki tu hoa
    msgi db 10,13,'Nhap mot chuoi (gioi han: 80 ki tu): $'
    msgo db 10,13,'Chuoi xuat ra: $'
    inp db 80,?,81 dup('$')
    
    ;data trong bai tinh toan
    ms1 db "Nhap so thu nhat 0-99:$"
    ms2 db 10,13,"Nhap so thu hai 0-99:$"  
    bieuthuc1 db 10,13,"Tong hai so la:$"
    bieuthuc2 db 10,13,"Tich hai so la:$" 
    bieuthuc3 db 10,13,"Hieu hai so la(x1-x2):$" 
    bieuthuc4 db 10,13,"Thuong hai so la:$"
    Error db 10,13,"Nhap so khong hop le! nhap lai:$"
    x dw ?  
    y dw ?
    z dw ?
    t dw ?

    ;data trong bai in loi chao
    loichao1 db "Good morning$"
    loichao2 db "Good afternoon$"
    loichao3 db  "Good evening$"


.code
main proc
    mov ax,@data            ; khoi dau DS
    mov ds,ax
    mov es,ax

    ; [chua test duoc code nay tren emu8086]
    ; [tham khao]
    ; https://stackoverflow.com/questions/72637425/how-to-check-the-capslock-status-in-assembly
    ; http://www.techhelpmanual.com/58-keyboard_shift_status_flags.html

    ;; kiem tra trang thai den cua capslock va numlock
    mov ax,40h              ; tim den dia chi chua cac keyboard shift flags
    mov es,ax               ; o dia chi 0040:0017
    
    ; test dung toan tu bit AND va kiem tra bit
    ; https://en.wikipedia.org/wiki/TEST_(x86_instruction) 
    
    ; kiem tra numlock
    test byte ptr es:[17h],20h ; tinh trang numlock bieu thi o bit 5: 20h 
    jnz num_on              ; flag != 0, numlock bat
    jz num_off              ; flag = 0, numlock tat
                               
    ;; kiem tra capslock o ca hai truong hop numlock bat/tat
num_on:
    test byte ptr es:[17h],40h ; tinh trang caps lock bieu thi o bit 6: 40h
    jnz num_on_caps_on      ; numlock bat, capslock bat 
    jz num_on_caps_off      ; numlock bat, capslock tat

num_off:
    test byte ptr es:[17h],40h ; tinh trang caps lock bieu thi o bit 6: 40h
    jnz num_off_caps_on     ; numlock tat, capslock bat 
    jz num_off_caps_off     ; numlock tat, capslock tat
    
num_on_caps_on:
    ; goi ham hien thi gio hien tai cua may (bai 1)
    call time
    jmp done
    
num_on_caps_off:
    ; goi ham tinh tong, hieu, tich, thuong 2 so (bai 3)
    call Math
    jmp done

num_off_caps_on:
    ; goi ham chuyen chuoi thanh chu hoa (bai 2)
    call toupper
    jmp done

num_off_caps_off: ;vi chuong trinh chua kiem tra duoc trang thai caps va num nen mac dinh no se xuong day
    ; goi ham xuat thong bao chao mung
    call XinChao  ;co the thay the cac chuong trinh time,Math,toupper de chay cac chuong trinh con 
    jmp done

    ; ket thuc chuong trinh
done:
    mov ah,4ch
    int 21h                 ; tro ve DOS
    ret

main endp



timeComputer proc
    
    mov ah,2ch  ;ham ngat lay gio thanh ghi ch luu tru gio, thanh ghi cl chua phut, thanh ghi dh chua giay
    int 21h
    mov al,ch   ;chuyen gio vao al
    call disp   ;su dung al de in gio
    mov dl,':' 
    mov ah,2h
    int 21h  
    mov al,cl   ;chuyen phut vao al
    call disp   ;su dung al de in phut
    mov dl,':''  
    mov ah,2h
    int 21h
    mov al,dh   ;chuyen giay vao al
    call disp   ;su dung al de in giay
    mov ah,4ch  ; ngat chuong trinh
    int 21h

    
timeComputer endp    



disp proc 
aam ;al divided by 10 phan du ghi lai trong al, phan thuong o ah
    add ax,3030h; ax lu tru 3132h
; cong 3030 vi 31 trong ascii la 1, 32 trong ascii la 2 khi doi ra string
    mov bx,ax
    mov dl,ah
    mov ah,2
    int 21h
;print dl ra man hinh (so dau tien )
    mov dl,bl
    int 21h
;print dl ra man hinh(so thu 2 )
    ret
disp endp






toupper proc 
    ; [tham khao]
    ; https://stackoverflow.com/questions/1699748/what-is-the-difference-between-mov-and-lea
    mov ah,09h              ; xuat thong bao nhap
    lea dx,msgi             ; load dia chi chuoi thong bao nhap vao dx
    int 21h                 ; ham ngat de xuat chuoi

    mov ah,0Ah              ; nhap chuoi
    lea dx,inp              ; load dia chi chuoi can luu vao dx
    int 21h                 ; ham ngat de nhap

    mov ah,09h              ; xuat thong bao chuoi tra ve
    lea dx,msgo             ; load dia chi chuoi thong bao xuat vao dx
    int 21h                 ; ham ngat de xuat chuoi

    ; [tham khao]
    ; https://stackoverflow.com/questions/1396527/what-is-the-purpose-of-xoring-a-register-with-itself            
    xor cx,cx               ; dua cx (dem lan loop) ve 0

    mov si,02h              ; (chua giai thich nhung ma index 0, 1 khong chi ki tu nao trong chuoi inp
                            ; nen set si ve 2 de duyet tu ki tu dau trong chuoi inp)

    ; lap tat ca ki tu trong chuoi de chuyen sang chu in hoa
iterate:
    mov dl,inp[si]          ; sao chep ki tu thu si cua chuoi inp vao dl

    cmp dl,'$'              ; kiem tra neu ki tu la $ (ket thuc chuoi)
    je outstr               ; thoat khoi vong lap, di den xuat chuoi in hoa


    cmp dl,'a'              ; so sanh neu ki tu khong can phai in hoa
                            ; chu can in hoa nam trong khoang ['a','z']
    jb rightcase
    cmp dl,'z'
    ja rightcase

    sub dl,20h              ; chu hoa = chu thuong - 32d 
    mov inp[si],dl          ; dua ki tu in hoa ve tro lai chuoi inp

rightcase:
    inc si                  ; tang index si len 1
    loop iterate            ; lap lai voi ki tu tiep theo

    ; xuat chuoi cuoi cung
outstr:      
    mov ah,09h              ; xuat chuoi
    lea dx,inp+02h          ; load dia chi chuoi (cong 2 vi ly do da neu o dong 28) 
    int 21h                 ; ham ngat de xuat chuoi
    ret

toupper endp  



Math proc
    
    ; Nhap so   
    ; nhap cho so thu nhat
    mov ah,9 ; lenh ngat loai 9 in ra 1 chuoi ky tu
    lea dx,ms1 ; doan nay xuat ra chuoi ky tu ms1
    int 21h
    jmp nhap1
      
Loi1: ;bao loi va nhap lai so
    
    mov ah,9 ; lenh ngat loai 9 in ra 1 chuoi ky tu
    lea dx,Error ; doan nay xuat ra chuoi ky tu Error
    int 21h 
    
nhap1:
    call input
    cmp x,100 ;so sanh voi 100
    jnb Loi1  ;neu khong nho hon 100 la khong phai so co 2 chu so quay lai Loi1 de nhap lai
     
    mov ax,x  ; chuyen so vua nhap vao thanh ghi ax
    mov z,ax  ; chuyen so vua nhap vao thanh bien z  
    
    
    ; nhap cho so thu hai
    mov ah,9 ; lenh ngat loai 9 in ra 1 chuoi ky tu
    lea dx,ms2 ; doan nay xuat ra chuoi ky tu ms2
    int 21h  
    jmp nhap2
     
Loi2:
    mov ah,9 ; lenh ngat loai 9 in ra 1 chuoi ky tu
    lea dx,Error ; doan nay xuat ra chuoi ky tu Error
    int 21h 
     
nhap2:
    call input
    cmp x,100 ;so sanh voi 100
    jnb Loi2  ;neu khong nho hon 100 la khong phai so co 2 chu so quay lai Loi2 de nhap lai
    
    mov ax,x; chuyen so vua nhap vao thanh ghi ax
    mov t,ax; chuyen so vua nhap vao thanh bien t
    
    
    ; Tinh Tong
    mov ah,9 ; lenh ngat loai 9 in ra 1 chuoi ky tu
    lea dx,bieuthuc1 ; doan nay xuat ra chuoi ky tu bieuthuc1
    int 21h
    mov ax,z ; chuyen so nguyen vao thanh ghi ax
    add ax,t ; cong 2 so nguyen va luu vao ax
    mov x,ax ; chuyen so nguyen vua cong duoc cho thanh ghi ax 
    call output
    
    ; Tich
    mov ah,9 ; lenh ngat loai 9 in ra 1 chuoi ky tu
    lea dx,bieuthuc2 ; doan nay xuat ra chuoi ky tu bieuthuc2
    int 21h
    mov ax,z ; chuyen gia tri thanh ghi z vao ax
    mul t     ; nhan 2 so nguyen luu vao (dx,ax) voi ax la low address
    mov x,ax ; chuyen gia tri vao thanh ghi x
    call output


    ; Tinh Hieu  z-t
    mov ah,9 ; lenh ngat loai 9 in ra 1 chuoi ky tu
    lea dx,bieuthuc3 ;  doan nay xuat ra chuoi ky tu bieuthuc3
    int 21h
    mov ax,z ; chuyen so nguyen vao thanh ghi ax 
       
    cmp t,ax ; so sanh t va ax cung la de so sanh t va z
    ja Soam  ; neu t lon hon thi ket qua z-t la so am
       
Soduong:
      
    sub ax,t ; lay z-t va luu vao ax 
    mov x,ax ; chuyen so nguyen vua tru duoc cho thanh ghi ax
    jmp KetquaDuong 
       
Soam:
     
    mov ax,t ; chuyen so nguyen t vao thanh ghi ax
    sub ax,z ; lay t-z va luu vao ax 
     
     
KetquaAm:
    mov x,ax ; chuyen so nguyen vua tru duoc cho thanh ghi ax
    mov dl,'-' ; in ra dau -
    mov ah,2
    int 21h
     
KetquaDuong:
   
    call output ;in ra hieu cua 2 so

    ;Tinh Thuong
    mov ah,9 ; lenh ngat loai 9 in ra 1 chuoi ky tu
    lea dx,bieuthuc4 ; doan nay xuat ra chuoi ky tu bieuthuc4
    int 21h     
    xor dx,dx ;chuyen dx lai tat ca la 0
    mov ax,z ; chuyen so nguyen vao thanh ghi ax
    div t ; chia 2 so nguyen va luu vao ax
    mov x,ax ; chuyen thuong vao thanh ghi ax 
    cmp ch,cl
    call output 
    mov ah,4ch ; lenh ngay nay dung de thoat chuong trinh
    int 21h 

Math endp



; Chuong trinh con su dung cho Math
input proc
    mov x,0 ; khoi tao cho bien x bang 0 voi bien x la 16 bit
    mov y,0 ; khoi tao cho bien y bang 0 voi bien y la 16 bit
    mov bx,10 ; khoi tao co so 10 
nhap:
    mov ah,1 ; lenh ngat so 1 dung de nhap 1 kytu
    int 21h
    cmp al,13 ; so sanh voi voi 13 la enter de dung
    je thoat
    sub al,30h ; lay ra gia tri so nguyen trong he 16
    xor ah,ah ; xoa thanh ghi ah de thanh 8 bit 0 
    mov y,ax ; dua vao bien y voi 16 bit
    mov ax,x ; chuyen vao thanh ghi ax voi x =0
    mul bx ; nhan voi 10
    add ax,y ; cong y vao thanh ghi ax
    mov x,ax ; chuyen gia tri thanh ghi ax vao x  

    jmp nhap ; quay lai nhap tiep

thoat:
    ret ;; ve tiep tuc chuong trinh con Math
input endp


output proc
      mov bx,10 ; khoi tao co so 10 cho thanh khi bx
      mov ax,x ; chuyen gia tri x vao thanh ghi ax
      mov cx,0 ; dem so lan chia
chia:
      mov dx,0 ; xoa thanh ghi dx de luu phan du cua 16 bit
      div bx ; Chia cho thanh ghi ax va lay luu phan nguyen o thanh ghi AX va phan du o thanh ghi dx
      inc cx ; cx++ tang len mot don vi
      push dx ; push vao dinh stack cua thanh ghi dx de ti nua xuat ra
      cmp al,0 ; so xanh ax voi al xem co phai ax la so 0 hay khong de tiep tuc chia
      je hienthi; neu bang 0 thi hien so nguyen ra
      jmp chia ; con chua bang thi tiep tuc chia
hienthi:
      pop dx; lay du lieu tu dinh stack cua thanh ghi dx
      add dl,30h; cong them 30h de ra so nguyen theo ma asci
      mov ah,2; cau lenh ngat loai 2 in ra mot ki tu
      int 21h
      dec cx ; c-- giam cx xuong , co y nghia thuc hien so lan in ra ki tu
      cmp cx,0 ; compare voi 0 khi nao cx =0 thi dung lai
      jne hienthi ; quay lai hien tiep
      ret ; quay lai chuong trinh chinh
output endp  
 
    





XinChao proc    
    
    
      mov ah,2ch ; phep ngat lay thoi gian cua may tinh
      int 21h
            
           
      cmp ch,12  ; duoi 12 gio thi se la buoi sang        
      jb buoisang

      cmp ch,16  ;duoi 16 gio la buoi chieu
      jb buoichieu

      cmp ch,25  ; duoi  25 gio la buoi toi
      jb buoitoi
 
 

buoisang:    
    
      lea dx,loichao1 ;lay dia chi loichao1
      mov ah,9       ;in ra man hinh chuoi loichao1
      int 21h
       
      mov ah,4ch; ngat chuong trinh
      int 21h
buoichieu:
    
      lea dx,loichao2;lay dia chi loichao2
      mov ah,9   ;in ra man hinh chuoi loichao1
      int 21h
    
      mov ah,4ch ;ngat chuong trinh
      int 21h
buoitoi:

                    
      lea dx,loichao3 ;lay dia chi loichao3
      mov ah,9        ;in ra man hinh chuoi loichao1
      int 21h
     
       
      mov ah,4ch ;ngat chuong trinh
      int 21h


XinChao endp


end main 
