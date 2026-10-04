// 知识点：SystemVerilog solve...before控制随机化顺序
// 1. solve y before x：先随机化y，再根据y的值随机化x
// 2. 不加solve before时，求解器可能产生非均匀概率分布
// 3. 加solve before后，y的每个值概率均等，再根据约束决定x
// 4. 概率分布分析(solve y before x)：
//    y先随机，P(y=0/1/2/3)各25%
//    y=0时：x可取0或1，P(x=0|y=0)=50%, P(x=1|y=0)=50%
//    y=1/2/3时：x必须为1(因x=0要求y=0)
//    因此：P(x=0)=1/4*1/2=1/8(12.5%), P(x=1)=7/8(87.5%)
class impact;
    rand bit x;        // 0或1
    rand bit [1:0] y;  // 0,1,2或3
    constraint c_xy
    {
        (x == 0) -> y == 0;  // x为0时y必须为0
        solve y before x;    // 先随机化y，再随机化x
    }
endclass

module test;
    impact p;

    initial begin
        p = new();
        assert(p.randomize());
        $display("x = %0d", p.x);  // 运行结果：多为1，偶尔为0
        $display("y = %0d", p.y);  // 运行结果：0/1/2/3
    end
endmodule

// 运行结果（随机值每次不同，以下为示例）：
// x = 1
// y = 2
//
// 概率分布（solve y before x）：
// ┌──────┬──────┬────────────────┐
// │  y   │  x   │     概率       │
// ├──────┼──────┼────────────────┤
// │  0   │  0   │  1/4×1/2=1/8  │
// │  0   │  1   │  1/4×1/2=1/8  │
// │  1   │  1   │  1/4×1  =1/4  │
// │  2   │  1   │  1/4×1  =1/4  │
// │  3   │  1   │  1/4×1  =1/4  │
// └──────┴──────┴────────────────┘
// P(x=0) = 1/8 = 12.5%
// P(x=1) = 7/8 = 87.5%
