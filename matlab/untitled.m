clc;
clear;
close all;
warning off;
addpath 'func\'
fprintf("\nconv1a_weight:    128'h")
for j = 1 : 8   
    for i = 1 : 4
        x = uint8(rand(1) * 255);
        if     mod(x, 16) == 0
                      fprintf("0")
        elseif mod(x, 16) == 1
                      fprintf("1")
        elseif mod(x, 16) == 2
                      fprintf("2")
        elseif mod(x, 16) == 3
                      fprintf("3")
        elseif mod(x, 16) == 4
                      fprintf("4")
        elseif mod(x, 16) == 5
                      fprintf("5")
        elseif mod(x, 16) == 6
                      fprintf("6")
        elseif mod(x, 16) == 7
                      fprintf("7")
        elseif mod(x, 16) == 8
                      fprintf("8")   
        elseif mod(x, 16) == 9
                      fprintf("9")
        elseif mod(x, 16) == 10
                      fprintf("A")
        elseif mod(x, 16) == 11
                      fprintf("B")
        elseif mod(x, 16) == 12
                      fprintf("C")
        elseif mod(x, 16) == 13
                      fprintf("D")
        elseif mod(x, 16) == 14
                      fprintf("E")
        elseif mod(x, 16) == 15
                      fprintf("F")
        end
    end
    fprintf("_")
end
fprintf("\nconv1b_weight:    128'h")
for j = 1 : 8   
    for i = 1 : 4
        x = uint8(rand(1) * 255);
        if     mod(x, 16) == 0
                      fprintf("0")
        elseif mod(x, 16) == 1
                      fprintf("1")
        elseif mod(x, 16) == 2
                      fprintf("2")
        elseif mod(x, 16) == 3
                      fprintf("3")
        elseif mod(x, 16) == 4
                      fprintf("4")
        elseif mod(x, 16) == 5
                      fprintf("5")
        elseif mod(x, 16) == 6
                      fprintf("6")
        elseif mod(x, 16) == 7
                      fprintf("7")
        elseif mod(x, 16) == 8
                      fprintf("8")   
        elseif mod(x, 16) == 9
                      fprintf("9")
        elseif mod(x, 16) == 10
                      fprintf("A")
        elseif mod(x, 16) == 11
                      fprintf("B")
        elseif mod(x, 16) == 12
                      fprintf("C")
        elseif mod(x, 16) == 13
                      fprintf("D")
        elseif mod(x, 16) == 14
                      fprintf("E")
        elseif mod(x, 16) == 15
                      fprintf("F")
        end
    end
    fprintf("_")
end
fprintf("\nconv2a_weight:    128'h")
for j = 1 : 8   
    for i = 1 : 4
        x = uint8(rand(1) * 255);
        if     mod(x, 16) == 0
                      fprintf("0")
        elseif mod(x, 16) == 1
                      fprintf("1")
        elseif mod(x, 16) == 2
                      fprintf("2")
        elseif mod(x, 16) == 3
                      fprintf("3")
        elseif mod(x, 16) == 4
                      fprintf("4")
        elseif mod(x, 16) == 5
                      fprintf("5")
        elseif mod(x, 16) == 6
                      fprintf("6")
        elseif mod(x, 16) == 7
                      fprintf("7")
        elseif mod(x, 16) == 8
                      fprintf("8")   
        elseif mod(x, 16) == 9
                      fprintf("9")
        elseif mod(x, 16) == 10
                      fprintf("A")
        elseif mod(x, 16) == 11
                      fprintf("B")
        elseif mod(x, 16) == 12
                      fprintf("C")
        elseif mod(x, 16) == 13
                      fprintf("D")
        elseif mod(x, 16) == 14
                      fprintf("E")
        elseif mod(x, 16) == 15
                      fprintf("F")
        end
    end
    fprintf("_")
