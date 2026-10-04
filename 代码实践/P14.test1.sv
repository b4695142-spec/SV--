// 知识点：SystemVerilog 无约束随机化
// 1. rand bit x：1位随机变量，取值0或1，概率各50%
// 2. rand bit [1:0] y：2位随机变量，取值0/1/2/3，概率各25%
// 3. 无约束时，所有可能值的概率均等
// 4. bit类型无符号，取值范围：n位 → 0~2^n-1
class unconstrained;
    rand bit x;        // 0或1
    rand bit [1:0] y;  // 0,1,2或3
endclass

module test;
    unconstrained p;

    initial begin
        p = new();
        assert(p.randomize());
        $display("x = %0d", p.x);  // 运行结果：0或1
        $display("y = %0d", p.y);  // 运行结果：0/1/2/3
    end
endmodule

// 运行结果（随机值每次不同，以下为示例）：
// x = 1
// y = 2
//
// 解析：
// x为1位bit，等概率取0或1
// y为2位bit，等概率取0/1/2/3
