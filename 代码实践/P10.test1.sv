// 知识点：SystemVerilog 虚方法(virtual)与多态
// 1. virtual function：虚方法，调用时根据对象的实际类型（而非句柄类型）决定执行哪个方法
// 2. 非virtual function：普通方法，调用时根据句柄类型决定执行哪个方法
// 3. 句柄上转型：子类句柄可赋给父类句柄（p1=p2），但反之不行
// 4. 子类和父类同名变量各自独立，子类对象中同时存在两份（父类的和子类的）
// 5. 函数定义和调用必须带括号，即使无参数
class packet;
    int a = 1;
    int b = 2;
    
    function void display_a();          // 非虚方法
        $display("packet::a is %0d", a);
    endfunction
    
    virtual function void display_b();  // 虚方法
        $display("packet::b is %0d", b);
    endfunction
endclass

class my_packet extends packet;
    int a = 3;
    int b = 4;
    
    function void display_a();          // 非虚方法
        $display("my_packet::a is %0d", a);
    endfunction
    
    virtual function void display_b();  // 虚方法
        $display("my_packet::b is %0d", b);
    endfunction
endclass

module top;
    packet p1;
    my_packet p2;
    
    initial begin
        p1 = new();       // 创建packet对象
        p2 = new();       // 创建my_packet对象
        p1 = p2;          // 上转型：子类句柄赋给父类句柄，p1指向my_packet对象
        p1.display_a();   // 非虚方法：按句柄类型(packet)调用 → packet::display_a
        p1.display_b();   // 虚方法：按对象类型(my_packet)调用 → my_packet::display_b
    end
endmodule

// 运行结果：
// packet::a is 1
// my_packet::b is 4
//
// 解析：
// p1.display_a() → display_a非虚方法，按句柄类型packet解析，调用packet::display_a
//   packet::display_a中访问的a是packet::a=1
// p1.display_b() → display_b虚方法，按对象实际类型my_packet解析，调用my_packet::display_b
//   my_packet::display_b中访问的b是my_packet::b=4
