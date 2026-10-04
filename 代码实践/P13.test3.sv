// 知识点：SystemVerilog 内联约束(randomize() with)
// 1. randomize() with {}：在调用randomize时添加额外约束
// 2. with{}中的约束与class中的约束是"与"(AND)关系，必须同时满足
// 3. 内联约束是临时约束，只对本次randomize()调用生效
// 4. 若with{}约束与class约束冲突，randomize()会失败返回0
// 5. inside操作符：指定取值范围，支持多个区间，如 {[0:100],[1000:2000]}
class Transaction;
    rand bit [31:0] addr, data;
    constraint c1 {addr inside{[0:100],[1000:2000]};}  // addr在0-100或1000-2000
endclass

module test;
    Transaction t;

    initial begin
        t = new();
        // 第一次随机：添加内联约束，addr还需满足50~1500，data<10
        assert(t.randomize() with {addr >= 50; addr <= 1500; data < 10;});
        $display("t::addr is %0d", t.addr);   // 运行结果：50~100或1000~1500之间
        $display("t::data is %0d", t.data);   // 运行结果：0~9之间

        // 第二次随机：添加内联约束，addr固定为2000，data>10
        assert(t.randomize() with {addr == 2000; data > 10;});
        $display("t::addr is %0d", t.addr);   // 运行结果：2000
        $display("t::data is %0d", t.data);   // 运行结果：11~4294967295之间
    end
endmodule

// 运行结果（随机值每次不同，以下为示例）：
// t::addr is 87
// t::data is 3
// t::addr is 2000
// t::data is 12345
//
// 解析：
// 第一次：class约束 c1 要求 addr∈[0:100]∪[1000:2000]
//         with约束 要求 addr∈[50:1500], data<10
//         两者取交集 → addr∈[50:100]∪[1000:1500], data∈[0:9]
// 第二次：class约束 c1 要求 addr∈[0:100]∪[1000:2000]
//         with约束 要求 addr==2000, data>10
//         两者取交集 → addr==2000(在[1000:2000]内), data∈[11:2^32-1]

// 思考：with{}当中的约束和class中的约束是什么关系？
// 答：是与(AND)关系。with{}中的内联约束与class中定义的约束必须同时满足，
//     相当于在原有约束基础上叠加更多限制。若两者无交集则randomize()失败。