end
fprintf("\nconv2b_weight:    128'h")
for j = 1 : 8   
    for i = 1 : 4
        x = uint8(rand(1) * 255);
        if     mod(x, 16) == 0
                      fprintf("0")
        elseif mod(x, 16) == 1
                      fprintf("1")
        elseif mod(x, 16) == 2
                      fprintf("2")
        elseif mod(x, 16) == 3
                      fprintf("3")
        elseif mod(x, 16) == 4
                      fprintf("4")
        elseif mod(x, 16) == 5
                      fprintf("5")
        elseif mod(x, 16) == 6
                      fprintf("6")
        elseif mod(x, 16) == 7
                      fprintf("7")
        elseif mod(x, 16) == 8
                      fprintf("8")   
        elseif mod(x, 16) == 9
                      fprintf("9")
        elseif mod(x, 16) == 10
                      fprintf("A")
        elseif mod(x, 16) == 11
                      fprintf("B")
        elseif mod(x, 16) == 12
                      fprintf("C")
        elseif mod(x, 16) == 13
                      fprintf("D")
        elseif mod(x, 16) == 14
                      fprintf("E")
        elseif mod(x, 16) == 15
                      fprintf("F")
        end
    end
    fprintf("_")
end
fprintf("\nconv1a_bias:        8'h")
for i = 1 : 2
    x = uint8(rand(1) * 255);
    if     mod(x, 16) == 0
                  fprintf("0")
    elseif mod(x, 16) == 1
                  fprintf("1")
    elseif mod(x, 16) == 2
                  fprintf("2")
    elseif mod(x, 16) == 3
                  fprintf("3")
    elseif mod(x, 16) == 4
                  fprintf("4")
    elseif mod(x, 16) == 5
                  fprintf("5")
    elseif mod(x, 16) == 6
                  fprintf("6")
    elseif mod(x, 16) == 7
                  fprintf("7")
    elseif mod(x, 16) == 8
                  fprintf("8")   
    elseif mod(x, 16) == 9
                  fprintf("9")
    elseif mod(x, 16) == 10
                  fprintf("A")
    elseif mod(x, 16) == 11
                  fprintf("B")
    elseif mod(x, 16) == 12
                  fprintf("C")
    elseif mod(x, 16) == 13
                  fprintf("D")
    elseif mod(x, 16) == 14
                  fprintf("E")
    elseif mod(x, 16) == 15
                  fprintf("F")
    end
end
fprintf("\nconv1b_bias:        8'h")
for i = 1 : 2
    x = uint8(rand(1) * 255);
    if     mod(x, 16) == 0
                  fprintf("0")
    elseif mod(x, 16) == 1
                  fprintf("1")
    elseif mod(x, 16) == 2
                  fprintf("2")
    elseif mod(x, 16) == 3
                  fprintf("3")
    elseif mod(x, 16) == 4
                  fprintf("4")
    elseif mod(x, 16) == 5
                  fprintf("5")
    elseif mod(x, 16) == 6
                  fprintf("6")
    elseif mod(x, 16) == 7
                  fprintf("7")
    elseif mod(x, 16) == 8
                  fprintf("8")   
    elseif mod(x, 16) == 9
                  fprintf("9")
    elseif mod(x, 16) == 10
                  fprintf("A")
    elseif mod(x, 16) == 11
                  fprintf("B")
    elseif mod(x, 16) == 12
                  fprintf("C")
    elseif mod(x, 16) == 13
                  fprintf("D")
    elseif mod(x, 16) == 14
                  fprintf("E")
    elseif mod(x, 16) == 15
                  fprintf("F")
    end
end
fprintf("\nconv2a_bias:        8'h")
for i = 1 : 2
    x = uint8(rand(1) * 255);
    if     mod(x, 16) == 0
                  fprintf("0")
    elseif mod(x, 16) == 1
                  fprintf("1")
    elseif mod(x, 16) == 2
                  fprintf("2")
    elseif mod(x, 16) == 3
                  fprintf("3")
    elseif mod(x, 16) == 4
                  fprintf("4")
    elseif mod(x, 16) == 5
                  fprintf("5")
    elseif mod(x, 16) == 6
                  fprintf("6")
    elseif mod(x, 16) == 7
                  fprintf("7")
    elseif mod(x, 16) == 8
                  fprintf("8")   
    elseif mod(x, 16) == 9
                  fprintf("9")
    elseif mod(x, 16) == 10
                  fprintf("A")
    elseif mod(x, 16) == 11
                  fprintf("B")
    elseif mod(x, 16) == 12
                  fprintf("C")
    elseif mod(x, 16) == 13
                  fprintf("D")
    elseif mod(x, 16) == 14
                  fprintf("E")
    elseif mod(x, 16) == 15
                  fprintf("F")
    end
