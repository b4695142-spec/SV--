// 知识点：SystemVerilog 约束控制(constraint_mode)
// 1. constraint_mode(0)：禁用指定约束
// 2. constraint_mode(1)：启用指定约束（默认状态）
// 3. 语法：对象名.约束名.constraint_mode(0/1)
// 4. 不能对对象直接调用constraint_mode，必须指定具体约束名
// 5. 可通过控制约束的启停，改变随机化行为
class Packet;
    rand int length;
    constraint c_short {length inside {[1:32]};}      // 短包约束
    constraint c_long  {length inside {[1000:1023]};}  // 长包约束
endclass

module test;
    Packet p;

    initial begin
        p = new();
        
        // 第一次随机：禁用c_short，仅c_long生效
        p.c_short.constraint_mode(0);   // 禁用短包约束
        assert(p.randomize());
        $display("p::length is %0d", p.length);  // 运行结果：1000~1023之间
        
        // 第二次随机：禁用所有约束，仅启用c_short
        p.c_short.constraint_mode(0);  // 禁用c_short
        p.c_long.constraint_mode(0);   // 禁用c_long
        p.c_short.constraint_mode(1);  // 仅启用c_short
        assert(p.randomize());
        $display("p::length is %0d", p.length);  // 运行结果：1~32之间
    end
endmodule

// 运行结果（随机值每次不同，以下为示例）：
// p::length is 1015
// p::length is 23
//
// 解析：
// 第一次：c_short禁用，c_long生效 → length在1000~1023之间
// 第二次：c_long禁用，c_short生效 → length在1~32之间

// 思考：是否可以全部将c_short和c_long打开？
// 答：不能。两个约束同时打开时，length需要同时满足 inside {[1:32]} 和 inside {[1000:1023]}，
//     这两个区间没有交集，无解，randomize()会失败并返回0。
