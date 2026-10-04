// 知识点：SystemVerilog 类(Class)基础
// 1. 类定义：class 类名; ... endclass，包含属性（变量）和方法（函数）
// 2. 对象创建：使用 new() 构造函数创建对象实例
// 3. 方法调用：通过 对象名.方法名 调用，如 t.display()
// 4. 类中的变量默认为动态（automatic），无需额外声明
// 5. 每个类可定义自己的 display() 方法，实现多态行为
module test;
class Transaction;
    bit [31:0] addr, crc, data[8];
    
    function void display();
        $display("@%0t: TR addr=%h, crc=%h", $time, addr, crc);
        $write("\tdata[0-7]=");
        foreach (data[i]) $write("%h ", data[i]); // 打印每个数据元素
        $display();
    endfunction
endclass
    
class PCI_Tran;
    bit [31:0] addr, data;
    
    function void display();
        $display("@%0t: PCI: addr=%h, data=%h", $time, addr, data);
    endfunction
endclass

Transaction t;   // 声明Transaction类型的句柄
PCI_Tran pc;     // 声明PCI_Tran类型的句柄

initial begin
    t = new();       // 创建Transaction对象
    t.display();     // 调用Transaction::display()
    pc = new();      // 创建PCI_Tran对象
    pc.display();    // 调用PCI_Tran::display()
end
endmodule
