// 知识点：SystemVerilog 函数的input/output参数
// 1. input参数：按值传入，函数内修改不影响原始变量
// 2. output参数：按值传出，函数结束时将值复制回调用者
// 3. 函数通过output参数返回结果时，应声明为void（无返回值）
// 4. 不应修改input参数的值，应使用局部变量或直接写入output
// 5. 数组索引从0开始，大小为5的数组有效索引为0~4
module test;
    function void init(input int f[5], input int start, output int o[5]);
        foreach(f[i]) begin
            o[i] = i + start;
        end
    endfunction
    
    int fa[5],fb[5];
    
    initial begin
        init(fa,5,fb);
        $display("===================");
        foreach(fb[i]) $display("fb[%0d]=%0d",i,fb[i]);
        $display("===================");
    end
endmodule
