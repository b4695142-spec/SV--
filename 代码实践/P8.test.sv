// 知识点：SystemVerilog 类的构造函数与句柄赋值
// 1. 构造函数 new()：创建对象时自动调用，用于初始化属性
// 2. 构造函数参数可设默认值，如 new(logic [31:0] a=3, d=5)
// 3. 每个参数必须单独声明类型，不能省略
// 4. 句柄赋值 t1 = tr：将tr的句柄赋给t1，两者指向同一个对象
//    修改t1的属性会同时影响tr，因为它们是同一对象的两个引用
// 5. 这不是对象复制，而是句柄（引用）复制
class Transaction;
    logic [31:0] addr, data[8];
    
    function new(logic [31:0] a = 3, d = 5); // 构造函数，带默认参数
        addr = a;
        foreach(data[i]) data[i] = d;
    endfunction
endclass

module test;
    Transaction tr, t1;
    
    initial begin
        tr = new(10, 1);  // 创建对象，addr=10, data全为1
        t1 = new(5, 2);   // 创建对象，addr=5, data全为2
        $display("Addr= %0d", t1.addr);  // 打印t1的addr，输出5
       
        t1 = tr;          // 句柄赋值，t1和tr指向同一个对象
        $display("Addr= %0d", t1.addr);  // 打印t1的addr，输出10
        
        t1.addr = 6;      // 修改t1的addr，由于t1和tr指向同一对象，tr也受影响
        $display("Addr= %0d", tr.addr);  // 打印tr的addr，输出6
    end
endmodule
