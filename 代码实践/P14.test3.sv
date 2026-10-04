// 知识点：SystemVerilog 约束冲突与求解
// 1. 多个约束同时生效时，必须全部满足(AND关系)
// 2. y > 0 要求y为1/2/3
// 3. (x == 0) -> y == 0 当x=0时要求y=0，与y>0冲突
// 4. 求解器会自动排除冲突的情况，因此x只能为1，y只能为1/2/3
// 5. 约束冲突不会导致编译错误，但会限制随机变量的取值范围
class impact;
    rand bit       x;  // 0或1
    rand bit [1:0] y;  // 0,1,2或3
    constraint c_xy
    {
        y > 0;                // y必须大于0，即y∈{1,2,3}
        (x == 0) -> y == 0;  // x为0时y必须为0，与y>0冲突
    }
endclass

module test;
    impact p;

    initial begin
        p = new();
        assert(p.randomize());
        $display("x = %0d", p.x);  // 运行结果：始终为1
        $display("y = %0d", p.y);  // 运行结果：1/2/3
    end
endmodule

// 运行结果（y随机但x固定，以下为示例）：
// x = 1
// y = 2
//
// 解析：
// 当x=0时：蕴含约束要求y==0，但y>0要求y∈{1,2,3}，两者矛盾，无解
// 当x=1时：蕴含约束不生效，仅需满足y>0，y∈{1,2,3}
// 因此求解器只能选择x=1，y∈{1,2,3}
