// 知识点：SystemVerilog 函数(Function)与ref参数
// 1. function声明：function 返回类型 函数名(参数列表)...endfunction
// 2. ref参数：按引用传递，函数内修改会影响原始变量（类似C的指针传递）
// 3. input参数：按值传递，函数内修改不影响原始变量
// 4. 使用ref参数的函数必须声明为automatic（模块中的函数默认是static的）
// 5. automatic函数：每次调用拥有独立的变量副本，支持ref和递归
module test ;
    function automatic void init(ref int f[5], input int start);
        foreach(f[i])
        f[i] = i + start;
    endfunction
    
    int fa[5];
    
    initial begin
        init(fa,5);
        $display("===================");
        foreach(fa[i])$display("fa[%0d]=%0d", i, fa[i]);
        $display("===================");
    end
endmodule
