// 知识点：SystemVerilog 类的继承与访问修饰符
// 1. extends：子类继承父类，获得父类的属性和方法
// 2. protected：受保护成员，仅在本类及其子类中可访问
// 3. local：局部成员，仅在本类中可访问，子类不可访问
// 4. this：指向当前对象，用于引用当前类的成员
// 5. 子类中访问父类protected成员，直接使用成员名即可
typedef enum {WHITE, BLACK} color_t;

class cat;
    protected color_t color;  // protected：子类可访问
    local bit is_good;        // local：仅本类可访问，子类不可访问

    function set_good(bit s);
        this.is_good = s;     // local成员通过本类方法访问
    endfunction

    function bit get_good();
        return this.is_good;  // 提供访问local成员的接口
    endfunction
endclass

class black_cat extends cat;
    function new();
        color = BLACK;        // 直接访问父类protected成员
    endfunction
endclass

class white_cat extends cat;
    function new();
        color = WHITE;        // 直接访问父类protected成员
    endfunction
endclass

module test;
    black_cat bk;
    white_cat wt;
    
    initial begin
        bk = new();           // 创建黑猫对象
        wt = new();           // 创建白猫对象
        bk.set_good(1);       // 通过父类方法设置local成员
        wt.set_good(1);
        $display("black_cat good=%0d", bk.get_good());
        $display("white_cat good=%0d", wt.get_good());
    end
endmodule
