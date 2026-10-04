// 知识点：SystemVerilog 条件约束(implication)
// 1. -> 蕴含操作符：(条件) -> (结果)，条件为真时结果必须成立
// 2. (x == 0) -> y == 0：当x为0时，y必须为0；x为1时，y无约束
// 3. 蕴含约束是单向的，只约束条件成立时的情况
// 4. 概率分布：
//    x=0(50%): y必须为0
//    x=1(50%): y可取0/1/2/3(各25%)
class impact;
    rand bit       x;  // 0或1
    rand bit [1:0] y;  // 0,1,2或3
    constraint c_xy {(x == 0) -> y == 0;}  // x为0时，y必须为0
endclass

module test;
    impact p;

    initial begin
        p = new();
        assert(p.randomize());
        $display("x = %0d", p.x);  // 运行结果：0或1
        $display("y = %0d", p.y);  // 运行结果：x=0时y=0；x=1时y为0/1/2/3
    end
endmodule

// 运行结果（随机值每次不同，以下为示例）：
// x = 0
// y = 0
//
// 或：
// x = 1
// y = 3
//
// 解析：
// 当x=0时，约束要求y==0，所以y只能为0
// 当x=1时，约束不生效，y可取0/1/2/3任意值