end
fprintf("\nconv2b_bias:        8'h")
for i = 1 : 2
    x = uint8(rand(1) * 255);
    if     mod(x, 16) == 0
                  fprintf("0")
    elseif mod(x, 16) == 1
                  fprintf("1")
    elseif mod(x, 16) == 2
                  fprintf("2")
    elseif mod(x, 16) == 3
                  fprintf("3")
    elseif mod(x, 16) == 4
                  fprintf("4")
    elseif mod(x, 16) == 5
                  fprintf("5")
    elseif mod(x, 16) == 6
                  fprintf("6")
    elseif mod(x, 16) == 7
                  fprintf("7")
    elseif mod(x, 16) == 8
                  fprintf("8")   
    elseif mod(x, 16) == 9
                  fprintf("9")
    elseif mod(x, 16) == 10
                  fprintf("A")
    elseif mod(x, 16) == 11
                  fprintf("B")
    elseif mod(x, 16) == 12
                  fprintf("C")
    elseif mod(x, 16) == 13
                  fprintf("D")
    elseif mod(x, 16) == 14
                  fprintf("E")
    elseif mod(x, 16) == 15
                  fprintf("F")
    end
end
fprintf("\nconnect_bias:      64'h")
for i = 1 : 16
    x = uint8(rand(1) * 255);
    if     mod(x, 16) == 0
                  fprintf("0")
    elseif mod(x, 16) == 1
                  fprintf("1")
    elseif mod(x, 16) == 2
                  fprintf("2")
    elseif mod(x, 16) == 3
                  fprintf("3")
    elseif mod(x, 16) == 4
                  fprintf("4")
    elseif mod(x, 16) == 5
                  fprintf("5")
    elseif mod(x, 16) == 6
                  fprintf("6")
    elseif mod(x, 16) == 7
                  fprintf("7")
    elseif mod(x, 16) == 8
                  fprintf("8")   
    elseif mod(x, 16) == 9
                  fprintf("9")
    elseif mod(x, 16) == 10
                  fprintf("A")
    elseif mod(x, 16) == 11
                  fprintf("B")
    elseif mod(x, 16) == 12
                  fprintf("C")
    elseif mod(x, 16) == 13
                  fprintf("D")
    elseif mod(x, 16) == 14
                  fprintf("E")
    elseif mod(x, 16) == 15
                  fprintf("F")
    end
end

fid = fopen('weight.mi','wt');
fprintf(fid,'#File_format=Hex\n');
fprintf(fid,'#Address_depth=25\n');
fprintf(fid,'#Data_width=256\n');
for j = 1 : 25
    for i = 1 : 64
        x = uint8(rand(1) * 255);
        if     mod(x, 16) == 0
                      fprintf(fid,"0");
        elseif mod(x, 16) == 1
                      fprintf(fid,"1");
        elseif mod(x, 16) == 2
                      fprintf(fid,"2");
        elseif mod(x, 16) == 3
                      fprintf(fid,"3");
        elseif mod(x, 16) == 4
                      fprintf(fid,"4");
        elseif mod(x, 16) == 5
                      fprintf(fid,"5");
        elseif mod(x, 16) == 6
                      fprintf(fid,"6");
        elseif mod(x, 16) == 7
                      fprintf(fid,"7");
        elseif mod(x, 16) == 8
                      fprintf(fid,"8");   
        elseif mod(x, 16) == 9
                      fprintf(fid,"9");
        elseif mod(x, 16) == 10
                      fprintf(fid,"A");
        elseif mod(x, 16) == 11
                      fprintf(fid,"B");
        elseif mod(x, 16) == 12
                      fprintf(fid,"C");
        elseif mod(x, 16) == 13
                      fprintf(fid,"D");
        elseif mod(x, 16) == 14
                      fprintf(fid,"E");
        elseif mod(x, 16) == 15
                      fprintf(fid,"F");
        end
    end
    fprintf(fid,'\n');
end