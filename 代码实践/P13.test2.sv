// 知识点：SystemVerilog rand_mode控制变量随机化
// 1. rand_mode(0)：禁用指定rand变量的随机化，变量保持当前值不变
// 2. rand_mode(1)：启用指定rand变量的随机化（默认状态）
// 3. 语法：对象名.变量名.rand_mode(0/1)
// 4. 与constraint_mode不同：constraint_mode控制约束，rand_mode控制变量
// 5. 禁用rand_mode后，约束中涉及该变量的部分仍需满足，但变量值由用户指定
class Packet;
    rand bit [7:0] length, payload[];
    constraint c_valid {length > 0; payload.size() == length;}
endclass

module test;
    Packet p;

    initial begin
        p = new();
        p.length.rand_mode(0);  // 禁用length的随机化
        p.length = 42;           // 手动设置length=42
        assert(p.randomize());   // 随机化：length保持42，仅随机化payload
        $display("p::length is %0d", p.length);  // 运行结果：42
        // 思考：为什么p.length=42，而不是被随机化？
        // 答：因为p.length.rand_mode(0)禁用了length的随机化，
        //     randomize()不会改变length的值，length保持用户设置的42

        p.length.rand_mode(1);  // 重新启用length的随机化
        assert(p.randomize());   // 随机化：length被随机化（仍受约束length>0）
        $display("p::length is %0d", p.length);  // 运行结果：1~255之间随机值
        // 思考：为什么p.length又被随机化了？
        // 答：因为p.length.rand_mode(1)重新启用了length的随机化，
        //     randomize()会重新随机化length的值（满足约束length>0）
    end
endmodule

// 运行结果（随机值每次不同，以下为示例）：
// p::length is 42
// p::length is 187
//
// 解析：
// 第一次：rand_mode(0)禁用length随机化 → length保持42，仅payload被随机化
//         约束 payload.size()==length 仍生效，payload数组大小变为42
// 第二次：rand_mode(1)启用length随机化 → length被重新随机化（1~255）
