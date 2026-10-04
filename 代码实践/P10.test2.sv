// 知识点：SystemVerilog 类继承、super与$cast
// 1. super.new()：子类构造函数中必须调用父类构造函数，且必须是第一条语句
// 2. 上转型(upcast)：子类句柄赋给父类句柄，自动完成，如 f = c0
// 3. 下转型(downcast)：父类句柄赋给子类句柄，必须用$cast，如 $cast(c2, f)
// 4. $cast(c2, f)：将f指向的对象转换为child1类型句柄c2，运行时检查类型是否匹配
// 5. 非虚方法按句柄类型解析，虚方法按对象类型解析
class father;
    string m_name;
    
    function new(string name);
        m_name = name;
    endfunction
    
    function void print();
        $display("Hello %s", m_name);
    endfunction
endclass : father

class child0 extends father;
    string car = "car";
    
    function new(string name);
        super.new(name);    // 调用父类构造函数
    endfunction
endclass : child0

class child1 extends father;
    string plane = "plane";
    
    function new(string name);
        super.new(name);    // 调用父类构造函数
    endfunction
endclass : child1

module top;
    father f;
    child0 c0;
    child1 c1;
    child1 c2;
    
    initial begin
        f = new("father");    // 创建father对象
        f.print();            // Hello father
        
        c0 = new("child0");   // 创建child0对象
        f = c0;               // 上转型：子类句柄赋给父类句柄
        f.print();            // Hello child0
        
        c1 = new("child1");   // 创建child1对象
        f = c1;               // 上转型
        f.print();            // Hello child1
        
        c1.plane = "big_plane";  // 修改c1的plane属性
        $cast(c2, f);         // 下转型：父类句柄f转为子类句柄c2，c2与c1指向同一对象
        f.print();            // Hello child1
        
        $display(", has %s", c2.plane);  // big_plane（c2与c1指向同一对象）
    end
endmodule : top

// 运行结果：
// Hello father
// Hello child0
// Hello child1
// Hello child1
// , has big_plane
//
// 解析：
// 1. f.print() 三次分别打印 father/child0/child1，因为 m_name 由 super.new(name) 设置
// 2. c1.plane="big_plane" 修改了对象属性，$cast(c2,f) 后 c2 与 c1 指向同一对象
// 3. 因此 c2.plane 也是 "big_plane"
